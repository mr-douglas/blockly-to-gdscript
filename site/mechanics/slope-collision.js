import {arrow, fmt, g, line} from "./lab.js";

const sin = 0.28;
const cos = Math.sqrt(1 - sin ** 2);
const frictionCoefficient = 0.5;
const massP = 0.3;
const massQ = 0.6;
const gap = 2.75;
const launchSpeed = 6;
const reboundVelocity = -1;
const downAcceleration = g * (sin - frictionCoefficient * cos);
const upAcceleration = g * (sin + frictionCoefficient * cos);
const impactSpeed = Math.sqrt(launchSpeed ** 2 + 2 * downAcceleration * gap);
const impactTime = (impactSpeed - launchSpeed) / downAcceleration;
const qVelocity = massP * (impactSpeed - reboundVelocity) / massQ;
const pStop = -reboundVelocity / upAcceleration;
const qStop = -qVelocity / downAcceleration;
const endTime = impactTime + qStop;

function afterImpact(velocity, acceleration, stop, elapsed) {
  const movingTime = Math.min(elapsed, stop);
  return {
    position: gap + velocity * movingTime + 0.5 * acceleration * movingTime ** 2,
    velocity: elapsed < stop ? velocity + acceleration * elapsed : 0,
    acceleration: elapsed < stop ? acceleration : 0,
  };
}

export function situation(stage, time = 0) {
  if (stage === "release") {
    return {
      label: "Released from rest",
      p: {position: 0, velocity: 0, acceleration: 0},
      q: {position: gap, velocity: 0, acceleration: 0},
    };
  }
  if (stage === "before" || time < impactTime - 1e-10) {
    const t = stage === "before" ? impactTime : time;
    return {
      label: stage === "before" ? "Immediately before impact" : "P moving down towards Q",
      p: {
        position: launchSpeed * t + 0.5 * downAcceleration * t ** 2,
        velocity: launchSpeed + downAcceleration * t,
        acceleration: downAcceleration,
      },
      q: {position: gap, velocity: 0, acceleration: 0},
    };
  }
  const elapsed = Math.max(0, time - impactTime);
  return {
    label: stage === "after" || elapsed < 1e-10 ? "Immediately after impact"
      : time >= endTime - 1e-10 ? "Both particles at rest"
      : elapsed >= pStop ? "P at rest; Q still moving down" : "P rebounds up while Q moves down",
    p: afterImpact(reboundVelocity, upAcceleration, pStop, elapsed),
    q: afterImpact(qVelocity, downAcceleration, qStop, time >= endTime - 1e-10 ? qStop : elapsed),
  };
}

function draw(ctx, {p, q}) {
  ctx.fillStyle = "#132945";
  ctx.fillRect(0, 0, 720, 350);
  ctx.textBaseline = "middle";
  const at = (s, offset = 0) => [92 + s * 102 * cos + offset * sin, 118 + s * 102 * sin - offset * cos];
  line(ctx, "#759aba", [at(-0.6), at(6.2)], 5);
  line(ctx, "#47657f", [at(-0.6), [at(-0.6)[0], at(6.2)[1]], at(6.2)], 2);
  for (const s of [0, gap]) {
    line(ctx, "#9db8ce", [at(s, -6), at(s, 6)], 2);
    ctx.fillStyle = "#c8deef";
    ctx.font = "15px system-ui";
    ctx.textAlign = "center";
    ctx.fillText(`${s} m`, ...at(s, -27));
  }
  const apart = Math.max(0, q.position - p.position);
  const lift = apart < 0.85 ? 43 * (1 - apart / 0.85) : 0;
  for (const [name, particle, color, offset] of [
    ["P", p, "#7ee0d5", 22 + lift],
    ["Q", q, "#ffbd77", 22],
  ]) {
    const center = at(particle.position, offset);
    line(ctx, color, [at(particle.position), center], 1.5);
    ctx.beginPath();
    ctx.arc(...center, 16, 0, 2 * Math.PI);
    ctx.fillStyle = color;
    ctx.fill();
    ctx.fillStyle = "#132945";
    ctx.font = "bold 16px system-ui";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText(name, ...center);
    if (Math.abs(particle.velocity) > 1e-8) {
      const [x, y] = at(particle.position, offset + 21);
      const length = Math.sign(particle.velocity) * (18 + 8 * Math.abs(particle.velocity));
      arrow(ctx, x, y, length * cos, length * sin, color);
    }
  }
  if (apart > 0.15) {
    const offset = -64;
    line(ctx, "#a5c6e5", [at(p.position, offset), at(q.position, offset)], 2);
    for (const s of [p.position, q.position]) line(ctx, "#a5c6e5", [at(s, offset - 6), at(s, offset + 6)], 2);
    ctx.fillStyle = "#e4f2ff";
    ctx.font = "bold 18px system-ui";
    ctx.fillText(`${fmt(apart)} m`, ...at((p.position + q.position) / 2, offset - 20));
  }
}

if (typeof document !== "undefined") {
  const demo = document.querySelector("[data-demo]");
  const canvas = demo.querySelector("canvas");
  const ctx = canvas.getContext("2d");
  const slider = demo.querySelector("#time");
  const readout = demo.querySelector("#readout");
  const play = demo.querySelector("#play");
  const tabButtons = [...demo.querySelectorAll("[data-stage]")];
  let stage = "release";
  let elapsed = 0;
  let start = null;
  let frame;

  function show() {
    const state = situation(stage, elapsed);
    draw(ctx, state);
    slider.value = elapsed;
    readout.textContent = stage === "release" ? "Before projection" : `${elapsed.toFixed(2)} s after projection`;
    demo.querySelector("#phase").textContent = state.label;
    demo.querySelector("#gap").textContent = `${fmt(Math.max(0, state.q.position - state.p.position))} m`;
    for (const [name, mass] of [["p", massP], ["q", massQ]]) {
      const particle = state[name];
      const friction = particle.acceleration === 0
        ? -mass * g * sin
        : -Math.sign(particle.velocity) * frictionCoefficient * mass * g * cos;
      const row = demo.querySelector(`[data-particle="${name}"]`);
      const values = [particle.velocity, particle.acceleration, friction];
      row.querySelectorAll("[data-value]").forEach((cell, index) => cell.textContent = fmt(values[index]));
    }
    for (const button of tabButtons) {
      button.setAttribute("aria-pressed", String(button.dataset.stage === stage));
    }
  }

  function pause() {
    cancelAnimationFrame(frame);
    start = null;
    play.textContent = "Play motion";
  }

  function animate(timestamp) {
    start ??= timestamp - elapsed * 1750;
    elapsed = Math.min(endTime, (timestamp - start) / 1750);
    show();
    if (elapsed < endTime) frame = requestAnimationFrame(animate);
    else pause();
  }

  play.addEventListener("click", () => {
    if (play.textContent === "Pause") {
      pause();
      return;
    }
    if (stage === "release" || elapsed >= endTime) elapsed = 0;
    stage = "motion";
    play.textContent = "Pause";
    show();
    frame = requestAnimationFrame(animate);
  });

  for (const button of tabButtons) button.addEventListener("click", () => {
    pause();
    stage = button.dataset.stage;
    elapsed = stage === "before" || stage === "after" ? impactTime : stage === "rest" ? endTime : 0;
    show();
  });
  slider.addEventListener("input", () => {
    pause();
    stage = "motion";
    elapsed = slider.valueAsNumber;
    show();
  });
  show();
}
