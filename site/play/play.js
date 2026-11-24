const playgrounds = {
  "top-down": {
    title: "Crystal trail",
    goal: "Collect all three crystals, then reach the exit. Walk around the walls.",
    controls: "Arrow keys to move. R to restart.",
    task: "Find the line that gives the player a velocity. Predict what happens if you halve SPEED. Change it here, run the edited code, then test diagonals and check that the walls still stop the player.",
    file: "top_down.gd",
  },
  platformer: {
    title: "Sky steps",
    goal: "Jump across the gaps and reach the green marker on the final platform.",
    controls: "Left and Right to move, Space to jump, and R to restart.",
    task: "Predict how changing JUMP_SPEED affects which platforms you can reach. Run your edited code and test the same gap twice. Explain why the floor check prevents a second jump in mid-air.",
    file: "platformer.gd",
  },
  "movement-3d": {
    title: "Landing pad",
    goal: "Guide the yellow character around the obstacles to the green landing pad.",
    controls: "Arrow keys to move. R to restart.",
    task: "Find the lines that map input to the x and z axes. Predict what happens if you negate direction.y in the z assignment, then run that change here.",
    file: "movement_3d.gd",
  },
  "physics-3d": {
    title: "Ramp and crates",
    goal: "Release the ball and observe how gravity, the ramp and the collisions move the crates.",
    controls: "Space to release the ball. R to reset the simulation.",
    task: "Predict what happens if you double ball.mass while keeping IMPULSE the same. Change one value at a time in the editor and compare how the ball and crates move after release.",
    file: "physics_3d.gd",
  },
  "landing-pad-follow": {
    title: "Landing Pad with a follow camera",
    goal: "Turn towards the green landing pad and steer around the obstacles. The camera stays behind your character.",
    controls: "Left and Right to turn. Up to move forward, Down to reverse, and R to restart.",
    task: "Compare this version with the original Landing Pad. Find how the code turns the character and uses its local forward direction. Predict what halving TURN_SPEED will change, then run the edited code.",
    file: "landing_pad_follow.gd",
  },
};

const requested = new URL(location.href).searchParams.get("demo");
const key = Object.hasOwn(playgrounds, requested) ? requested : "top-down";
const demo = playgrounds[key];
document.querySelector("#demo-title").textContent = demo.title;
document.querySelector("#goal").textContent = demo.goal;
document.querySelector("#controls").textContent = demo.controls + " Click the game to give it keyboard focus.";
document.querySelector("#task").textContent = demo.task;
document.querySelector(`nav a[href="?demo=${key}"]`).setAttribute("aria-current", "page");

const source = document.querySelector("#source");
const start = document.querySelector("#start");
const apply = document.querySelector("#apply");
const reset = document.querySelector("#reset");
const stop = document.querySelector("#stop");
const stage = document.querySelector(".play-stage");
const status = document.querySelector("#load-status");
const editorStatus = document.querySelector("#editor-status");
const consoleOutput = document.querySelector("#console");
const messages = document.querySelector("#messages");
let starter;
let frame;
let timer;

function stopGame() {
  clearTimeout(timer);
  frame?.remove();
  frame = undefined;
  start.hidden = false;
  stop.disabled = true;
}

function run() {
  if (!source.value.trim()) {
    editorStatus.textContent = "Enter some GDScript first.";
    source.focus();
    return;
  }
  stopGame();
  messages.textContent = "";
  consoleOutput.open = false;
  editorStatus.textContent = "Starting a new game with this code.";
  status.textContent = "Loading Godot…";
  start.hidden = true;
  stop.disabled = false;
  const preview = document.createElement("iframe");
  preview.title = `${demo.title} game preview`;
  preview.sandbox = "allow-scripts";
  preview.src = "preview.html?v=editable-1";
  frame = preview;
  const code = source.value;
  preview.addEventListener("load", () => {
    if (preview === frame) preview.contentWindow.postMessage({type: "run-playground", key, code}, "*");
  }, {once: true});
  stage.append(preview);
  timer = setTimeout(() => {
    stopGame();
    status.textContent = "Godot took too long to start. Try running the code again.";
    editorStatus.textContent = status.textContent;
  }, 45000);
}

window.addEventListener("message", ({source: sender, data}) => {
  if (!frame || sender !== frame.contentWindow || !data) return;
  if (data.type === "ready") {
    clearTimeout(timer);
    status.textContent = "Game ready. Click the preview, then use the keys shown above.";
    editorStatus.textContent = "Game restarted with the code in the editor.";
    frame.focus();
  } else if (data.type === "error" || data.type === "output") {
    if (messages.textContent.length < 16000) messages.append(String(data.text).slice(0, 2000), "\n");
    if (data.type === "error") consoleOutput.open = true;
  } else if (data.type === "failed") {
    stopGame();
    status.textContent = data.text || "The script could not start. Check the error below.";
    editorStatus.textContent = status.textContent;
    consoleOutput.open = true;
    source.focus();
  }
});

fetch(`source/${demo.file}?v=editable-1`)
  .then((response) => {
    if (!response.ok) throw new Error("Could not load the script.");
    return response.text();
  })
  .then((code) => {
    starter = source.value = code;
    source.disabled = start.disabled = apply.disabled = reset.disabled = false;
  })
  .catch((error) => {
    status.textContent = error.message;
  });

start.addEventListener("click", run);
apply.addEventListener("click", run);
reset.addEventListener("click", () => {
  source.value = starter;
  editorStatus.textContent = "Starter code restored. Run it to restart the game.";
  source.focus();
});
stop.addEventListener("click", () => {
  stopGame();
  status.textContent = editorStatus.textContent = "Game stopped.";
  start.focus();
});
source.addEventListener("keydown", (event) => {
  if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
    event.preventDefault();
    run();
  } else if (event.key === "Enter" && !event.isComposing) {
    event.preventDefault();
    const currentLine = source.value.slice(0, source.selectionStart).split("\n").at(-1);
    const indent = currentLine.match(/^\s*/)[0];
    const deeper = /:\s*$/.test(currentLine) ? (indent.includes(" ") ? "    " : "\t") : "";
    source.setRangeText(`\n${indent}${deeper}`, source.selectionStart, source.selectionEnd, "end");
  }
});
