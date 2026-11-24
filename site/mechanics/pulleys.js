import {arrow, block, fmt, g, line, mountLab} from "./lab.js";

export function pulley({a, b}, time) {
  const acceleration = g * (b - a) / (a + b);
  const tension = a * (g + acceleration);
  const displacement = 0.5 * acceleration * time ** 2;
  return {
    a, b, acceleration, tension, displacement,
    results: `B acceleration: ${fmt(acceleration)} m/s² · Tension: ${fmt(tension)} N · B velocity: ${fmt(acceleration * time)} m/s · B displacement: ${fmt(displacement)} m`,
  };
}

function draw(ctx, state) {
  const shift = state.displacement * 23;
  ctx.beginPath();
  ctx.arc(360, 95, 56, Math.PI, 0);
  ctx.strokeStyle = "#d4e2f2";
  ctx.lineWidth = 4;
  ctx.stroke();
  ctx.beginPath();
  ctx.arc(360, 95, 48, 0, Math.PI * 2);
  ctx.fillStyle = "#355375";
  ctx.fill();
  const angle = state.displacement * 23 / 56;
  line(ctx, "#8cacc8", [[360 - 39 * Math.cos(angle), 95 - 39 * Math.sin(angle)], [360 + 39 * Math.cos(angle), 95 + 39 * Math.sin(angle)]]);
  for (const [x, y, label, color] of [
    [304, 202 - shift, `A · ${state.a} kg`, "#7ee0d5"],
    [416, 202 + shift, `B · ${state.b} kg`, "#ffbd77"],
  ]) {
    line(ctx, "#d4e2f2", [[x, 95], [x, y]]);
    block(ctx, x, y, 91, 42, color, label);
  }
  if (state.acceleration !== 0) {
    const direction = Math.sign(state.acceleration);
    arrow(ctx, 222, 202 - shift + 23 * direction, 0, -46 * direction, "#7ee0d5");
    arrow(ctx, 500, 202 + shift - 23 * direction, 0, 46 * direction, "#ffbd77");
  }
}

if (typeof document !== "undefined") mountLab({model: pulley, draw});
