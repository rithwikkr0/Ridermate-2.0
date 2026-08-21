import React, { useEffect, useRef, useState } from 'react';

export const CyberHeroCanvas: React.FC = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [reducedMotion, setReducedMotion] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReducedMotion(mediaQuery.matches);
    const handler = (e: MediaQueryListEvent) => setReducedMotion(e.matches);
    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, []);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animId: number;
    let time = 0;

    const resize = () => {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      const rect = canvas.getBoundingClientRect();
      canvas.width = rect.width * dpr;
      canvas.height = rect.height * dpr;
      ctx.scale(dpr, dpr);
    };

    resize();
    window.addEventListener('resize', resize);

    // Mouse parallax tracking
    let mouseX = 0.5;
    let mouseY = 0.5;
    let targetMouseX = 0.5;
    let targetMouseY = 0.5;

    const handleMouseMove = (e: MouseEvent) => {
      targetMouseX = e.clientX / window.innerWidth;
      targetMouseY = e.clientY / window.innerHeight;
    };
    window.addEventListener('mousemove', handleMouseMove);

    // Generate ambient grid particles
    const particles = Array.from({ length: 60 }, () => ({
      x: Math.random(),
      y: Math.random(),
      z: Math.random() * 2 + 0.5,
      speed: Math.random() * 0.002 + 0.001,
      size: Math.random() * 1.5 + 0.8,
      alpha: Math.random() * 0.5 + 0.2,
    }));

    const render = () => {
      const rect = canvas.getBoundingClientRect();
      const w = rect.width;
      const h = rect.height;

      time += 0.012;
      mouseX += (targetMouseX - mouseX) * 0.05;
      mouseY += (targetMouseY - mouseY) * 0.05;

      ctx.clearRect(0, 0, w, h);

      // ── 1. Cyber Perspective Horizon Grid ──────────────────────────────
      const horizonY = h * 0.52;
      const vanishingX = w * 0.5 + (mouseX - 0.5) * 80;

      // Deep dark background
      const bgGrad = ctx.createLinearGradient(0, 0, 0, h);
      bgGrad.addColorStop(0, '#060709');
      bgGrad.addColorStop(0.5, '#0B0D13');
      bgGrad.addColorStop(1, '#08090C');
      ctx.fillStyle = bgGrad;
      ctx.fillRect(0, 0, w, h);

      // Horizon glow
      const horizonGlow = ctx.createRadialGradient(
        vanishingX, horizonY, 10,
        vanishingX, horizonY, w * 0.6
      );
      horizonGlow.addColorStop(0, 'rgba(255, 107, 0, 0.25)');
      horizonGlow.addColorStop(0.5, 'rgba(255, 107, 0, 0.05)');
      horizonGlow.addColorStop(1, 'transparent');
      ctx.fillStyle = horizonGlow;
      ctx.fillRect(0, 0, w, h);

      // Perspective Grid Lines (Ground)
      ctx.lineWidth = 1;
      const gridLines = 24;
      for (let i = -gridLines / 2; i <= gridLines / 2; i++) {
        const bottomX = w * 0.5 + i * (w / 12) + (mouseX - 0.5) * 120;
        const alpha = Math.max(0, 1 - Math.abs(i) / (gridLines * 0.45));

        ctx.strokeStyle = `rgba(255, 107, 0, ${alpha * 0.25})`;
        ctx.beginPath();
        ctx.moveTo(vanishingX, horizonY);
        ctx.lineTo(bottomX, h);
        ctx.stroke();
      }

      // Moving Horizontal Highway Lines
      const horizCount = 9;
      for (let i = 1; i <= horizCount; i++) {
        const progress = reducedMotion ? (i / horizCount) : ((i / horizCount + time * 0.4) % 1);
        const y = horizonY + Math.pow(progress, 2.2) * (h - horizonY);
        const lineAlpha = Math.pow(progress, 1.5) * 0.35;

        ctx.strokeStyle = `rgba(255, 107, 0, ${lineAlpha})`;
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(w, y);
        ctx.stroke();
      }

      // ── 2. Floating Cyber Particles ─────────────────────────────────────
      particles.forEach((p) => {
        if (!reducedMotion) {
          p.y += p.speed;
          if (p.y > 1) p.y = 0;
        }

        const px = (p.x + (mouseX - 0.5) * 0.08 * p.z) * w;
        const py = p.y * h;

        ctx.fillStyle = '#FF6B00';
        ctx.globalAlpha = p.alpha;
        ctx.beginPath();
        ctx.arc(px, py, p.size, 0, Math.PI * 2);
        ctx.fill();
      });
      ctx.globalAlpha = 1.0;

      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener('resize', resize);
      window.removeEventListener('mousemove', handleMouseMove);
    };
  }, [reducedMotion]);

  return (
    <div className="absolute inset-0 w-full h-full pointer-events-none overflow-hidden select-none">
      <canvas ref={canvasRef} className="w-full h-full block" />
    </div>
  );
};
