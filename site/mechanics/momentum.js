import {arrow, block, fmt, line, mountLab} from "./lab.js";

const gap = 3;

function collision({a, b, ua, ub}, time) {
  const momentum = a * ua + b * ub;
  const velocity = momentum / (a + b);
  const impact = gap / (ua - ub);
  const joined = time >= impact;
  const position = joined ? ua * impact + velocity * (time - impact) : ua * time;
  return {
    a, b, ua, ub, velocity, joined, position, second: gap + ub * time,
    results: joined
      ? `After impact · Common velocity: ${fmt(velocity)} m/s · Total momentum: ${fmt((a + b) * velocity)} kg·m/s`
      : `Before impact · A velocity: ${fmt(ua)} m/s · B velocity: ${fmt(ub)} m/s · Total momentum: ${fmt(momentum)} kg·m/s`,
  };
}

function draw(ctx, state) {
  const scale = 49;
  const toScreen = (position) => 157 + position * scale;
  line(ctx, "#7298b8", [[20, 230], [700, 230]], 3);
  ctx.fillStyle = "#c6ddf0";
  ctx.font = "15px system-ui";
  ctx.textAlign = "center";
  ctx.textBaseline = "alphabetic";
  for (let metres = -2; metres < 12; metres++) {
    const x = toScreen(metres);
    if (x + 12 > 700) break;
    line(ctx, "#7298b8", [[x, 230], [x, 240]], 2);
    ctx.fillText(`${metres}`, x, 264);
  }
  const x = toScreen(state.position);
  if (state.joined) {
    block(ctx, x, 180, 103, 48, "#a6cdf7", `A + B · ${state.a + state.b} kg`);
    if (state.velocity !== 0) arrow(ctx, x, 131, 10 * state.velocity, 0, "#a6cdf7");
  } else {
    const other = toScreen(state.second);
    block(ctx, x, 180, 50, 48, "#7ee0d5", "A");
    block(ctx, other, 180, 50, 48, "#ffbd77", "B");
    arrow(ctx, x, 131, 10 * state.ua, 0, "#7ee0d5");
    if (state.ub !== 0) arrow(ctx, other, 99, 10 * state.ub, 0, "#ffbd77");
  }
}

mountLab({model: collision, draw});
