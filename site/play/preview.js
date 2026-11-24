const send = (type, text) => parent.postMessage({type, text}, "*");
window.reportPlaygroundReady = (success) => {
  if (success) {
    document.querySelector("#game").focus();
    send("ready");
  } else {
    send("failed");
  }
};

window.addEventListener("message", async ({source, data}) => {
  if (source !== parent || data?.type !== "run-playground") return;
  try {
    if (typeof Engine === "undefined" || !Engine.isWebGLAvailable(2)) {
      throw new Error("This preview requires WebGL 2.");
    }
    const engine = new Engine({
      executable: "godot",
      canvas: document.querySelector("#game"),
      canvasResizePolicy: 0,
      persistentPaths: [],
      onPrint: (text) => {
        if (!/^(Godot Engine|OpenGL API|WebGL API|Build configuration:|Failed to assign PWA callback)/.test(text)) {
          send("output", text);
        }
      },
      onPrintError: (text) => send("error", text),
    });
    await Promise.all([
      engine.init("godot"),
      engine.preloadFile("playgrounds.pck?v=editable-1", "playgrounds.pck"),
    ]);
    engine.copyToFS("/student.gd", new TextEncoder().encode(data.code));
    await engine.start({args: ["--main-pack", "playgrounds.pck", "--", data.key]});
  } catch (error) {
    send("failed", error.message);
  }
}, {once: true});
