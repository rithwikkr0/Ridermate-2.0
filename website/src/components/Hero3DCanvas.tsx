import React, { useRef, useMemo, useEffect } from 'react';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { Sphere, Box, Torus, MeshDistortMaterial, Float, Stars } from '@react-three/drei';
import * as THREE from 'three';

/* ─── Particle Field ─── */
function Particles({ count = 800 }) {
  const meshRef = useRef<THREE.Points>(null);

  const [positions, colors] = useMemo(() => {
    const positions = new Float32Array(count * 3);
    const colors = new Float32Array(count * 3);
    for (let i = 0; i < count; i++) {
      const r = 12 + Math.random() * 8;
      const theta = Math.random() * Math.PI * 2;
      const phi = Math.acos(2 * Math.random() - 1);
      positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
      positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta) * 0.4;
      positions[i * 3 + 2] = r * Math.cos(phi);

      const t = Math.random();
      // Gradient: orange to white
      colors[i * 3] = 1.0;
      colors[i * 3 + 1] = 0.42 + t * 0.58;
      colors[i * 3 + 2] = t * 0.3;
    }
    return [positions, colors];
  }, [count]);

  useFrame((state) => {
    if (!meshRef.current) return;
    meshRef.current.rotation.y = state.clock.elapsedTime * 0.04;
    meshRef.current.rotation.x = Math.sin(state.clock.elapsedTime * 0.02) * 0.1;
  });

  return (
    <points ref={meshRef}>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" args={[positions, 3]} />
        <bufferAttribute attach="attributes-color" args={[colors, 3]} />
      </bufferGeometry>
      <pointsMaterial size={0.06} vertexColors transparent opacity={0.75} sizeAttenuation />
    </points>
  );
}

/* ─── Glowing Ring ─── */
function GlowRing({ radius, tube, speed, color }: {
  radius: number; tube: number; speed: number; color: string;
}) {
  const meshRef = useRef<THREE.Mesh>(null);
  useFrame((state) => {
    if (!meshRef.current) return;
    meshRef.current.rotation.x = state.clock.elapsedTime * speed * 0.7;
    meshRef.current.rotation.z = state.clock.elapsedTime * speed;
  });

  return (
    <Torus ref={meshRef} args={[radius, tube, 2, 80]}>
      <meshBasicMaterial color={color} wireframe />
    </Torus>
  );
}

/* ─── Floating Geometric Cockpit ─── */
function CockpitGeometry() {
  const groupRef = useRef<THREE.Group>(null);
  useFrame((state) => {
    if (!groupRef.current) return;
    groupRef.current.rotation.y = state.clock.elapsedTime * 0.3;
    groupRef.current.position.y = Math.sin(state.clock.elapsedTime * 0.8) * 0.3;
  });

  return (
    <group ref={groupRef} position={[0, 0, 0]}>
      {/* Central sphere - distorted, glowing */}
      <Sphere args={[1.4, 64, 64]}>
        <MeshDistortMaterial
          color="#FF6B00"
          emissive="#FF3300"
          emissiveIntensity={0.5}
          distort={0.4}
          speed={3}
          roughness={0.1}
          metalness={0.9}
          transparent
          opacity={0.85}
        />
      </Sphere>

      {/* Inner wireframe icosahedron */}
      <mesh>
        <icosahedronGeometry args={[1.7, 1]} />
        <meshBasicMaterial color="#FF6B00" wireframe transparent opacity={0.15} />
      </mesh>

      {/* Orbiting small spheres */}
      {[0, 1, 2, 3].map((i) => (
        <OrbitingDot key={i} angle={(i / 4) * Math.PI * 2} radius={2.5} speed={0.5 + i * 0.1} />
      ))}
    </group>
  );
}

function OrbitingDot({ angle, radius, speed }: { angle: number; radius: number; speed: number }) {
  const meshRef = useRef<THREE.Mesh>(null);
  useFrame((state) => {
    if (!meshRef.current) return;
    const t = state.clock.elapsedTime * speed + angle;
    meshRef.current.position.x = Math.cos(t) * radius;
    meshRef.current.position.z = Math.sin(t) * radius * 0.4;
    meshRef.current.position.y = Math.sin(t * 0.7) * 0.5;
  });
  return (
    <mesh ref={meshRef}>
      <sphereGeometry args={[0.08, 8, 8]} />
      <meshBasicMaterial color="#FF8833" />
    </mesh>
  );
}

/* ─── Grid Floor ─── */
function GridFloor() {
  const linesRef = useRef<THREE.LineSegments>(null);
  useFrame((state) => {
    if (!linesRef.current) return;
    linesRef.current.position.z = (state.clock.elapsedTime * 1.5) % 2;
  });

  const geometry = useMemo(() => {
    const geo = new THREE.BufferGeometry();
    const verts: number[] = [];
    const size = 20;
    const divisions = 20;
    const step = size / divisions;

    for (let i = -size / 2; i <= size / 2; i += step) {
      // x lines
      verts.push(i, -3, -size / 2);
      verts.push(i, -3, size / 2);
      // z lines
      verts.push(-size / 2, -3, i);
      verts.push(size / 2, -3, i);
    }
    geo.setAttribute('position', new THREE.Float32BufferAttribute(verts, 3));
    return geo;
  }, []);

  return (
    <lineSegments ref={linesRef} geometry={geometry}>
      <lineBasicMaterial color="#FF6B00" transparent opacity={0.08} />
    </lineSegments>
  );
}

/* ─── Mouse Parallax Camera ─── */
function ParallaxCamera() {
  const { camera } = useThree();
  const mouse = useRef({ x: 0, y: 0 });

  useEffect(() => {
    const onMove = (e: MouseEvent) => {
      mouse.current.x = (e.clientX / window.innerWidth - 0.5) * 2;
      mouse.current.y = -(e.clientY / window.innerHeight - 0.5) * 2;
    };
    window.addEventListener('mousemove', onMove);
    return () => window.removeEventListener('mousemove', onMove);
  }, []);

  useFrame(() => {
    camera.position.x += (mouse.current.x * 1.5 - camera.position.x) * 0.04;
    camera.position.y += (mouse.current.y * 0.8 + 1 - camera.position.y) * 0.04;
    camera.lookAt(0, 0, 0);
  });

  return null;
}

/* ─── Main Canvas Export ─── */
export const Hero3DCanvas: React.FC = () => {
  return (
    <div className="absolute inset-0 z-0">
      <Canvas
        camera={{ position: [0, 1, 7], fov: 60 }}
        gl={{ antialias: true, alpha: true }}
        dpr={[1, 1.5]}
        style={{ background: 'transparent' }}
      >
        <ambientLight intensity={0.2} />
        <pointLight position={[5, 5, 5]} intensity={1.5} color="#FF6B00" />
        <pointLight position={[-5, -5, -5]} intensity={0.5} color="#FF8833" />
        <directionalLight position={[0, 10, 5]} intensity={0.3} />

        <ParallaxCamera />

        <Stars radius={80} depth={50} count={2000} factor={3} saturation={0} fade speed={0.5} />
        <Particles count={700} />
        <GlowRing radius={3.5} tube={0.008} speed={0.15} color="#FF6B00" />
        <GlowRing radius={4.5} tube={0.006} speed={-0.1} color="#FF8833" />
        <GlowRing radius={5.5} tube={0.004} speed={0.08} color="#993D00" />
        <Float speed={1.5} rotationIntensity={0.3} floatIntensity={0.5}>
          <CockpitGeometry />
        </Float>
        <GridFloor />
      </Canvas>
    </div>
  );
};
