// TEST: .ts entry — exercises the 'code' render mode (highlight.js, language: typescript)

interface Particle {
  x: number;
  y: number;
  hue: number;
}

function spawn(count: number): Particle[] {
  const particles: Particle[] = [];
  for (let i = 0; i < count; i++) {
    particles.push({ x: Math.random(), y: Math.random(), hue: i * 7 % 360 });
  }
  return particles;
}

const particles = spawn(5);
console.log(`Spawned ${particles.length} particles`);
