import React, { useRef, useMemo, useEffect, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Float, MeshDistortMaterial } from '@react-three/drei';
import * as THREE from 'three';

// Procedural 3D Motorcycle Cockpit & Wireframe Speed Grid
const MotorcycleCockpitScene: React.FC<{ reducedMotion: boolean }> = ({ reducedMotion }) => {
  const ringRef1 = useRef<THREE.Mesh>(null!);
  const ringRef2 = useRef<THREE.Mesh>(null!);
  const coreRef = useRef<THREE.Mesh>(null!);
  const particlesRef = useRef<THREE.Points>(null!);

  // Generate cyber particles
  const particleCount = 120;
  const [positions, colors] = useMemo(() => {
    const pos = new Float32Array(particleCount * 3);
    const col = new Float32Array(particleCount * 3);
    const colorOrange = new THREE.Color('#FF6B00');
    const colorCyan = new THREE.Color('#38BDF8');

    for (let i = 0; i < particleCount; i++) {
      const theta = THREE.MathUtils.randFloatSpread(360);
      const phi = THREE.MathUtils.randFloatSpread(360);
      const radius = 2.2 + Math.random() * 1.5;

      pos[i * 3] = radius * Math.sin(theta) * Math.cos(phi);
      pos[i * 3 + 1] = radius * Math.sin(theta) * Math.sin(phi);
      pos[i * 3 + 2] = radius * Math.cos(theta);

      const mixed = Math.random() > 0.3 ? colorOrange : colorCyan;
      col[i * 3] = mixed.r;
      col[i * 3 + 1] = mixed.g;
      col[i * 3 + 2] = mixed.b;
    }
    return [pos, col];
  }, []);

  useFrame((state, delta) => {
    if (reducedMotion) return;

    if (ringRef1.current) {
      ringRef1.current.rotation.z += delta * 0.4;
      ringRef1.current.rotation.x += delta * 0.15;
    }
    if (ringRef2.current) {
      ringRef2.current.rotation.z -= delta * 0.3;
      ringRef2.current.rotation.y += delta * 0.2;
    }
    if (coreRef.current) {
      coreRef.current.rotation.y += delta * 0.5;
    }
    if (particlesRef.current) {
      particlesRef.current.rotation.y += delta * 0.1;
    }
  });

  return (
    <group>
      {/* Central Cyber Core (Glowing Octahedron telemetry engine) */}
      <Float speed={reducedMotion ? 0 : 2} rotationIntensity={0.4} floatIntensity={0.6}>
        <mesh ref={coreRef}>
          <octahedronGeometry args={[0.9, 0]} />
          <meshStandardMaterial
            color="#FF6B00"
            emissive="#FF4500"
            emissiveIntensity={0.8}
            wireframe
            roughness={0.2}
          />
        </mesh>
      </Float>

      {/* Orbiting Telemetry HUD Ring 1 */}
      <mesh ref={ringRef1} rotation={[Math.PI / 3, 0, 0]}>
        <torusGeometry args={[1.6, 0.02, 16, 64]} />
        <meshBasicMaterial color="#FF6B00" wireframe />
      </mesh>

      {/* Orbiting Telemetry HUD Ring 2 */}
      <mesh ref={ringRef2} rotation={[-Math.PI / 4, Math.PI / 6, 0]}>
        <torusGeometry args={[2.0, 0.015, 16, 64]} />
        <meshBasicMaterial color="#38BDF8" transparent opacity={0.6} />
      </mesh>

      {/* Outer Speed Ring */}
      <mesh rotation={[0, 0, Math.PI / 4]}>
        <ringGeometry args={[2.4, 2.44, 32]} />
        <meshBasicMaterial color="#FF6B00" transparent opacity={0.3} side={THREE.DoubleSide} />
      </mesh>

      {/* Floating telemetry particles */}
      <points ref={particlesRef}>
        <bufferGeometry>
          <bufferAttribute
            attach="attributes-position"
            args={[positions, 3]}
          />
          <bufferAttribute
            attach="attributes-color"
            args={[colors, 3]}
          />
        </bufferGeometry>
        <pointsMaterial
          size={0.05}
          vertexColors
          transparent
          opacity={0.8}
          blending={THREE.AdditiveBlending}
        />
      </points>

      {/* Lights */}
      <ambientLight intensity={0.6} />
      <pointLight position={[10, 10, 10]} intensity={1.5} color="#FF8833" />
      <pointLight position={[-10, -10, -5]} intensity={1.0} color="#38BDF8" />
    </group>
  );
};

export const Hero3D: React.FC = () => {
  const [reducedMotion, setReducedMotion] = useState(false);
  const [isSupported, setIsSupported] = useState(true);

  useEffect(() => {
    // Check user preference for reduced motion
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReducedMotion(mediaQuery.matches);

    const handler = (e: MediaQueryListEvent) => setReducedMotion(e.matches);
    mediaQuery.addEventListener('change', handler);

    // Check WebGL support
    try {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      if (!gl) setIsSupported(false);
    } catch {
      setIsSupported(false);
    }

    return () => mediaQuery.removeEventListener('change', handler);
  }, []);

  if (!isSupported) {
    return (
      <div className="w-full h-full flex items-center justify-center p-8">
        <div className="w-64 h-64 rounded-full bg-gradient-to-tr from-circuitOrange/20 to-blue-500/20 border border-circuitOrange/30 flex items-center justify-center animate-pulse">
          <div className="text-center font-mono text-xs text-circuitOrange">
            [COCKPIT TELEMETRY READY]
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full h-[360px] sm:h-[440px] lg:h-[500px] relative">
      <Canvas
        camera={{ position: [0, 0, 5], fov: 45 }}
        gl={{ alpha: true, antialias: true, powerPreference: 'high-performance' }}
        dpr={[1, 1.5]}
        aria-label="3D interactive visualization of RiderMate telemetry system"
      >
        <MotorcycleCockpitScene reducedMotion={reducedMotion} />
        {!reducedMotion && (
          <OrbitControls
            enableZoom={false}
            enablePan={false}
            autoRotate={false}
            maxPolarAngle={Math.PI / 1.5}
            minPolarAngle={Math.PI / 3}
          />
        )}
      </Canvas>

      {/* Floating HUD Badges */}
      <div className="absolute bottom-4 left-4 glass-panel px-3 py-1.5 rounded-lg border border-white/10 text-[11px] font-mono text-onSurfaceVariant flex items-center gap-2 pointer-events-none">
        <span className="w-2 h-2 rounded-full bg-circuitOrange animate-ping" />
        <span>3D Telemetry HUD: Interactive</span>
      </div>
    </div>
  );
};
