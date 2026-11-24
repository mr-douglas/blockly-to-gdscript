import {arrow, block, line} from "./lab.js";

export function drawPlane(ctx, state) {
  const origin = [150, 83];
  const along = [Math.cos(state.angle), Math.sin(state.angle)];
  const normal = [along[1], -along[0]];
  const finish = origin.map((n, i) => n + 410 * along[i]);
  line(ctx, "#547b98", [origin, finish], 7);
  line(ctx, "#547b98", [finish, [origin[0], finish[1]], origin], 2);
  const center = origin.map((n, i) => n + (55 + 72 * state.displacement) * along[i] + 21 * normal[i]);
  ctx.save();
  ctx.translate(...center);
  ctx.rotate(state.angle);
  block(ctx, 0, 0, 69, 36, "#7ee0d5", `${state.mass} kg`);
  ctx.restore();
  if (state.angle > 0) {
    ctx.fillStyle = "#c6ddf0";
    ctx.font = "16px system-ui";
    ctx.textAlign = "right";
    ctx.fillText(`${state.degrees}°`, finish[0] - 40, finish[1] - 11);
  }
  arrow(ctx, center[0] + 15, center[1], 0, 51, "#ffbd77");
  arrow(ctx, center[0] - 9, center[1] - 4, 49 * normal[0], 49 * normal[1], "#b8cfff");
}
