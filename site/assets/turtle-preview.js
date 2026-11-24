const pad = {x: 0, y: 0, angle: 0};
const defaultBeacons = [{x: 120, y: 0}, {x: 120, y: 100}, {x: 0, y: 100}];
const marker = "@rover ";
const isNear = (a, b) => Math.hypot(a.x - b.x, a.y - b.y) <= 10;

export function createTurtlePreview(stage) {
  const beacons = stage.dataset.beacons
    ? JSON.parse(stage.dataset.beacons).map(([x, y]) => ({x, y}))
    : defaultBeacons;
  const canvas = stage.querySelector("canvas");
  const summary = stage.querySelector("[data-route-summary]");
  const ctx = canvas.getContext("2d");
  let route = [pad];
  let frame;

  function draw(rover, visited, trail) {
    ctx.fillStyle = "#0c1c30";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.save();
    ctx.translate(144, 92);
    ctx.scale(1.6, 1.6);

    ctx.lineWidth = 0.6;
    ctx.strokeStyle = "#29405b";
    ctx.beginPath();
    for (let x = -80; x <= 200; x += 20) {
      ctx.moveTo(x, -60);
      ctx.lineTo(x, 150);
    }
    for (let y = -60; y <= 150; y += 20) {
      ctx.moveTo(-90, y);
      ctx.lineTo(210, y);
    }
    ctx.stroke();

    ctx.fillStyle = "#afc7e4";
    ctx.font = "10px system-ui";
    ctx.fillText("+x", 186, -9);
    ctx.fillText("+y", -18, 132);
    ctx.fillText("(0, 0)", -13, -21);

    ctx.strokeStyle = "#63c0ff";
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(pad.x, pad.y);
    for (const point of trail) ctx.lineTo(point.x, point.y);
    ctx.lineTo(rover.x, rover.y);
    ctx.stroke();

    ctx.strokeStyle = "#a7d0f3";
    ctx.beginPath();
    ctx.arc(0, 0, 14, 0, Math.PI * 2);
    ctx.stroke();

    for (const [index, beacon] of beacons.entries()) {
      ctx.fillStyle = visited.has(index) ? "#64e8ba" : "#ffc36f";
      ctx.beginPath();
      ctx.moveTo(beacon.x, beacon.y - 9);
      ctx.lineTo(beacon.x + 9, beacon.y);
      ctx.lineTo(beacon.x, beacon.y + 9);
      ctx.lineTo(beacon.x - 9, beacon.y);
      ctx.closePath();
      ctx.fill();
      ctx.fillStyle = "#e6eefb";
      ctx.fillText(String(index + 1), beacon.x + 12, beacon.y + 12);
    }

    ctx.translate(rover.x, rover.y);
    ctx.rotate(rover.angle * Math.PI / 180);
    ctx.fillStyle = "#7897b9";
    for (const y of [-9, 5]) {
      ctx.fillRect(-10, y, 6, 4);
      ctx.fillRect(4, y, 6, 4);
    }
    ctx.fillStyle = "#8ce6fe";
    ctx.fillRect(-12, -6, 22, 12);
    ctx.fillStyle = "#245078";
    ctx.fillRect(-6, -3, 9, 6);
    ctx.fillStyle = "#ffc36f";
    ctx.beginPath();
    ctx.moveTo(16, 0);
    ctx.lineTo(8, 5);
    ctx.lineTo(8, -5);
    ctx.closePath();
    ctx.fill();
    ctx.restore();
  }

  function reset() {
    cancelAnimationFrame(frame);
    route = [pad];
    draw(pad, new Set(), []);
    summary.textContent = `At the landing pad. Facing right. 0 of ${beacons.length} beacons reached.`;
  }

  function play() {
    const visited = new Set();
    const trail = [];
    const stepDuration = matchMedia("(prefers-reduced-motion: reduce)").matches
      ? 0 : Math.min(490, 4500 / Math.max(1, route.length - 1));
    let step = 1;
    let previousTime;

    function show(time) {
      const from = route[step - 1];
      const to = route[step];
      if (!to) {
        const coord = (v) => Math.round(v * 10) / 10 || 0;
        const angle = ((Math.round(from.angle) % 360) + 360) % 360;
        const home = visited.size === beacons.length && isNear(from, pad);
        draw(from, visited, trail);
        summary.textContent = `${home ? "Mission complete! " : ""}Position (${coord(from.x)}, ${coord(from.y)}). Heading ${angle}°. ${visited.size} of ${beacons.length} beacons reached.`;
        return;
      }
      previousTime ??= time;
      const progress = stepDuration ? Math.min(1, (time - previousTime) / stepDuration) : 1;
      if (progress === 1) {
        trail.push(to);
        beacons.forEach((beacon, index) => {
          if (isNear(to, beacon)) visited.add(index);
        });
        step++;
        previousTime = time;
      }
      draw({
        x: from.x + (to.x - from.x) * progress,
        y: from.y + (to.y - from.y) * progress,
        angle: from.angle + (to.angle - from.angle) * progress,
      }, visited, trail);
      frame = requestAnimationFrame(show);
    }

    summary.textContent = "Following the route…";
    frame = requestAnimationFrame(show);
  }

  function capture(text) {
    if (!text.startsWith(marker)) return false;
    const [x, y, angle, ...extra] = text.slice(marker.length).split(" ").map(Number);
    if (!extra.length && [x, y, angle].every((value) => Number.isFinite(value) && Math.abs(value) <= 100000)) {
      route.push({x, y, angle});
    }
    return true;
  }

  function wrap(source) {
    if (/^extends\s/m.test(source)) return source;
    return `extends Node2D

func _ready():
${source.split("\n").map((line) => `    ${line}`).join("\n")}

func forward(pixels: float) -> void:
    move_local_x(pixels)
    _record_rover()

func turn_right(degrees: float) -> void:
    rotation_degrees += degrees
    _record_rover()

func _record_rover() -> void:
    print("@rover ", position.x, " ", position.y, " ", rotation_degrees)
`;
  }

  reset();
  return {reset, play, capture, wrap};
}
