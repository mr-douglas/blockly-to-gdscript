// Opens game examples from the built site in headless Chrome and saves
// screenshots of the loading bar and of the running game, so the web build
// can be checked exactly as students see it. Run by .github/workflows/browser.yml.
//   SITE=site SHOTS=out node .github/browser-shots.cjs
const fs = require("node:fs");
const http = require("node:http");
const path = require("node:path");
const {chromium} = require("playwright");

const site = path.resolve(process.env.SITE || "site");
const shots = path.resolve(process.env.SHOTS || "shots");
fs.mkdirSync(shots, {recursive: true});

const PAGES = [
  ["racing-laps", "/play/?demo=racing&lesson=laps"],
  ["racing-fixed", "/play/?demo=racing&lesson=fixed-track"],
  ["platformer-3d", "/play/?demo=movement-3d&lesson=goal-3d"],
  ["ui-start-menu", "/play/?demo=ui&lesson=start-menu"],
  ["top-down", "/play/?demo=top-down"],
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

async function visit(browser, name, address, log) {
  const page = await browser.newPage({viewport: {width: 1100, height: 1000}});
  page.on("pageerror", (error) => log.push(`${name} page error: ${error.message}`));
  await page.goto(address);
  await page.waitForSelector("#start:not([disabled])", {timeout: 30000});
  await page.click("#start");
  const stage = page.locator(".play-stage");
  const status = page.locator("#load-status");
  const seen = new Set();
  const started = Date.now();
  let ready = false;
  while (Date.now() - started < 180000) {
    const text = (await status.textContent()) || "";
    const percent = Number((text.match(/(\d+)%/) || [])[1]);
    if (!seen.has("loading") && percent >= 25 && percent <= 75) {
      seen.add("loading");
      log.push(`${name} progress: ${text}`);
      await stage.screenshot({path: path.join(shots, `${name}-loading.png`)});
    }
    if (!seen.has("starting") && text.startsWith("Starting")) {
      seen.add("starting");
      log.push(`${name} ${text} after ${((Date.now() - started) / 1000).toFixed(1)} s`);
      await stage.screenshot({path: path.join(shots, `${name}-starting.png`)});
    }
    if (text.startsWith("Game ready")) {
      ready = true;
      break;
    }
    if (/could not|too long|failed|requires/i.test(text)) {
      log.push(`${name} status: ${text}`);
      break;
    }
    await page.waitForTimeout(150);
  }
  log.push(`${name} ${ready ? "ready" : "NOT READY"} after ${((Date.now() - started) / 1000).toFixed(1)} s`);
  if (ready) {
    await page.waitForTimeout(4000);
    await stage.screenshot({path: path.join(shots, `${name}.png`)});
  }
  const messages = (await page.locator("#messages").textContent()) || "";
  if (messages.trim()) log.push(`${name} game output:\n${messages.trim()}`);
  await page.close();
  return ready;
}

(async () => {
  await new Promise((resolve) => server.listen(8000, "127.0.0.1", resolve));
  const browser = await chromium.launch({
    args: ["--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--ignore-gpu-blocklist"],
  });
  const log = [];
  let failures = 0;
  for (const [name, route] of PAGES) {
    if (!(await visit(browser, name, `http://127.0.0.1:8000${route}`, log))) failures += 1;
  }
  await browser.close();
  server.close();
  log.push(failures ? `BROWSER FAILED ${failures}` : "BROWSER PASSED");
  fs.writeFileSync(path.join(shots, "browser.log"), log.join("\n") + "\n");
  console.log(log.join("\n"));
  process.exit(failures ? 1 : 0);
})();
