// This worker is loaded from a data URL, which gives student code an opaque origin.
self.onmessage = async ({data: {source, base}}) => {
  let finished = false;
  let lines = 0;
  function finish(code) {
    if (finished) return;
    finished = true;
    postMessage({type: "done", code});
    self.close();
  }
  function report(type, text) {
    if (finished) return;
    if (lines >= 200) {
      postMessage({type: "error", text: "Stopped after 200 lines of output."});
      finish(1);
      return;
    }
    lines++;
    postMessage({type, text: String(text).slice(0, 4000)});
  }

  try {
    importScripts(new URL("engine.js", base).href);
    const engine = await Godot({
      locateFile: () => new URL("engine.wasm", base).href,
      print: (text) => {
        if (!text.startsWith("Godot Engine v") && !text.startsWith("Build configuration: Emscripten")) {
          report("output", text);
        }
      },
      printErr: (text) => report("error", text),
    });
    // The web template calls through window even in headless mode.
    self.window = self;
    self.finishStudentRun = finish;
    engine.initConfig({
      canvas: new OffscreenCanvas(1, 1),
      locale: "en",
      onExit: finish,
    });
    const pack = await fetch(new URL("engine.pck", base), {credentials: "omit"});
    if (!pack.ok) throw new Error("Could not load the GDScript project.");
    engine.copyToFS("/engine.pck", await pack.arrayBuffer());
    engine.copyToFS("/student.gd", new TextEncoder().encode(source));
    postMessage({type: "started"});
    engine.callMain(["--headless", "--main-pack", "/engine.pck"]);
  } catch (error) {
    report("error", error.message);
    finish(1);
  }
};
