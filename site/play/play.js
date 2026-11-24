const playgrounds = {
  "top-down": {
    title: "Crystal trail",
    goal: "Collect all three crystals, then reach the exit. Walk around the walls.",
    controls: "Arrow keys to move. R to restart.",
    task: "Find the line that gives the player a velocity. Predict what happens if you halve SPEED. Change it in Godot, then test diagonals and check that the walls still stop the player.",
    file: "top_down.gd",
    end: "\n\n\tfor index",
  },
  platformer: {
    title: "Sky steps",
    goal: "Jump across the gaps and reach the green marker on the final platform.",
    controls: "Left and Right to move, Space to jump, and R to restart.",
    task: "Predict how changing JUMP_SPEED affects which platforms you can reach. Change it in Godot and test the same gap twice. Explain why the floor check prevents a second jump in mid-air.",
    file: "platformer.gd",
    end: "\n\n\tif player.position",
  },
  "movement-3d": {
    title: "Landing pad",
    goal: "Guide the yellow character around the obstacles to the green landing pad.",
    controls: "Arrow keys to move. R to restart.",
    task: "Find the lines that map input to the x and z axes. Predict what happens if you negate direction.y in the z assignment, then try that change in Godot.",
    file: "movement_3d.gd",
    end: "\n\nfunc move_player",
  },
  "physics-3d": {
    title: "Ramp and crates",
    goal: "Release the ball and observe how gravity, the ramp and the collisions move the crates.",
    controls: "Space to release the ball. R to reset the simulation.",
    task: "Predict what happens if you double ball.mass while keeping IMPULSE the same. Change one value at a time in Godot and compare how the ball and crates move after release.",
    file: "physics_3d.gd",
  },
  "landing-pad-follow": {
    title: "Landing Pad with a follow camera",
    goal: "Turn towards the green landing pad and steer around the obstacles. The camera stays behind your character.",
    controls: "Left and Right to turn. Up to move forward, Down to reverse, and R to restart.",
    task: "Compare this version with the original Landing Pad. Find how the code turns the character and uses its local forward direction. Predict what halving TURN_SPEED will change, then test it in Godot.",
    file: "landing_pad_follow.gd",
    version: "?v=follow-camera",
  },
};

const requested = new URL(location.href).searchParams.get("demo");
const key = Object.hasOwn(playgrounds, requested) ? requested : "top-down";
const demo = playgrounds[key];
document.querySelector("#demo-title").textContent = demo.title;
document.querySelector("#goal").textContent = demo.goal;
document.querySelector("#controls").textContent = demo.controls + " Click the game to return keyboard focus.";
document.querySelector("#task").textContent = demo.task;
document.querySelector(`nav a[href="?demo=${key}"]`).setAttribute("aria-current", "page");

const source = document.querySelector("#source");
const snippet = document.querySelector("#snippet");
fetch(`source/${demo.file}${demo.version ?? ""}`)
  .then((response) => {
    if (!response.ok) throw new Error("Could not load the script.");
    return response.text();
  })
  .then((code) => {
    source.textContent = code;
    const movement = code.slice(code.indexOf("func _physics_process"));
    snippet.textContent = demo.end ? movement.split(demo.end)[0] : movement.trimEnd();
  })
  .catch((error) => {
    source.textContent = snippet.textContent = error.message;
  });

const start = document.querySelector("#start");
const canvas = document.querySelector("#game");
const status = document.querySelector("#load-status");
start.addEventListener("click", async () => {
  start.disabled = true;
  status.textContent = "Loading Godot…";
  try {
    if (typeof Engine === "undefined" || !Engine.isWebGLAvailable(2)) {
      throw new Error("These demos need a browser with WebGL 2 enabled.");
    }
    const engine = new Engine({
      executable: "godot",
      mainPack: "playgrounds.pck",
      canvas,
      canvasResizePolicy: 0,
      args: ["--", key],
    });
    canvas.width = 768;
    canvas.height = 432;
    canvas.hidden = false;
    start.hidden = true;
    if (demo.version) {
      await engine.preloadFile(`playgrounds.pck${demo.version}`, "playgrounds.pck");
      await engine.init("godot");
      await engine.start({args: ["--main-pack", "playgrounds.pck", "--", key]});
    } else {
      await engine.startGame();
    }
    canvas.focus();
    status.textContent = "Game ready. Press the keys shown above.";
  } catch (error) {
    canvas.hidden = true;
    start.hidden = false;
    start.disabled = false;
    status.textContent = error.message;
  }
});
