// TEST: JS file inside multi-file folder
// Should render as animation (canvas wrapper), not raw code
// because EXT_MODE maps .js → 'animation'
// canvas, ctx, and _resize() are pre-wired by the wrapper — don't redeclare them

let t = 0;
function draw() {
  ctx.fillStyle = 'rgba(25, 23, 20, 0.15)';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  const cx = canvas.width / 2;
  const cy = canvas.height / 2;

  for (let i = 0; i < 6; i++) {
    const angle = (i / 6) * Math.PI * 2 + t;
    const r = 80;
    const x = cx + Math.cos(angle) * r;
    const y = cy + Math.sin(angle) * r;
    ctx.beginPath();
    ctx.arc(x, y, 8, 0, Math.PI * 2);
    ctx.fillStyle = `hsl(${(i * 60 + t * 30) % 360}, 70%, 65%)`;
    ctx.fill();
  }

  t += 0.02;
  requestAnimationFrame(draw);
}
draw();
