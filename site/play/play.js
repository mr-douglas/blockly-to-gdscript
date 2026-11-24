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
    goal: "Jump across the gaps and reach the trophy on the final platform.",
    controls: "Left and Right to move, Space to jump, and R to restart.",
    task: "Predict how changing JUMP_SPEED affects which platforms you can reach. Run your edited code and test the same gap twice. Explain why the floor check prevents a second jump in mid-air.",
    file: "platformer.gd",
  },
  "movement-3d": {
    title: "Landing pad",
    goal: "Guide the character around the brick walls to the green landing pad.",
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

const params = new URL(location.href).searchParams;
const requested = params.get("demo");
const platformerLessons = {
  movement: {
    title: "Platformer lesson 1 · Sideways movement",
    goal: "Move the frog left and right using the arrow keys.",
    controls: "Left and Right to move. R to restart.",
    task: "Predict what happens if you double SPEED. Change it, run the edited code, and compare with the original.",
    file: "platformer_move.gd",
  },
  "collision": {
    "title": "Platformer lesson 2 · Make walls solid",
    "goal": "Move into a wall and see where the character stops.",
    "controls": "Left and Right to move. R to restart.",
    "task": "Compare move_and_slide() with a direct position update. Test the same wall in both versions.",
    "file": "platformer_collision.gd"
  },
  "gravity": {
    "title": "Platformer lesson 3 · Fall and land with gravity",
    "goal": "Watch the character fall onto a solid floor.",
    "controls": "Left and Right to move. R to repeat the fall.",
    "task": "Change GRAVITY and compare the time it takes to reach the floor.",
    "file": "platformer_gravity.gd"
  },
  "jump": {
    "title": "Platformer lesson 4 · Jump only from the floor",
    "goal": "Jump onto the raised platform after landing.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Compare JUMP_SPEED values of 240 and 440 on the same platform.",
    "file": "platformer_jump.gd"
  },
  "respawn": {
    "title": "Platformer lesson 5 · Recover after falling",
    "goal": "Fall into the gap to test respawning, then jump across it.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Try an elevated spawn to see the effect of preserving or resetting velocity.",
    "file": "platformer_respawn.gd"
  },
  "goal": {
    "title": "Platformer lesson 6 · Finish the level with a signal",
    "goal": "Jump the gap and reach the trophy.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Disconnect and reconnect the goal signal, then test the difference by reaching the finish.",
    "file": "platformer_goal.gd"
  },
  "coins": {
    "title": "Platformer lesson 7 · Collect coins and count them",
    "goal": "Collect the apple coins on the ground and above the gap.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Set COIN_VALUE to 5 and add a fourth position to the coin list.",
    "file": "platformer_coins.gd"
  },
  "hazards": {
    "title": "Platformer lesson 8 · Add hazards that reset the player",
    "goal": "Jump the gap, then jump over the spikes on the far side.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Add a second hazard and predict whether your return path is still playable.",
    "file": "platformer_hazards.gd"
  },
  "checkpoint": {
    "title": "Platformer lesson 9 · Save a checkpoint",
    "goal": "Touch the checkpoint pole to raise its flag, then deliberately hit the spikes to test where you return.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Move CHECKPOINT and check that the pole and the saved spawn position both move.",
    "file": "platformer_checkpoint.gd"
  },
  "patrol": {
    "title": "Platformer lesson 10 · Make an enemy patrol",
    "goal": "Time a jump over the spinning saw and reach the trophy.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Change the patrol speed and test the timing at both endpoints.",
    "file": "platformer_patrol.gd"
  },
  "moving-platforms": {
    "title": "Platformer lesson 11 · Ride a moving platform",
    "goal": "Ride the wooden platform across the gap, then jump off onto the far side.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Double the cycle time and compare how long the player waits for the platform.",
    "file": "platformer_moving.gd"
  },
  "coin-gate": {
    "title": "Platformer lesson 12 · Unlock the exit with coins",
    "goal": "Collect all three coins, jump past the hazards, and reach the trophy.",
    "controls": "Left and Right to move, Space to jump, R to restart.",
    "task": "Change REQUIRED_COINS to 2 and test both sides of the new threshold.",
    "file": "platformer_coin_gate.gd"
  },
};
const platformer3DLessons = {
  "walk-3d": {
    "title": "Platformer lesson 1 · Steer a 3D character",
    "goal": "Steer around the brick barrier.",
    "controls": "Left and Right to turn, Up and Down to move, R to restart.",
    "task": "Change TURN_RATE and compare turning in place.",
    "file": "platform3d_walk.gd"
  },
  "fall-3d": {
    "title": "Platformer lesson 2 · Fall and land in 3D",
    "goal": "Compare the initial drop at two gravity values.",
    "controls": "Left and Right to turn, Up and Down to move, R to restart.",
    "task": "Halve GRAVITY and compare the time taken to land.",
    "file": "platform3d_fall.gd"
  },
  "jump-3d": {
    "title": "Platformer lesson 3 · Jump over a 3D obstacle",
    "goal": "Clear the low brick wall with a grounded jump.",
    "controls": "Left and Right to turn, Up and Down to move, Space to jump, R to restart.",
    "task": "Try JUMP_SPEED at 3 and 5.9 and compare the result at the same obstacle.",
    "file": "platform3d_jump.gd"
  },
  "cameras-3d": {
    "title": "Platformer lesson 4 · Switch between first and third person",
    "goal": "Press C to switch views, then jump and turn in both.",
    "controls": "Left and Right to turn, Up and Down to move, Space to jump, C to switch camera, R to restart.",
    "task": "Make the scene start in first person, then use C to switch back.",
    "file": "platform3d_cameras.gd"
  },
  "goal-3d": {
    "title": "Platformer lesson 5 · Finish a 3D obstacle course",
    "goal": "Jump the gap and reach the finish pad between the flags.",
    "controls": "Left and Right to turn, Up and Down to move, Space to jump, C to switch camera, R to restart.",
    "task": "Change the finish message and test a successful run in either view.",
    "file": "platform3d_goal.gd"
  },
};
const racingLessons = {
  "fixed-track": {
    "title": "Racing lesson 1 · Drive two cars on one track",
    "goal": "Drive both cars round the curved circuit. A fixed camera looks down at the whole track from an angle.",
    "controls": "Orange uses arrows. Green uses WASD. Up or W drives forward. Down or S reverses. Left and Right or A and D steer. R restarts.",
    "task": "Swap the two bodies in the drive calls, then test which keys control which car.",
    "file": "racing_fixed.gd"
  },
  "shared-camera": {
    "title": "Racing lesson 2 · Pan and zoom to keep both cars visible",
    "goal": "Separate the cars to make the camera pull back, then bring them together again.",
    "controls": "Orange uses arrows and Green uses WASD. Up or W drives forward. Down or S reverses. Left and Right or A and D steer. R restarts.",
    "task": "Change FRAME_MARGIN and test cars separated across the width and along the depth of the track.",
    "file": "racing_shared_camera.gd"
  },
  "laps": {
    "title": "Racing lesson 3 · Count laps and decide who wins",
    "goal": "Race clockwise. Pass the three green strips in order, then cross the chequered line. First to two laps wins.",
    "controls": "Orange uses arrows. Green uses WASD. Up or W drives forward. Down or S reverses. Left and Right or A and D steer. R restarts.",
    "task": "Change LAPS_TO_WIN to 1, then test the ordered checkpoint rule.",
    "file": "racing_laps.gd"
  },
};
const artLessons = {
  "sprites-2d": {
    "title": "Animation lesson 1 · Import and play a 2D sprite sheet",
    "goal": "Watch the Ninja Frog switch from idle to run and face the direction of travel.",
    "controls": "Left and Right to run. Release to idle. R to restart.",
    "task": "Change RUN_FPS, then compare animation speed and travel speed.",
    "file": "art_sprite_2d.gd"
  },
  "characters-3d": {
    "title": "Animation lesson 2 · Import and animate a 3D character",
    "goal": "Make the knight walk and return to idle. Watch the pose blend when you release a key.",
    "controls": "Left and Right to walk. Release to idle. R to restart.",
    "task": "Change the playback rate, then swap the Walking clip for Run.",
    "file": "art_character_3d.gd"
  },
};
const lessonCourses = {
  platformer: {path: "platformer", lessons: platformerLessons},
  "movement-3d": {path: "platformer-3d", lessons: platformer3DLessons},
  racing: {path: "racing", lessons: racingLessons},
  animation: {path: "animation", lessons: artLessons},
};
const course = Object.hasOwn(lessonCourses, requested) ? lessonCourses[requested] : null;
const lesson = course && Object.hasOwn(course.lessons, params.get("lesson"))
  ? params.get("lesson") : null;
const key = Object.hasOwn(playgrounds, requested) ? requested : "top-down";
const demo = lesson ? course.lessons[lesson] : playgrounds[key];
if (lesson) {
  const link = document.querySelector("#lesson-back");
  link.href = `../${course.path}/${lesson}.html`;
  link.hidden = false;
}
document.querySelector("#demo-title").textContent = demo.title;
document.querySelector("#goal").textContent = demo.goal;
document.querySelector("#controls").textContent = demo.controls + " Click the game to give it keyboard focus.";
document.querySelector("#task").textContent = demo.task;
document.querySelector(`nav a[href="?demo=${key}"]`).setAttribute("aria-current", "page");

if (lesson && params.get("embed") === "1" && window.parent !== window) {
  document.documentElement.classList.add("embedded-lesson");
}

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
  preview.src = "preview.html?v=platformer-1";
  frame = preview;
  const code = source.value;
  preview.addEventListener("load", () => {
    if (preview === frame) preview.contentWindow.postMessage({type: "run-playground", key, code, lesson}, "*");
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

fetch(`source/${demo.file}?v=${lesson ?? "editable-1"}`)
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
