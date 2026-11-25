// Opens game examples from the built site in headless Chrome and saves
// screenshots of the loading bar and of the running game, so the web build
// can be checked exactly as students see it. It also checks that the
// "Click here to interact" prompt appears when the game loses focus and goes
// away when the game is clicked. Run by .github/workflows/browser.yml.
//   SITE=site SHOTS=out node .github/browser-shots.cjs
const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const {chromium} = require("playwright");

const site = path.resolve(process.env.SITE || "site");
const shots = path.resolve(process.env.SHOTS || "shots");
fs.mkdirSync(shots, {recursive: true});

// The last value says whether the editor is embedded in a lesson page.
const PAGES = [
  ["racing-laps", "/play/?demo=racing&lesson=laps", false],
  ["racing-fixed", "/play/?demo=racing&lesson=fixed-track", false],
  ["platformer-3d", "/play/?demo=movement-3d&lesson=goal-3d", false],
  ["ui-start-menu", "/play/?demo=ui&lesson=start-menu", false],
  ["top-down", "/play/?demo=top-down", false],
  ["lesson-racing-laps", "/racing/laps.html", true],
];
const TYPES = {
  ".html": "text/html; charset=utf-8", ".js": "text/javascript", ".css": "text/css",
  ".json": "application/json", ".wasm": "application/wasm", ".png": "image/png",
  ".svg": "image/svg+xml", ".pck": "application/octet-stream",
};
// Stream large files at about 8 MB/s so the progress bar has time to show.
const CHUNK = 256 * 1024;
const PAUSE_MS = 30;

const server = http.createServer((request, response) => {
  const url = new URL(request.url, "http://localhost");
  let file = path.join(site, decodeURIComponent(url.pathname));
  if (!file.startsWith(site)) {
    response.writeHead(403).end();
    return;
  }
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, "index.html");
  if (!fs.existsSync(file)) {
    response.writeHead(404).end();
    return;
  }
  const data = fs.readFileSync(file);
  response.writeHead(200, {
    "Content-Type": TYPES[path.extname(file)] || "application/octet-stream",
    "Content-Length": data.length,
    // GitHub Pages sends this too. The sandboxed preview has an opaque origin.
    "Access-Control-Allow-Origin": "*",
  });
  if (data.length < 2 * CHUNK) {
    response.end(data);
    return;
  }
  let offset = 0;
  const next = () => {
    if (offset >= data.length) {
      response.end();
      return;
    }
    response.write(data.subarray(offset, offset + CHUNK));
    offset += CHUNK;
    setTimeout(next, PAUSE_MS);
  };
  next();
});

async function hintShown(preview) {
  return (await preview.locator("#focus-hint").getAttribute("hidden", {timeout: 5000})) === null;
}

// Click outside the game, then on it, and check the prompt each time.
async function checkFocusHint(page, root, name, log) {
  const preview = root.frameLocator(".play-stage iframe");
  const stage = root.locator(".play-stage");
  let ok = true;
  await page.mouse.click(5, 5);
  await page.waitForTimeout(800);
  if (await hintShown(preview)) {
    log.push(`${name} prompt shown after clicking outside the game`);
  } else {
    log.push(`${name} FAIL: no prompt after clicking outside the game`);
    ok = false;
  }
  await stage.screenshot({path: path.join(shots, `${name}-unfocused.png`)});
  await preview.locator("#game").click({position: {x: 40, y: 200}});
  await page.waitForTimeout(800);
  if (!(await hintShown(preview))) {
    log.push(`${name} prompt hidden after clicking the game`);
  } else {
    log.push(`${name} FAIL: prompt still shown after clicking the game`);
    ok = false;
  }
  await stage.screenshot({path: path.join(shots, `${name}-focused.png`)});
  return ok;
}

async function visit(browser, name, address, embedded, log) {
  const page = await browser.newPage({viewport: {width: 1100, height: 1000}});
  page.on("pageerror", (error) => log.push(`${name} page error: ${error.message}`));
  await page.goto(address);
  const root = embedded ? page.frameLocator("iframe[data-platformer-editor]") : page;
  const start = root.locator("#start");
  await root.locator("#start:not([disabled])").waitFor({timeout: 30000});
  await start.scrollIntoViewIfNeeded();
  await start.click();
  const stage = root.locator(".play-stage");
  const status = root.locator("#load-status");
  const seen = new Set();
  const started = Date.now();
  let ready = false;
  let last = "";
  while (Date.now() - started < 90000) {
    const text = (await status.textContent()) || "";
    if (!text.startsWith("Loading the game") && text !== last) {
      log.push(`${name} status after ${((Date.now() - started) / 1000).toFixed(1)} s: ${text}`);
    }
    last = text;
    const percent = Number((text.match(/(\d+)%/) || [])[1]);
    if (!seen.has("loading") && percent >= 25 && percent <= 75) {
      seen.add("loading");
      await stage.screenshot({path: path.join(shots, `${name}-loading.png`)});
    }
    if (text.startsWith("Game ready")) {
      ready = true;
      break;
    }
    if (/could not|too long|failed|requires|stopped/i.test(text)) {
      break;
    }
    await page.waitForTimeout(150);
  }
  log.push(`${name} ${ready ? "ready" : "NOT READY"} after ${((Date.now() - started) / 1000).toFixed(1)} s`);
  await page.waitForTimeout(3000);
  await stage.screenshot({path: path.join(shots, `${name}.png`)});
  let ok = ready;
  if (ready) ok = await checkFocusHint(page, root, name, log);
  const messages = (await root.locator("#messages").textContent()) || "";
  if (messages.trim()) log.push(`${name} game output:\n${messages.trim()}`);
  await page.close();
  return ok;
}

(async () => {
  await new Promise((resolve) => server.listen(8000, "127.0.0.1", resolve));
  const browser = await chromium.launch({
    args: ["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--ignore-gpu-blocklist"],
  });
  const log = [];
  let failures = 0;
  for (const [name, route, embedded] of PAGES) {
    try {
      if (!(await visit(browser, name, `http://127.0.0.1:8000${route}`, embedded, log))) failures += 1;
    } catch (error) {
      log.push(`${name} FAIL: ${error.message.split("\n")[0]}`);
      failures += 1;
    }
  }
  await browser.close();
  server.close();
  log.push(failures ? `BROWSER FAILED ${failures}` : "BROWSER PASSED");
  fs.writeFileSync(path.join(shots, "browser.log"), log.join("\n") + "\n");
  console.log(log.join("\n"));
  process.exit(failures ? 1 : 0);
})();
