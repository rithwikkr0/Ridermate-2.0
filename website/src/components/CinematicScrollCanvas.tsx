import React, { useEffect, useRef, useState } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

interface CinematicScrollCanvasProps {
  onProgressUpdate?: (progress: number, speed: number, altitude: number) => void;
}

export const CinematicScrollCanvas: React.FC<CinematicScrollCanvasProps> = ({ onProgressUpdate }) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [reducedMotion, setReducedMotion] = useState(false);

  useEffect(() => {
    // Check user preference for reduced motion
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReducedMotion(mediaQuery.matches);
    const handler = (e: MediaQueryListEvent) => setReducedMotion(e.matches);
    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, []);

  useEffect(() => {
    const canvas = canvasRef.current;
    const container = containerRef.current;
    if (!canvas || !container) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animFrameId: number;
    let currentProgress = 0;
    let targetProgress = 0;
    let currentSpeed = 0;
    let currentAltitude = 1420;

    // Handle high-DPI canvas resolution
    const resizeCanvas = () => {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      const width = container.clientWidth;
      const height = container.clientHeight;
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      ctx.scale(dpr, dpr);
    };

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    // GSAP ScrollTrigger pinning & progress scrub
    const trigger = ScrollTrigger.create({
      trigger: container,
      start: 'top top',
      end: '+=250%',
      pin: true,
      scrub: 0.6,
      onUpdate: (self) => {
        targetProgress = self.progress;
      },
    });

    // Starfield points
    const stars: { x: number; y: number; size: number; alpha: number }[] = [];
    for (let i = 0; i < 90; i++) {
      stars.push({
        x: Math.random(),
        y: Math.random() * 0.45,
        size: Math.random() * 1.5 + 0.5,
        alpha: Math.random() * 0.7 + 0.3,
      });
    }

    // Render loop
    const render = () => {
      const width = container.clientWidth;
      const height = container.clientHeight;

      // Linear interpolation for silky 60fps smoothing
      currentProgress += (targetProgress - currentProgress) * 0.08;
      
      // Calculate dynamic physics telemetry based on scroll
      currentSpeed = Math.round(currentProgress * 128); // 0 to 128 km/h
      currentAltitude = Math.round(1420 + currentProgress * 1420); // 1420m to 2840m
      const leanAngle = Math.sin(currentProgress * Math.PI * 4) * 28; // Lean left/right

      if (onProgressUpdate) {
        onProgressUpdate(currentProgress, currentSpeed, currentAltitude);
      }

      ctx.clearRect(0, 0, width, height);

      // ── 1. Sky & Atmosphere Background ─────────────────────────────────
      const skyGradient = ctx.createLinearGradient(0, 0, 0, height * 0.55);
      skyGradient.addColorStop(0, '#060709');
      skyGradient.addColorStop(0.6, '#0B0D13');
      skyGradient.addColorStop(1, '#151922');
      ctx.fillStyle = skyGradient;
      ctx.fillRect(0, 0, width, height * 0.55);

      // Starfield
      ctx.fillStyle = '#FFFFFF';
      stars.forEach((s) => {
        ctx.globalAlpha = s.alpha * (1 - currentProgress * 0.3);
        ctx.beginPath();
        ctx.arc(s.x * width, s.y * height, s.size, 0, Math.PI * 2);
        ctx.fill();
      });
      ctx.globalAlpha = 1.0;

      // ── 2. Distant Mountain Silhouettes ─────────────────────────────────
      const mountainVanishingY = height * 0.46;
      ctx.fillStyle = '#0F1219';
      ctx.beginPath();
      ctx.moveTo(0, mountainVanishingY);
      for (let x = 0; x <= width; x += 30) {
        const peak = Math.sin(x * 0.008 + currentProgress * 2) * 35 +
                     Math.cos(x * 0.015 - currentProgress * 1.5) * 20;
        ctx.lineTo(x, mountainVanishingY - 40 + peak);
      }
      ctx.lineTo(width, height);
      ctx.lineTo(0, height);
      ctx.closePath();
      ctx.fill();

      // ── 3. Ground / Valley Plane ─────────────────────────────────────────
      const groundGradient = ctx.createLinearGradient(0, mountainVanishingY, 0, height);
      groundGradient.addColorStop(0, '#10131A');
      groundGradient.addColorStop(1, '#08090C');
      ctx.fillStyle = groundGradient;
      ctx.fillRect(0, mountainVanishingY, width, height - mountainVanishingY);

      // ── 4. Dynamic Perspective Highway ──────────────────────────────────
      const horizonY = mountainVanishingY + 10;
      const roadCenterHorizon = width * 0.5 + Math.sin(currentProgress * Math.PI * 3) * (width * 0.25);
      const roadCenterBottom = width * 0.5 + (leanAngle * -1.5);
      const roadTopWidth = width * 0.08;
      const roadBottomWidth = width * 0.85;

      // Road Surface
      ctx.beginPath();
      ctx.moveTo(roadCenterHorizon - roadTopWidth / 2, horizonY);
      ctx.lineTo(roadCenterHorizon + roadTopWidth / 2, horizonY);
      ctx.lineTo(roadCenterBottom + roadBottomWidth / 2, height);
      ctx.lineTo(roadCenterBottom - roadBottomWidth / 2, height);
      ctx.closePath();

      const roadGradient = ctx.createLinearGradient(0, horizonY, 0, height);
      roadGradient.addColorStop(0, '#161922');
      roadGradient.addColorStop(0.5, '#12141A');
      roadGradient.addColorStop(1, '#0C0E12');
      ctx.fillStyle = roadGradient;
      ctx.fill();

      // Road Neon Borders (Circuit Orange `#FF6B00`)
      ctx.lineWidth = 2.5;
      ctx.strokeStyle = '#FF6B00';
      ctx.shadowColor = '#FF6B00';
      ctx.shadowBlur = 12;

      // Left Border
      ctx.beginPath();
      ctx.moveTo(roadCenterHorizon - roadTopWidth / 2, horizonY);
      ctx.lineTo(roadCenterBottom - roadBottomWidth / 2, height);
      ctx.stroke();

      // Right Border
      ctx.beginPath();
      ctx.moveTo(roadCenterHorizon + roadTopWidth / 2, horizonY);
      ctx.lineTo(roadCenterBottom + roadBottomWidth / 2, height);
      ctx.stroke();

      // ── 5. Dashed Animated Centerline ────────────────────────────────────
      ctx.shadowBlur = 8;
      ctx.strokeStyle = '#FF8833';
      ctx.lineWidth = 3;

      const segments = 14;
      for (let i = 0; i < segments; i++) {
        const segOffset = (i / segments + (currentProgress * 6) % 1) % 1;
        const t1 = Math.pow(segOffset, 2);
        const t2 = Math.pow(Math.min(segOffset + 0.04, 1), 2);

        const x1 = roadCenterHorizon + (roadCenterBottom - roadCenterHorizon) * t1;
        const y1 = horizonY + (height - horizonY) * t1;
        const x2 = roadCenterHorizon + (roadCenterBottom - roadCenterHorizon) * t2;
        const y2 = horizonY + (height - horizonY) * t2;

        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.stroke();
      }

      ctx.shadowBlur = 0; // Reset shadow

      // ── 6. Cockpit HUD Telemetry Overlay (Bottom Screen) ────────────────
      const hudY = height - 110;
      const hudCenterX = width * 0.5;

      // Speed Ring Glow
      ctx.strokeStyle = 'rgba(255, 107, 0, 0.4)';
      ctx.lineWidth = 4;
      ctx.beginPath();
      ctx.arc(hudCenterX, hudY + 40, 60, Math.PI * 0.8, Math.PI * 2.2);
      ctx.stroke();

      // Active Speed Arc
      ctx.strokeStyle = '#FF6B00';
      ctx.lineWidth = 5;
      ctx.shadowColor = '#FF6B00';
      ctx.shadowBlur = 15;
      const speedAngle = Math.PI * 0.8 + (currentSpeed / 140) * Math.PI * 1.4;
      ctx.beginPath();
      ctx.arc(hudCenterX, hudY + 40, 60, Math.PI * 0.8, Math.min(speedAngle, Math.PI * 2.2));
      ctx.stroke();
      ctx.shadowBlur = 0;

      // Cockpit Telemetry Text
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 36px "JetBrains Mono", monospace';
      ctx.textAlign = 'center';
      ctx.fillText(`${currentSpeed}`, hudCenterX, hudY + 45);

      ctx.fillStyle = '#FF6B00';
      ctx.font = '600 11px "JetBrains Mono", monospace';
      ctx.fillText('KM/H', hudCenterX, hudY + 62);

      // Left Telemetry Box: Lean Angle
      ctx.fillStyle = 'rgba(18, 20, 26, 0.85)';
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
      ctx.lineWidth = 1;
      const boxW = 120;
      const boxH = 50;
      const leftBoxX = Math.max(20, hudCenterX - 220);
      ctx.roundRect?.(leftBoxX, hudY + 15, boxW, boxH, 10);
      ctx.fill();
      ctx.stroke();

      ctx.fillStyle = '#9AA0A6';
      ctx.font = '10px "Plus Jakarta Sans", sans-serif';
      ctx.textAlign = 'left';
      ctx.fillText('LEAN ANGLE', leftBoxX + 12, hudY + 32);

      ctx.fillStyle = leanAngle > 15 || leanAngle < -15 ? '#FF6B00' : '#FFFFFF';
      ctx.font = 'bold 15px "JetBrains Mono", monospace';
      ctx.fillText(`${leanAngle >= 0 ? '+' : ''}${leanAngle.toFixed(1)}°`, leftBoxX + 12, hudY + 52);

      // Right Telemetry Box: Altitude Elevation
      const rightBoxX = Math.min(width - boxW - 20, hudCenterX + 100);
      ctx.roundRect?.(rightBoxX, hudY + 15, boxW, boxH, 10);
      ctx.fill();
      ctx.stroke();

      ctx.fillStyle = '#9AA0A6';
      ctx.font = '10px "Plus Jakarta Sans", sans-serif';
      ctx.fillText('ELEVATION', rightBoxX + 12, hudY + 32);

      ctx.fillStyle = '#38BDF8';
      ctx.font = 'bold 15px "JetBrains Mono", monospace';
      ctx.fillText(`${currentAltitude}m`, rightBoxX + 12, hudY + 52);

      animFrameId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animFrameId);
      window.removeEventListener('resize', resizeCanvas);
      trigger.kill();
    };
  }, [reducedMotion, onProgressUpdate]);

  return (
    <div ref={containerRef} className="w-full h-screen relative bg-background overflow-hidden select-none">
      <canvas
        ref={canvasRef}
        className="w-full h-full block"
        aria-label="Interactive motorcycle highway telemetry sequence"
      />

      {/* Floating Guidance Banner */}
      <div className="absolute top-24 left-1/2 -translate-x-1/2 glass-panel px-4 py-2 rounded-full border border-circuitOrange/30 text-xs font-mono text-white flex items-center gap-2 shadow-2xl pointer-events-none">
        <span className="w-2 h-2 rounded-full bg-circuitOrange animate-ping" />
        <span>SCROLL DOWN TO ENGAGE COCKPIT THROTTLE</span>
      </div>
    </div>
  );
};
