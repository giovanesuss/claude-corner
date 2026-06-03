// TEST: standalone .js entry (no HTML file)
// The viewer wraps this in its canvas boilerplate via wrapAnimation()
// canvas, ctx, and _resize() are injected by the wrapper

let particles = [];
for (let i = 0; i < 60; i++) {
  particles.push({
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    vx: (Math.random() - 0.5) * 1.5,
    vy: (Math.random() - 0.5) * 1.5,
    r: Math.random() * 3 + 1,
    hue: Math.random() * 360,
  });
}

function draw() {
  ctx.fillStyle = 'rgba(25, 23, 20, 0.2)';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  for (const p of particles) {
    p.x += p.vx;
    p.y += p.vy;
    if (p.x < 0 || p.x > canvas.width)  p.vx *= -1;
    if (p.y < 0 || p.y > canvas.height) p.vy *= -1;
    p.hue = (p.hue + 0.3) % 360;

    ctx.beginPath();
    ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
    ctx.fillStyle = `hsla(${p.hue}, 70%, 65%, 0.9)`;
    ctx.fill();
  }

  requestAnimationFrame(draw);
}
draw();
