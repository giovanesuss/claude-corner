// TEST: .js entry — exercises the wrapAnimation() contract explicitly:
// self-driven requestAnimationFrame loop + the resize(fn) registration hook.

let cx = canvas.width / 2;
let cy = canvas.height / 2;

resize(() => {
  cx = canvas.width / 2;
  cy = canvas.height / 2;
});

let t = 0;

function draw() {
  ctx.fillStyle = '#191714';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  const r = Math.min(canvas.width, canvas.height) * 0.25;
  ctx.beginPath();
  ctx.arc(cx + Math.cos(t) * r, cy + Math.sin(t) * r, 12, 0, Math.PI * 2);
  ctx.fillStyle = '#D97757';
  ctx.fill();

  t += 0.03;
  requestAnimationFrame(draw);
}

draw();
