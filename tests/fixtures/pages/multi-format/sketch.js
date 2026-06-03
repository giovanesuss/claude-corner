// Lissajous curve — tests JS animation renderer inside a multi-format folder
let t = 0;
const trail = [];

function draw() {
  ctx.fillStyle = 'rgba(25,23,20,0.08)';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  const cx = canvas.width / 2;
  const cy = canvas.height / 2;
  const rx = Math.min(canvas.width, canvas.height) * 0.35;
  const ry = rx;

  const x = cx + rx * Math.sin(3 * t + Math.PI / 4);
  const y = cy + ry * Math.sin(2 * t);

  trail.push({ x, y, age: 0 });
  if (trail.length > 300) trail.shift();

  for (const p of trail) {
    const alpha = 1 - p.age / 300;
    ctx.beginPath();
    ctx.arc(p.x, p.y, 2, 0, Math.PI * 2);
    ctx.fillStyle = `hsla(${200 + p.age * 0.4}, 70%, 65%, ${alpha})`;
    ctx.fill();
    p.age++;
  }

  t += 0.015;
  requestAnimationFrame(draw);
}
draw();
