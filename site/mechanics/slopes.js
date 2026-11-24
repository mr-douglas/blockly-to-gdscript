import {fmt, g, mountLab} from "./lab.js";
import {drawPlane} from "./plane.js";

function smoothPlane({mass, degrees}, time) {
  const angle = degrees * Math.PI / 180;
  const acceleration = g * Math.sin(angle);
  const reaction = mass * g * Math.cos(angle);
  const displacement = 0.5 * acceleration * time ** 2;
  return {
    angle, degrees, mass, displacement,
    results: `Down-slope force: ${fmt(mass * acceleration)} N · Normal reaction: ${fmt(reaction)} N · Acceleration: ${fmt(acceleration)} m/s² · Speed: ${fmt(acceleration * time)} m/s · Displacement: ${fmt(displacement)} m`,
  };
}

mountLab({model: smoothPlane, draw: drawPlane});
