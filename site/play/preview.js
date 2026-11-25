const send = (type, text, extra = {}) => parent.postMessage({type, text, ...extra}, "*");
const overlay = document.querySelector("#loading");
const bar = document.querySelector("#loading-bar");
const caption = document.querySelector("#loading-text");

let finished = false;

function showProgress(fraction, text) {
  // The engine can still report progress after the game has started.
  if (finished) return;
  const percent = Math.max(0, Math.min(100, Math.floor(fraction * 100)));
  bar.style.width = `${percent}%`;
  overlay.setAttribute("aria-valuenow", String(percent));
  caption.textContent = text ?? `Loading the game… ${percent}%`;
  send("progress", caption.textContent, {percent});
}

window.reportPlaygroundReady = (success) => {
  finished = true;
  overlay.hidden = true;
  if (success) {
    document.querySelector("#game").focus();
    send("ready");
  } else {
    send("failed");
  }
};

// build.json is written by runner/build.sh. It gives the download sizes for the
// progress bar and a version that changes whenever the game files change.
async function loadBuildInfo() {
  try {
    const response = await fetch("build.json", {cache: "no-cache"});
    if (response.ok) return await response.json();
  } catch {
    // Without build.json the bar shows megabytes instead of a percentage.
  }
  return {};
}

async function download(url, onBytes) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Could not download the game files (${response.status}).`);
  if (!response.body) {
    const buffer = await response.arrayBuffer();
    onBytes(buffer.byteLength);
    return buffer;
  }
  const reader = response.body.getReader();
  const chunks = [];
  let received = 0;
  for (;;) {
    const {done, value} = await reader.read();
    if (done) break;
    chunks.push(value);
    received += value.length;
    onBytes(received);
  }
  const data = new Uint8Array(received);
  let offset = 0;
  for (const chunk of chunks) {
    data.set(chunk, offset);
    offset += chunk.length;
  }
  return data.buffer;
}

window.addEventListener("message", async ({source, data}) => {
  if (source !== parent || data?.type !== "run-playground") return;
  try {
    if (typeof Engine === "undefined" || !Engine.isWebGLAvailable(2)) {
      throw new Error("This preview requires WebGL 2.");
    }
    showProgress(0);
    const info = await loadBuildInfo();
    const wasmSize = Number(info.wasmSize) || 0;
    const pckSize = Number(info.pckSize) || 0;
    let wasmBytes = 0;
    let pckBytes = 0;
    const update = () => {
      const total = wasmSize + pckSize;
      if (total > 0) {
        showProgress((wasmBytes + pckBytes) / total);
      } else {
        showProgress(0, `Loading the game… ${((wasmBytes + pckBytes) / 1048576).toFixed(1)} MB`);
      }
    };
    const engine = new Engine({
      executable: "godot",
      canvas: document.querySelector("#game"),
      canvasResizePolicy: 0,
      persistentPaths: [],
      onProgress: (current) => {
        wasmBytes = wasmSize ? Math.min(current, wasmSize) : current;
        update();
      },
      onPrint: (text) => {
        if (!/^(Godot Engine|OpenGL API|WebGL API|Build configuration:|Failed to assign PWA callback)/.test(text)) {
          send("output", text);
        }
      },
      onPrintError: (text) => {
        // The sandboxed preview has no service-worker access.
        if (text.trim() !== "Failed to assign PWA callback") send("error", text);
      },
    });
    const version = info.version ?? data.lesson ?? "editable-1";
    const [, pack] = await Promise.all([
      engine.init("godot"),
      download(`playgrounds.pck?v=${encodeURIComponent(version)}`, (bytes) => {
        pckBytes = pckSize ? Math.min(bytes, pckSize) : bytes;
        update();
      }),
    ]);
    await engine.preloadFile(pack, "playgrounds.pck");
    overlay.classList.add("starting");
    showProgress(1, "Starting the game…");
    engine.copyToFS("/student.gd", new TextEncoder().encode(data.code));
    await engine.start({args: ["--main-pack", "playgrounds.pck", "--", data.key]});
  } catch (error) {
    if (finished) {
      send("error", error.message);
      return;
    }
    finished = true;
    overlay.hidden = true;
    send("failed", error.message);
  }
}, {once: true});
