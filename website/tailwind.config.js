/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#090A0D',
        surface: '#12141A',
        surfaceContainer: '#191C24',
        surfaceContainerHigh: '#20242E',
        glassBorder: 'rgba(255, 255, 255, 0.08)',
        circuitOrange: '#FF6B00',
        circuitOrangeGlow: '#FF8833',
        onSurface: '#F0F2F5',
        onSurfaceVariant: '#9AA0A6',
      },
      fontFamily: {
        sans: ['Plus Jakarta Sans', 'Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      animation: {
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'glow': 'glow 3s ease-in-out infinite alternate',
      },
      keyframes: {
        glow: {
          '0%': { boxShadow: '0 0 20px rgba(255, 107, 0, 0.2)' },
          '100%': { boxShadow: '0 0 40px rgba(255, 107, 0, 0.6)' },
        }
      }
    },
  },
  plugins: [],
}
