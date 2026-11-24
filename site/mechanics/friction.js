import {fmt, g, mountLab} from "./lab.js";
import {drawPlane} from "./plane.js?v=friction";

function roughPlane({mass, degrees, coefficient}, time) {
  const angle = degrees * Math.PI / 180;
  const drivingForce = mass * g * Math.sin(angle);
  const reaction = mass * g * Math.cos(angle);
  const limit = coefficient * reaction;
  const difference = drivingForce - limit;
  const motion = difference > 1e-9 ? "Slides down" : Math.abs(difference) < 1e-9 && drivingForce > 0 ? "Limiting equilibrium" : "At rest";
  const friction = Math.min(drivingForce, limit);
  const acceleration = motion === "Slides down" ? difference / mass : 0;
  return {
    angle, degrees, mass, friction, displacement: 0.5 * acceleration * time ** 2,
    results: `${motion} · Normal reaction: ${fmt(reaction)} N · Friction: ${fmt(friction)} N · Limit μR: ${fmt(limit)} N · Acceleration: ${fmt(acceleration)} m/s²`,
  };
}

mountLab({model: roughPlane, draw: drawPlane});
