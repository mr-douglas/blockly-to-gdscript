const controlsTemplate = document.createElement("template");
controlsTemplate.innerHTML = `<div class="practice-controls">
  <label for="practice-code">Edit the example</label>
  <textarea id="practice-code" aria-describedby="practice-help" spellcheck="false" autocapitalize="off" autocomplete="off" wrap="off"></textarea>
  <div class="practice-actions">
    <button type="button" data-action="run">Run</button>
    <button type="button" data-action="stop" disabled>Stop</button>
    <button type="button" data-action="reset">Reset code</button>
  </div>
  <p id="practice-help">Run with Ctrl+Enter or ⌘+Enter. The first run downloads Godot.</p>
  <p role="status">Ready to run.</p>
  <div aria-labelledby="output-label" role="log">
    <strong id="output-label">Output</strong>
    <pre data-output></pre>
  </div>
</div>`;

const runnerBase = new URL("../runner/", import.meta.url);
let workerURL;

function loadWorker() {
  workerURL ??= fetch(new URL("worker.js", runnerBase))
    .then((response) => {
      if (!response.ok) throw new Error("Could not load the GDScript runner.");
      return response.text();
    })
    .then((source) => `data:text/javascript,${encodeURIComponent(source)}`)
    .catch((error) => {
      workerURL = undefined;
      throw error;
    });
  return workerURL;
}

for (const [index, practice] of [...document.querySelectorAll("[data-practice]")].entries()) {
  const example = practice.querySelector("pre");
  const starter = example.textContent;
  const fullScript = practice.dataset.practice === "full";
  const turtle = practice.dataset.practice === "turtle"
    ? (await import("./turtle-preview.js?v=editable-1")).createTurtlePreview(document.querySelector("[data-route-stage]"))
    : null;
  const controls = controlsTemplate.content.cloneNode(true);
  const editor = controls.querySelector("textarea");
  const label = controls.querySelector("label");
  const help = controls.querySelector("#practice-help");
  const outputLabel = controls.querySelector("#output-label");
  for (const element of [editor, help, outputLabel]) element.id += `-${index + 1}`;
  label.htmlFor = editor.id;
  label.textContent = practice.dataset.editorLabel || label.textContent;
  editor.setAttribute("aria-describedby", help.id);
  controls.querySelector('[role="log"]').setAttribute("aria-labelledby", outputLabel.id);
  const expectedOutput = practice.dataset.expectedOutput;
  const run = controls.querySelector('[data-action="run"]');
  const stop = controls.querySelector('[data-action="stop"]');
  const reset = controls.querySelector('[data-action="reset"]');
  const status = controls.querySelector("[role=status]");
  const consoleOutput = controls.querySelector("[data-output]");
  let activeRun;

  editor.value = starter;
  editor.rows = Math.min(16, Math.max(6, starter.split("\n").length + 1));
  if (practice.hasAttribute("data-reference")) {
    const disclosure = document.createElement("details");
    const summary = document.createElement("summary");
    summary.textContent = "Edit and run this example";
    disclosure.append(summary, controls);
    example.after(disclosure);
  } else {
    example.replaceWith(controls);
  }

  function complete(session, text) {
    if (activeRun !== session) return;
    clearTimeout(session.timeout);
    session.worker?.terminate();
    activeRun = undefined;
    run.disabled = false;
    stop.disabled = true;
    status.textContent = text;
  }

  function append(text) {
    if (consoleOutput.textContent.length >= 24000) return;
    consoleOutput.append(`${text}\n`);
  }

  async function execute() {
    if (activeRun) return;
    const source = editor.value.replace(/^[ \t]+/gm, (indent) => indent.replaceAll("\t", "    "));
    if (!source.trim()) {
      status.textContent = "Enter some GDScript before running.";
      return;
    }

    turtle?.reset();
    const session = {};
    activeRun = session;
    run.disabled = true;
    stop.disabled = false;
    consoleOutput.textContent = "";
    status.textContent = "Loading Godot…";
    session.timeout = setTimeout(() => complete(session, "Godot took too long to load. Try running again."), 45000);

    try {
      const url = await loadWorker();
      if (activeRun !== session) return;
      const worker = new Worker(url);
      session.worker = worker;
      worker.onerror = () => complete(session, "Could not start Godot in this browser.");
      worker.onmessage = ({data}) => {
        if (activeRun !== session) return;
        switch (data.type) {
          case "started":
            clearTimeout(session.timeout);
            status.textContent = "Running…";
            session.timeout = setTimeout(() => complete(session, "Stopped after 3 seconds. Check for a loop that never ends."), 3000);
            break;
          case "output":
            if (!turtle?.capture(data.text)) append(data.text);
            break;
          case "error":
            session.hasError = true;
            if (/res:\/\/runner\.gd:/.test(data.text)) break;
            const lineNumber = (line) => Math.max(1, Number(line) - (fullScript || turtle && /^extends\s/m.test(source) ? 0 : 3));
            append(data.text
              .replace(/^Line (\d+):/, (_, line) => `Line ${lineNumber(line)}:`)
              .replace(/gdscript:\/\/[^)\s]+\.gd:(\d+)/g, (_, line) => `line ${lineNumber(line)}`));
            break;
          case "done":
            const passed = !session.hasError && data.code === 0;
            complete(session, passed ? "Run finished." : "Run ended with errors.");
            if (passed && expectedOutput !== undefined) {
              status.textContent = consoleOutput.textContent.replace(/\n$/, "") === expectedOutput
                ? "Success. Your output matches the goal."
                : "Compare your output with the goal, then try again.";
            }
            if (turtle && passed) turtle.play();
            if (!turtle && !consoleOutput.textContent) append("No output.");
            break;
        }
      };
      const script = turtle ? turtle.wrap(source) : fullScript ? source : `extends Node\n\nfunc _ready():\n${source.split("\n").map((line) => `    ${line}`).join("\n")}`;
      worker.postMessage({source: script, base: runnerBase.href});
    } catch (error) {
      complete(session, error.message);
    }
  }

  if (turtle) {
    for (const button of document.querySelectorAll("[data-load-rover]")) {
      button.addEventListener("click", () => {
        if (activeRun) complete(activeRun, "");
        turtle.reset();
        const exampleCode = button.previousElementSibling.textContent;
        editor.value = button.dataset.loadRover === "functions" ? turtle.wrap(starter) : starter + "\n" + exampleCode;
        consoleOutput.textContent = "";
        status.textContent = "Example loaded. Run it to see the route.";
        editor.focus();
      });
    }
  }

  run.addEventListener("click", execute);
  stop.addEventListener("click", () => {
    if (activeRun) complete(activeRun, "Run stopped.");
  });
  reset.addEventListener("click", () => {
    if (activeRun) complete(activeRun, "");
    turtle?.reset();
    editor.value = starter;
    consoleOutput.textContent = "";
    status.textContent = "Starter code restored.";
    editor.focus();
  });
  editor.addEventListener("keydown", (event) => {
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      event.preventDefault();
      execute();
    } else if (event.key === "Enter" && !event.isComposing) {
      event.preventDefault();
      const before = editor.value.slice(0, editor.selectionStart).split("\n").at(-1);
      const indent = before.match(/^\s*/)[0];
      const innerIndent = /:\s*$/.test(before) ? "    " : "";
      editor.setRangeText(`\n${indent}${innerIndent}`, editor.selectionStart, editor.selectionEnd, "end");
    }
  });
}
