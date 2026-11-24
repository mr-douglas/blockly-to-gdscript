export const g = 10;

export function fmt(value) {
  return Number(value.toFixed(3)).toString();
}

export function mountLab({model, draw}) {
  const lab = document.querySelector("[data-lab]");
  const fields = [...lab.querySelectorAll("[data-parameter]")];
  const duration = Number(lab.dataset.duration);
  const scrub = lab.querySelector("[data-time]");
  const time = lab.querySelector("[data-time-label]");
  const results = lab.querySelector("[data-results]");
  const canvas = lab.querySelector("canvas");
  const ctx = canvas.getContext("2d");
  const play = lab.querySelector("[data-play]");
  const reset = lab.querySelector("[data-reset]");
  const step = lab.querySelector("[data-step]");
  let elapsed = 0;
  let started = null;
  let frame;
  let observed = false;

  function show() {
    const values = Object.fromEntries(fields.map((field) => {
      const value = field.valueAsNumber;
      field.closest("label").querySelector("output").textContent = fmt(value);
      return [field.name, value];
    }));
    const state = model(values, elapsed);
    scrub.value = elapsed;
    time.textContent = `${elapsed.toFixed(2)} s`;
    ctx.fillStyle = "#132945";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    draw(ctx, state);
    results.textContent = observed ? state.results : "Make a prediction, then run or step through the model.";
  }

  function pause() {
    cancelAnimationFrame(frame);
    started = null;
    play.textContent = "Run";
  }

  function update(timestamp) {
    started ??= timestamp - elapsed * 1000;
    elapsed = Math.min(duration, (timestamp - started) / 1000);
    show();
    if (elapsed < duration) frame = requestAnimationFrame(update);
    else pause();
  }

  play.addEventListener("click", () => {
    if (play.textContent === "Pause") {
      pause();
      return;
    }
    if (elapsed >= duration) elapsed = 0;
    observed = true;
    play.textContent = "Pause";
    frame = requestAnimationFrame(update);
  });
  function setTime(next) {
    pause();
    elapsed = Math.min(duration, next);
    observed = true;
    show();
  }
  step.addEventListener("click", () => setTime(elapsed + 0.25));
  scrub.addEventListener("input", () => setTime(scrub.valueAsNumber));
  reset.addEventListener("click", () => {
    pause();
    elapsed = 0;
    observed = false;
    for (const field of fields) field.value = field.defaultValue;
    show();
  });
  for (const field of fields) field.addEventListener("input", () => {
    pause();
    elapsed = 0;
    observed = false;
    show();
  });
  show();
}

export function line(ctx, color, points, width = 3) {
  ctx.beginPath();
  ctx.strokeStyle = color;
  ctx.lineWidth = width;
  ctx.moveTo(...points[0]);
  for (const point of points.slice(1)) ctx.lineTo(...point);
  ctx.stroke();
}

export function block(ctx, x, y, width, height, color, text) {
  ctx.fillStyle = color;
  ctx.fillRect(x - width / 2, y - height / 2, width, height);
  ctx.fillStyle = "#112541";
  ctx.font = "bold 18px system-ui";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillText(text, x, y);
}

export function arrow(ctx, x, y, dx, dy, color) {
  const angle = Math.atan2(dy, dx);
  const tip = [x + dx, y + dy];
  line(ctx, color, [[x, y], tip]);
  line(ctx, color, [
    [tip[0] - 10 * Math.cos(angle - 0.5), tip[1] - 10 * Math.sin(angle - 0.5)],
    tip,
    [tip[0] - 10 * Math.cos(angle + 0.5), tip[1] - 10 * Math.sin(angle + 0.5)],
  ]);
}
