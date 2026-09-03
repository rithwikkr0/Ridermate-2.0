import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const outputDir = path.resolve(__dirname, '../public/screenshots');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const chromePath = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const baseStyles = `
  @import url('https://fonts.googleapis.com/css2?family=Hanken+Grotesk:wght@400;600;700;800;900&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@500;700&display=swap');
  
  * { box-sizing: border-box; margin: 0; padding: 0; user-select: none; }
  body {
    width: 1080px;
    height: 2340px;
    background: #07080B;
    color: #FFFFFF;
    font-family: 'Inter', sans-serif;
    overflow: hidden;
    position: relative;
  }
  .hanken { font-family: 'Hanken Grotesk', sans-serif; }
  .mono { font-family: 'JetBrains Mono', monospace; }
  .orange { color: #FF6B00; }
  .bg-orange { background-color: #FF6B00; }
  .border-orange { border-color: #FF6B00; }
  
  /* Status Bar */
  .status-bar {
    height: 90px;
    padding: 0 48px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 26px;
    font-weight: 600;
    color: rgba(255,255,255,0.9);
    z-index: 100;
    position: relative;
  }
  .status-icons { display: flex; gap: 16px; align-items: center; }

  /* Glass Card */
  .glass {
    background: rgba(22, 24, 30, 0.75);
    backdrop-filter: blur(24px);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 28px;
  }
  .glass-orange {
    background: rgba(255, 107, 0, 0.08);
    border: 1px solid rgba(255, 107, 0, 0.25);
    border-radius: 24px;
  }

  /* Bottom Navigation */
  .nav-bar {
    position: absolute;
    bottom: 40px;
    left: 48px;
    right: 48px;
    height: 140px;
    background: rgba(16, 18, 22, 0.92);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 40px;
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding: 0 20px;
    backdrop-filter: blur(30px);
    box-shadow: 0 20px 40px rgba(0,0,0,0.6);
  }
  .nav-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    font-size: 20px;
    font-weight: 600;
    color: rgba(255,255,255,0.45);
  }
  .nav-item.active {
    color: #FF6B00;
  }
  .nav-icon {
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
`;

const screens = [
  {
    name: 'cockpit_dashboard.png',
    html: `<!DOCTYPE html>
    <html>
    <head><style>${baseStyles}</style></head>
    <body>
      <div class="status-bar">
        <span>10:42</span>
        <div class="status-icons">
          <span>5G</span>
          <span>●●●●</span>
          <span>86% ⚡</span>
        </div>
      </div>

      <div style="padding: 20px 48px 180px;">
        <!-- Pilot Header -->
        <div class="glass" style="padding: 28px 36px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 36px;">
          <div style="display: flex; align-items: center; gap: 24px;">
            <div style="width: 76px; height: 76px; border-radius: 50%; background: linear-gradient(135deg, #FF6B00, #FF944D); display: flex; align-items: center; justify-content: center; font-size: 34px; font-weight: 800; border: 3px solid #FF6B00; box-shadow: 0 0 25px rgba(255,107,0,0.5);">RP</div>
            <div>
              <div class="hanken" style="font-size: 32px; font-weight: 800; letter-spacing: -0.5px;">Rithwik Pilot</div>
              <div class="mono orange" style="font-size: 20px; font-weight: 700; margin-top: 4px;">LEVEL 7 • EXPERT RIDER (18,450 XP)</div>
            </div>
          </div>
          <div style="padding: 12px 24px; background: rgba(255,59,48,0.15); border: 1px solid #FF3B30; border-radius: 16px; color: #FF3B30; font-weight: 800; font-size: 20px; letter-spacing: 1px;">SOS READY</div>
        </div>

        <!-- Big Cockpit Circular HUD -->
        <div class="glass" style="padding: 48px; text-align: center; position: relative; margin-bottom: 36px; overflow: hidden; box-shadow: 0 20px 50px rgba(0,0,0,0.5);">
          <div style="position: absolute; top: -100px; left: 50%; transform: translateX(-50%); width: 600px; height: 600px; background: radial-gradient(circle, rgba(255,107,0,0.15) 0%, transparent 70%);"></div>
          
          <div class="mono orange" style="font-size: 22px; font-weight: 700; letter-spacing: 3px; margin-bottom: 20px;">KINETIC COCKPIT HUD</div>

          <!-- Speed Arc Display -->
          <div style="position: relative; width: 480px; height: 480px; margin: 0 auto; border-radius: 50%; border: 6px dashed rgba(255,107,0,0.3); display: flex; flex-direction: column; align-items: center; justify-content: center; box-shadow: inset 0 0 60px rgba(255,107,0,0.15);">
            <div class="hanken" style="font-size: 150px; font-weight: 900; line-height: 1; letter-spacing: -4px; text-shadow: 0 0 40px rgba(255,107,0,0.6);">118</div>
            <div class="mono" style="font-size: 32px; font-weight: 700; color: rgba(255,255,255,0.7); letter-spacing: 2px;">KM / H</div>
            <div class="mono orange" style="font-size: 24px; font-weight: 700; margin-top: 14px;">GEAR 5 • 9.2k RPM</div>
          </div>

          <!-- Pitch & Lean Angle Bar -->
          <div style="display: flex; justify-content: space-around; margin-top: 40px; padding-top: 30px; border-top: 1px solid rgba(255,255,255,0.08);">
            <div>
              <div class="mono orange" style="font-size: 38px; font-weight: 800;">34° L</div>
              <div style="font-size: 18px; color: rgba(255,255,255,0.5); font-weight: 600; text-transform: uppercase;">Lean Angle</div>
            </div>
            <div style="width: 1px; background: rgba(255,255,255,0.1);"></div>
            <div>
              <div class="mono orange" style="font-size: 38px; font-weight: 800;">1.1 G</div>
              <div style="font-size: 18px; color: rgba(255,255,255,0.5); font-weight: 600; text-transform: uppercase;">Lateral Force</div>
            </div>
            <div style="width: 1px; background: rgba(255,255,255,0.1);"></div>
            <div>
              <div class="mono orange" style="font-size: 38px; font-weight: 800;">940 m</div>
              <div style="font-size: 18px; color: rgba(255,255,255,0.5); font-weight: 600; text-transform: uppercase;">Elevation</div>
            </div>
          </div>
        </div>

        <!-- Real-Time Telemetry Quad -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 36px;">
          <div class="glass-orange" style="padding: 28px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">SESSION DISTANCE</div>
            <div class="hanken orange" style="font-size: 48px; font-weight: 800; margin-top: 8px;">42.8 <span style="font-size: 24px; color: #fff;">km</span></div>
            <div class="mono" style="font-size: 18px; color: rgba(255,255,255,0.5); margin-top: 4px;">Elapsed: 38m 14s</div>
          </div>
          <div class="glass" style="padding: 28px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">SAFETY RATING</div>
            <div class="hanken" style="font-size: 48px; font-weight: 800; margin-top: 8px; color: #34C759;">99.4 <span style="font-size: 24px; color: #fff;">/ 100</span></div>
            <div class="mono" style="font-size: 18px; color: #34C759; margin-top: 4px;">Zero Violations Recorded</div>
          </div>
          <div class="glass" style="padding: 28px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">ACTIVE MACHINE</div>
            <div class="hanken" style="font-size: 30px; font-weight: 700; margin-top: 10px;">Classic 350</div>
            <div class="mono orange" style="font-size: 18px; margin-top: 4px;">KA 04 EL 274 (349 cc)</div>
          </div>
          <div class="glass" style="padding: 28px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">WEATHER CONDITION</div>
            <div class="hanken" style="font-size: 30px; font-weight: 700; margin-top: 10px;">28°C Clear</div>
            <div class="mono" style="font-size: 18px; color: rgba(255,255,255,0.6); margin-top: 4px;">Asphalt Dry • Wind 8 km/h</div>
          </div>
        </div>

        <!-- Big CTA Button -->
        <div style="background: linear-gradient(135deg, #FF6B00, #E05300); border-radius: 28px; padding: 32px; text-align: center; box-shadow: 0 15px 35px rgba(255,107,0,0.4);">
          <div class="hanken" style="font-size: 32px; font-weight: 900; letter-spacing: 1.5px; color: #fff;">START LIVE RECORDING SESSION</div>
        </div>
      </div>

      <!-- Bottom Nav -->
      <div class="nav-bar">
        <div class="nav-item active"><div class="nav-icon" style="font-size: 36px;">⚡</div>Cockpit</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🧭</div>Ride</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">📸</div>Memories</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">👥</div>Squads</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🏍️</div>Garage</div>
      </div>
    </body>
    </html>`
  },
  {
    name: 'navigation_ride.png',
    html: `<!DOCTYPE html>
    <html>
    <head><style>${baseStyles}
      .map-grid {
        position: absolute;
        inset: 0;
        background: #0B0E14;
        background-image: 
          radial-gradient(#1E2330 1.5px, transparent 1.5px),
          radial-gradient(#1E2330 1.5px, #0B0E14 1.5px);
        background-size: 60px 60px;
        background-position: 0 0, 30px 30px;
      }
    </style></head>
    <body>
      <div class="map-grid"></div>

      <!-- Realistic Map Route SVG Vector -->
      <svg style="position: absolute; inset: 0; width: 100%; height: 100%; z-index: 5;" xmlns="http://www.w3.org/2000/svg">
        <!-- Background Roads -->
        <path d="M 120 1800 Q 300 1400 450 1200 T 800 600 L 980 200" fill="none" stroke="#1A202C" stroke-width="42"/>
        <path d="M 50 800 L 1050 950" fill="none" stroke="#1A202C" stroke-width="28"/>
        
        <!-- Glowing GPS Trajectory -->
        <path d="M 540 2100 Q 540 1600 580 1350 T 420 850 Q 380 550 680 320" fill="none" stroke="#FF6B00" stroke-width="18" stroke-linecap="round" stroke-linejoin="round" style="filter: drop-shadow(0 0 16px rgba(255,107,0,0.8));"/>
        
        <!-- Waypoint Dots -->
        <circle cx="580" cy="1350" r="14" fill="#FFFFFF" stroke="#FF6B00" stroke-width="6"/>
        <circle cx="420" cy="850" r="14" fill="#FFFFFF" stroke="#FF6B00" stroke-width="6"/>
        
        <!-- Current Rider Marker with Direction Cone -->
        <circle cx="540" cy="1650" r="32" fill="#FF6B00" style="filter: drop-shadow(0 0 30px rgba(255,107,0,1));"/>
        <circle cx="540" cy="1650" r="14" fill="#FFFFFF"/>
        <polygon points="540,1570 515,1630 565,1630" fill="#FF6B00"/>

        <!-- Destination Flag -->
        <circle cx="680" cy="320" r="28" fill="#34C759" style="filter: drop-shadow(0 0 25px rgba(52,199,89,0.8));"/>
        <text x="730" y="330" fill="#FFFFFF" font-family="'Hanken Grotesk', sans-serif" font-size="30" font-weight="bold">Nandi Hills Peak (1,478m)</text>
      </svg>

      <div class="status-bar">
        <span>11:15</span>
        <div class="status-icons">
          <span>5G GPS LOCKED</span>
          <span>84% ⚡</span>
        </div>
      </div>

      <!-- Turn-by-Turn Instruction Banner -->
      <div style="position: relative; z-index: 20; padding: 20px 48px;">
        <div class="glass" style="padding: 32px 36px; background: rgba(14, 16, 22, 0.9); border-left: 12px solid #FF6B00; display: flex; align-items: center; gap: 32px; box-shadow: 0 20px 40px rgba(0,0,0,0.6);">
          <div style="width: 80px; height: 80px; background: #FF6B00; border-radius: 20px; display: flex; align-items: center; justify-content: center; font-size: 46px; font-weight: 900; color: #fff;">↱</div>
          <div>
            <div class="mono orange" style="font-size: 24px; font-weight: 700; letter-spacing: 1px;">IN 250 METERS</div>
            <div class="hanken" style="font-size: 38px; font-weight: 800; margin-top: 4px;">Turn Right onto NH 44 Expressway</div>
            <div style="font-size: 20px; color: rgba(255,255,255,0.6); margin-top: 4px;">Stay on right 2 lanes toward Devanahalli Bypass</div>
          </div>
        </div>
      </div>

      <!-- Floating Live Speed & Radar Pill -->
      <div style="position: absolute; top: 380px; right: 48px; z-index: 20; display: flex; flex-direction: column; gap: 16px;">
        <div class="glass" style="width: 140px; height: 140px; border-radius: 50%; display: flex; flex-direction: column; align-items: center; justify-content: center; border: 4px solid #FF6B00; box-shadow: 0 0 35px rgba(255,107,0,0.4);">
          <div class="hanken" style="font-size: 52px; font-weight: 900; line-height: 1;">92</div>
          <div class="mono" style="font-size: 16px; color: rgba(255,255,255,0.6);">KM/H</div>
        </div>
        <div class="glass" style="width: 140px; height: 60px; border-radius: 30px; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: 700; color: #34C759; border: 1px solid #34C759;">
          LIMIT 100
        </div>
      </div>

      <!-- Bottom Ride Stats HUD -->
      <div style="position: absolute; bottom: 220px; left: 48px; right: 48px; z-index: 20;">
        <div class="glass" style="padding: 36px 44px; background: rgba(14, 16, 22, 0.94); box-shadow: 0 25px 60px rgba(0,0,0,0.7);">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
            <div>
              <div style="font-size: 20px; color: rgba(255,255,255,0.5); font-weight: 600;">DESTINATION</div>
              <div class="hanken" style="font-size: 34px; font-weight: 800;">Nandi Hills Viewpoint</div>
            </div>
            <div style="text-align: right;">
              <div class="mono orange" style="font-size: 42px; font-weight: 900;">36.4 km</div>
              <div style="font-size: 18px; color: rgba(255,255,255,0.6);">ETA 11:58 AM (43 mins)</div>
            </div>
          </div>

          <div style="height: 8px; background: rgba(255,255,255,0.1); border-radius: 4px; overflow: hidden; margin-bottom: 24px;">
            <div style="width: 58%; height: 100%; background: linear-gradient(90deg, #FF6B00, #34C759);"></div>
          </div>

          <div style="display: flex; justify-content: space-between; align-items: center;">
            <div style="display: flex; gap: 20px;">
              <span class="mono" style="font-size: 20px; color: rgba(255,255,255,0.7);">⚡ 0 Traffic Delays</span>
              <span class="mono" style="font-size: 20px; color: #34C759;">● Ghat Tarmac Dry</span>
            </div>
            <div style="padding: 14px 28px; background: rgba(255,59,48,0.15); border: 1px solid #FF3B30; border-radius: 16px; color: #FF3B30; font-weight: 800; font-size: 20px;">END RIDE</div>
          </div>
        </div>
      </div>

      <!-- Bottom Nav -->
      <div class="nav-bar">
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">⚡</div>Cockpit</div>
        <div class="nav-item active"><div class="nav-icon" style="font-size: 36px;">🧭</div>Ride</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">📸</div>Memories</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">👥</div>Squads</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🏍️</div>Garage</div>
      </div>
    </body>
    </html>`
  },
  {
    name: 'squads_community.png',
    html: `<!DOCTYPE html>
    <html>
    <head><style>${baseStyles}</style></head>
    <body>
      <div class="status-bar">
        <span>11:45</span>
        <div class="status-icons">
          <span>SQUAD RADAR ON</span>
          <span>82% ⚡</span>
        </div>
      </div>

      <div style="padding: 20px 48px 180px;">
        <!-- Squad Header -->
        <div class="glass" style="padding: 32px 36px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 36px; border-top: 4px solid #FF6B00;">
          <div>
            <div class="mono orange" style="font-size: 18px; font-weight: 700; letter-spacing: 2px;">ACTIVE CONVOY</div>
            <div class="hanken" style="font-size: 36px; font-weight: 800; margin-top: 4px;">Apex Syndicate Bangalore</div>
            <div style="font-size: 20px; color: rgba(255,255,255,0.6); margin-top: 4px;">4 Pilots Riding • Formation: Staggered</div>
          </div>
          <div style="display: flex; gap: 12px;">
            <div style="width: 56px; height: 56px; border-radius: 50%; background: #34C759; display: flex; align-items: center; justify-content: center; font-size: 26px;">🎙️</div>
          </div>
        </div>

        <!-- Live Tactical Radar Circle -->
        <div class="glass" style="padding: 40px; text-align: center; position: relative; margin-bottom: 36px;">
          <div class="mono" style="font-size: 20px; color: rgba(255,255,255,0.6); letter-spacing: 2px; margin-bottom: 24px;">LIVE PROXIMITY RADAR (500m RANGE)</div>

          <!-- Radar Visual Circles -->
          <div style="width: 440px; height: 440px; margin: 0 auto; border-radius: 50%; border: 2px solid rgba(255,107,0,0.4); position: relative; display: flex; align-items: center; justify-content: center;">
            <div style="width: 300px; height: 300px; border-radius: 50%; border: 1px dashed rgba(255,255,255,0.2); position: absolute;"></div>
            <div style="width: 160px; height: 160px; border-radius: 50%; border: 1px dashed rgba(255,255,255,0.15); position: absolute;"></div>
            <div style="width: 100%; height: 2px; background: rgba(255,255,255,0.06); position: absolute;"></div>
            <div style="height: 100%; width: 2px; background: rgba(255,255,255,0.06); position: absolute;"></div>

            <!-- You (Lead Pilot) -->
            <div style="width: 32px; height: 32px; border-radius: 50%; background: #FF6B00; box-shadow: 0 0 25px #FF6B00; position: absolute; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 14px;">ME</div>
            
            <!-- Wingman 1: Alex -->
            <div style="position: absolute; top: 120px; left: 160px; text-align: center;">
              <div style="width: 24px; height: 24px; border-radius: 50%; background: #00E5FF; box-shadow: 0 0 15px #00E5FF; margin: 0 auto;"></div>
              <span class="mono" style="font-size: 16px; color: #00E5FF; font-weight: bold;">Alex (24m)</span>
            </div>

            <!-- Wingman 2: Carlos -->
            <div style="position: absolute; bottom: 100px; left: 130px; text-align: center;">
              <div style="width: 24px; height: 24px; border-radius: 50%; background: #00E5FF; box-shadow: 0 0 15px #00E5FF; margin: 0 auto;"></div>
              <span class="mono" style="font-size: 16px; color: #00E5FF; font-weight: bold;">Carlos (58m)</span>
            </div>

            <!-- Sweeper: Sarah -->
            <div style="position: absolute; bottom: 60px; right: 140px; text-align: center;">
              <div style="width: 24px; height: 24px; border-radius: 50%; background: #34C759; box-shadow: 0 0 15px #34C759; margin: 0 auto;"></div>
              <span class="mono" style="font-size: 16px; color: #34C759; font-weight: bold;">Sarah (110m)</span>
            </div>
          </div>

          <div class="mono orange" style="font-size: 22px; font-weight: 700; margin-top: 30px;">● CONVOY FORMATION OPTIMAL (0 PILOTS STRAGGLING)</div>
        </div>

        <!-- Pilot Roster List -->
        <div class="glass" style="padding: 24px 36px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; align-items: center; gap: 20px;">
            <div style="width: 60px; height: 60px; border-radius: 50%; background: #FF6B00; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 24px;">RP</div>
            <div>
              <div class="hanken" style="font-size: 26px; font-weight: 700;">Rithwik Pilot (Lead)</div>
              <div class="mono orange" style="font-size: 18px;">Speed: 94 km/h • Classic 350</div>
            </div>
          </div>
          <div style="color: #34C759; font-weight: 800; font-size: 22px;">ONLINE</div>
        </div>

        <div class="glass" style="padding: 24px 36px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; align-items: center; gap: 20px;">
            <div style="width: 60px; height: 60px; border-radius: 50%; background: #00E5FF; color: #000; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 24px;">AR</div>
            <div>
              <div class="hanken" style="font-size: 26px; font-weight: 700;">Alex Rider (Wingman)</div>
              <div class="mono" style="font-size: 18px; color: rgba(255,255,255,0.6);">24m Behind • Duke 390</div>
            </div>
          </div>
          <div style="color: #34C759; font-weight: 800; font-size: 22px;">VOICE ACTIVE</div>
        </div>

        <div class="glass" style="padding: 24px 36px; display: flex; justify-content: space-between; align-items: center;">
          <div style="display: flex; align-items: center; gap: 20px;">
            <div style="width: 60px; height: 60px; border-radius: 50%; background: #34C759; color: #000; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 24px;">SK</div>
            <div>
              <div class="hanken" style="font-size: 26px; font-weight: 700;">Sarah K. (Sweeper)</div>
              <div class="mono" style="font-size: 18px; color: rgba(255,255,255,0.6);">110m Behind • Speed 400</div>
            </div>
          </div>
          <div style="color: #34C759; font-weight: 800; font-size: 22px;">SYNCED</div>
        </div>
      </div>

      <!-- Bottom Nav -->
      <div class="nav-bar">
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">⚡</div>Cockpit</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🧭</div>Ride</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">📸</div>Memories</div>
        <div class="nav-item active"><div class="nav-icon" style="font-size: 36px;">👥</div>Squads</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🏍️</div>Garage</div>
      </div>
    </body>
    </html>`
  },
  {
    name: 'pilot_profile.png',
    html: `<!DOCTYPE html>
    <html>
    <head><style>${baseStyles}</style></head>
    <body>
      <div class="status-bar">
        <span>12:05</span>
        <div class="status-icons">
          <span>5G</span>
          <span>80% ⚡</span>
        </div>
      </div>

      <div style="padding: 20px 48px 180px;">
        <!-- Big Pilot Card -->
        <div class="glass" style="padding: 44px; text-align: center; margin-bottom: 36px; position: relative;">
          <div style="width: 140px; height: 140px; border-radius: 50%; background: linear-gradient(135deg, #FF6B00, #FF944D); margin: 0 auto 24px; display: flex; align-items: center; justify-content: center; font-size: 64px; font-weight: 900; border: 4px solid #FF6B00; box-shadow: 0 0 40px rgba(255,107,0,0.6);">RP</div>
          <div class="hanken" style="font-size: 42px; font-weight: 900;">Rithwik Pilot</div>
          <div class="mono orange" style="font-size: 22px; font-weight: 700; margin-top: 6px;">@rithwik_pilot • BANGALORE, IN</div>
          
          <!-- XP Progress Bar -->
          <div style="margin-top: 32px; background: rgba(255,255,255,0.05); padding: 24px 32px; border-radius: 20px;">
            <div style="display: flex; justify-content: space-between; font-size: 22px; font-weight: 700; margin-bottom: 12px;">
              <span class="orange">Level 7: Tourer Legend</span>
              <span class="mono">18,450 / 20,000 XP</span>
            </div>
            <div style="height: 14px; background: rgba(255,255,255,0.1); border-radius: 7px; overflow: hidden;">
              <div style="width: 92%; height: 100%; background: linear-gradient(90deg, #FF6B00, #FFA726);"></div>
            </div>
          </div>
        </div>

        <!-- Pilot Lifetime Stats Grid -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 36px;">
          <div class="glass" style="padding: 32px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">TOTAL DISTANCE</div>
            <div class="hanken orange" style="font-size: 54px; font-weight: 900; margin-top: 8px;">4,820 <span style="font-size: 24px; color: #fff;">km</span></div>
          </div>
          <div class="glass" style="padding: 32px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">RIDES LOGGED</div>
            <div class="hanken" style="font-size: 54px; font-weight: 900; margin-top: 8px;">68 <span style="font-size: 24px; color: rgba(255,255,255,0.6);">rides</span></div>
          </div>
          <div class="glass" style="padding: 32px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">SAFETY INDEX</div>
            <div class="hanken" style="font-size: 54px; font-weight: 900; margin-top: 8px; color: #34C759;">99.4%</div>
          </div>
          <div class="glass" style="padding: 32px;">
            <div style="font-size: 18px; color: rgba(255,255,255,0.6); font-weight: 600;">MAX LEAN ANGLE</div>
            <div class="hanken orange" style="font-size: 54px; font-weight: 900; margin-top: 8px;">46° L</div>
          </div>
        </div>

        <!-- Trophy Badges Showcase -->
        <div class="glass" style="padding: 36px;">
          <div class="hanken" style="font-size: 28px; font-weight: 800; margin-bottom: 24px;">UNLOCKED TROPHIES (12)</div>
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; text-align: center;">
            <div style="padding: 20px; background: rgba(255,107,0,0.1); border: 1px solid rgba(255,107,0,0.3); border-radius: 20px;">
              <div style="font-size: 48px;">🏆</div>
              <div class="hanken" style="font-size: 20px; font-weight: 700; margin-top: 8px;">Century Rider</div>
              <div class="mono" style="font-size: 14px; color: rgba(255,255,255,0.6); margin-top: 4px;">100km Non-stop</div>
            </div>
            <div style="padding: 20px; background: rgba(52,199,89,0.1); border: 1px solid rgba(52,199,89,0.3); border-radius: 20px;">
              <div style="font-size: 48px;">🛡️</div>
              <div class="hanken" style="font-size: 20px; font-weight: 700; margin-top: 8px;">Zero Violations</div>
              <div class="mono" style="font-size: 14px; color: rgba(255,255,255,0.6); margin-top: 4px;">10 Clean Rides</div>
            </div>
            <div style="padding: 20px; background: rgba(0,229,255,0.1); border: 1px solid rgba(0,229,255,0.3); border-radius: 20px;">
              <div style="font-size: 48px;">🏔️</div>
              <div class="hanken" style="font-size: 20px; font-weight: 700; margin-top: 8px;">Apex Master</div>
              <div class="mono" style="font-size: 14px; color: rgba(255,255,255,0.6); margin-top: 4px;">45° Lean Achieved</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Bottom Nav -->
      <div class="nav-bar">
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">⚡</div>Cockpit</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🧭</div>Ride</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">📸</div>Memories</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">👥</div>Squads</div>
        <div class="nav-item active"><div class="nav-icon" style="font-size: 36px;">🏍️</div>Garage</div>
      </div>
    </body>
    </html>`
  },
  {
    name: 'memories_journal.png',
    html: `<!DOCTYPE html>
    <html>
    <head><style>${baseStyles}</style></head>
    <body>
      <div class="status-bar">
        <span>12:20</span>
        <div class="status-icons">
          <span>5G</span>
          <span>78% ⚡</span>
        </div>
      </div>

      <div style="padding: 20px 48px 180px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px;">
          <div>
            <div class="mono orange" style="font-size: 18px; font-weight: 700; letter-spacing: 2px;">TELEMETRY JOURNAL</div>
            <div class="hanken" style="font-size: 38px; font-weight: 900; margin-top: 4px;">Ride Memories</div>
          </div>
          <div style="padding: 14px 28px; background: #FF6B00; border-radius: 20px; font-weight: 800; font-size: 20px;">+ RECORD MEMORY</div>
        </div>

        <!-- Featured Ride Highlight Card -->
        <div class="glass" style="padding: 40px; margin-bottom: 36px; border-left: 8px solid #FF6B00; box-shadow: 0 20px 45px rgba(0,0,0,0.5);">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <span class="mono orange" style="font-size: 18px; font-weight: bold;">YESTERDAY • 148.5 KM</span>
              <div class="hanken" style="font-size: 36px; font-weight: 900; margin-top: 8px;">Western Ghats Monsoon Pass</div>
              <div style="font-size: 20px; color: rgba(255,255,255,0.6); margin-top: 4px;">Route: Sakleshpur to Bisle Ghat Viewpoint</div>
            </div>
            <div style="padding: 10px 20px; background: rgba(52,199,89,0.15); border: 1px solid #34C759; border-radius: 14px; color: #34C759; font-weight: bold; font-size: 18px;">SAFETY 100</div>
          </div>

          <!-- Elevation & Telemetry Waveform -->
          <div style="margin: 32px 0; padding: 24px; background: rgba(0,0,0,0.4); border-radius: 20px;">
            <div style="display: flex; justify-content: space-between; font-size: 18px; color: rgba(255,255,255,0.6); margin-bottom: 12px;">
              <span>Elevation Profile (Climb: 1,420m)</span>
              <span class="mono orange">Max Lean: 44°</span>
            </div>
            <svg width="100%" height="90" viewBox="0 0 900 90" fill="none">
              <path d="M 0 80 Q 200 40 350 20 T 600 50 T 900 10" stroke="#FF6B00" stroke-width="5" fill="none"/>
              <path d="M 0 80 Q 200 40 350 20 T 600 50 T 900 10 L 900 90 L 0 90 Z" fill="rgba(255,107,0,0.1)"/>
            </svg>
          </div>

          <!-- Quick Stats Trio -->
          <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; text-align: center;">
            <div style="padding: 18px; background: rgba(255,255,255,0.04); border-radius: 16px;">
              <div class="hanken orange" style="font-size: 34px; font-weight: 800;">3h 12m</div>
              <div style="font-size: 16px; color: rgba(255,255,255,0.5);">Duration</div>
            </div>
            <div style="padding: 18px; background: rgba(255,255,255,0.04); border-radius: 16px;">
              <div class="hanken" style="font-size: 34px; font-weight: 800;">68 km/h</div>
              <div style="font-size: 16px; color: rgba(255,255,255,0.5);">Avg Speed</div>
            </div>
            <div style="padding: 18px; background: rgba(255,255,255,0.04); border-radius: 16px;">
              <div class="hanken orange" style="font-size: 34px; font-weight: 800;">138 km/h</div>
              <div style="font-size: 16px; color: rgba(255,255,255,0.5);">Top Speed</div>
            </div>
          </div>
        </div>

        <!-- Voice Note Attachment Card -->
        <div class="glass" style="padding: 30px 36px; display: flex; align-items: center; justify-content: space-between;">
          <div style="display: flex; align-items: center; gap: 24px;">
            <div style="width: 64px; height: 64px; border-radius: 50%; background: #FF6B00; display: flex; align-items: center; justify-content: center; font-size: 28px;">▶️</div>
            <div>
              <div class="hanken" style="font-size: 24px; font-weight: 700;">Voice Memo: Bisle Hairpins Condition</div>
              <div class="mono" style="font-size: 18px; color: rgba(255,255,255,0.5); margin-top: 4px;">Recorded at 1,180m • 0:45s</div>
            </div>
          </div>
          <span class="mono orange" style="font-size: 20px; font-weight: bold;">PLAY AUDIO</span>
        </div>
      </div>

      <!-- Bottom Nav -->
      <div class="nav-bar">
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">⚡</div>Cockpit</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🧭</div>Ride</div>
        <div class="nav-item active"><div class="nav-icon" style="font-size: 36px;">📸</div>Memories</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">👥</div>Squads</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🏍️</div>Garage</div>
      </div>
    </body>
    </html>`
  },
  {
    name: 'garage_management.png',
    html: `<!DOCTYPE html>
    <html>
    <head><style>${baseStyles}</style></head>
    <body>
      <div class="status-bar">
        <span>12:35</span>
        <div class="status-icons">
          <span>5G</span>
          <span>76% ⚡</span>
        </div>
      </div>

      <div style="padding: 20px 48px 180px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px;">
          <div>
            <div class="mono orange" style="font-size: 18px; font-weight: 700; letter-spacing: 2px;">DIGITAL MOTORCYCLE VAULT</div>
            <div class="hanken" style="font-size: 38px; font-weight: 900; margin-top: 4px;">My Garage</div>
          </div>
          <div style="padding: 14px 28px; background: #FF6B00; border-radius: 20px; font-weight: 800; font-size: 20px;">+ ADD BIKE</div>
        </div>

        <!-- Primary Motorcycle Showcase Card -->
        <div class="glass" style="padding: 40px; margin-bottom: 36px; border: 2px solid rgba(255,107,0,0.4); box-shadow: 0 25px 50px rgba(255,107,0,0.15);">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <div>
              <span class="mono orange" style="font-size: 18px; font-weight: bold; background: rgba(255,107,0,0.15); padding: 6px 14px; border-radius: 8px;">PRIMARY MACHINE</span>
              <div class="hanken" style="font-size: 42px; font-weight: 900; margin-top: 14px;">Royal Enfield Classic 350</div>
              <div class="mono" style="font-size: 24px; color: rgba(255,255,255,0.8); margin-top: 6px;">KA 04 EL 274 • 349 cc (Petrol)</div>
            </div>
            <div style="font-size: 64px;">🏍️</div>
          </div>

          <!-- Odometer & Health Bar -->
          <div style="display: flex; justify-content: space-between; margin-top: 36px; padding-top: 28px; border-top: 1px solid rgba(255,255,255,0.08);">
            <div>
              <div style="font-size: 18px; color: rgba(255,255,255,0.5);">CURRENT ODOMETER</div>
              <div class="hanken orange" style="font-size: 40px; font-weight: 900;">12,450 km</div>
            </div>
            <div>
              <div style="font-size: 18px; color: rgba(255,255,255,0.5);">NEXT SERVICE DUE</div>
              <div class="hanken" style="font-size: 40px; font-weight: 900;">In 850 km</div>
            </div>
            <div>
              <div style="font-size: 18px; color: rgba(255,255,255,0.5);">VEHICLE HEALTH</div>
              <div class="hanken" style="font-size: 40px; font-weight: 900; color: #34C759;">100% Ready</div>
            </div>
          </div>
        </div>

        <!-- Document & Legal Vault (Challans, Insurance, PUC) -->
        <div class="glass" style="padding: 36px; margin-bottom: 36px;">
          <div class="hanken" style="font-size: 28px; font-weight: 800; margin-bottom: 24px;">RTO COMPLIANCE & DOCUMENTS</div>
          
          <div style="display: flex; flex-direction: column; gap: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; background: rgba(52,199,89,0.1); border: 1px solid rgba(52,199,89,0.3); border-radius: 16px;">
              <div style="display: flex; align-items: center; gap: 16px;">
                <span style="font-size: 32px;">🛡️</span>
                <div>
                  <div class="hanken" style="font-size: 22px; font-weight: bold;">Comprehensive Insurance</div>
                  <div class="mono" style="font-size: 16px; color: rgba(255,255,255,0.6);">Valid up to 14 Oct 2027 (280 days left)</div>
                </div>
              </div>
              <span style="color: #34C759; font-weight: 800; font-size: 20px;">ACTIVE</span>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; background: rgba(52,199,89,0.1); border: 1px solid rgba(52,199,89,0.3); border-radius: 16px;">
              <div style="display: flex; align-items: center; gap: 16px;">
                <span style="font-size: 32px;">🌿</span>
                <div>
                  <div class="hanken" style="font-size: 22px; font-weight: bold;">PUC Emission Certificate</div>
                  <div class="mono" style="font-size: 16px; color: rgba(255,255,255,0.6);">Valid up to 30 Jun 2027 (90 days left)</div>
                </div>
              </div>
              <span style="color: #34C759; font-weight: 800; font-size: 20px;">VALID</span>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; padding: 20px 24px; background: rgba(255,107,0,0.1); border: 1px solid rgba(255,107,0,0.3); border-radius: 16px;">
              <div style="display: flex; align-items: center; gap: 16px;">
                <span style="font-size: 32px;">⚖️</span>
                <div>
                  <div class="hanken" style="font-size: 22px; font-weight: bold;">Traffic Challan Vault</div>
                  <div class="mono" style="font-size: 16px; color: rgba(255,255,255,0.6);">0 Pending Traffic Violations Recorded</div>
                </div>
              </div>
              <span class="orange" style="font-weight: 800; font-size: 20px;">CLEAN</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Bottom Nav -->
      <div class="nav-bar">
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">⚡</div>Cockpit</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">🧭</div>Ride</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">📸</div>Memories</div>
        <div class="nav-item"><div class="nav-icon" style="font-size: 36px;">👥</div>Squads</div>
        <div class="nav-item active"><div class="nav-icon" style="font-size: 36px;">🏍️</div>Garage</div>
      </div>
    </body>
    </html>`
  }
];

// Generate HTML files and render via headless Chrome
const tempDir = path.resolve(__dirname, '../temp_screens');
if (!fs.existsSync(tempDir)) fs.mkdirSync(tempDir, { recursive: true });

for (const screen of screens) {
  const htmlPath = path.join(tempDir, `${screen.name}.html`);
  const pngPath = path.join(outputDir, screen.name);
  fs.writeFileSync(htmlPath, screen.html, 'utf8');

  console.log(`Rendering ${screen.name}...`);
  const cmd = `"${chromePath}" --headless --screenshot="${pngPath}" --window-size=1080,2340 --hide-scrollbars "file://${htmlPath.replace(/\\\\/g, '/')}"`;
  execSync(cmd);
  console.log(`✓ Rendered ${screen.name} to ${pngPath}`);
}

// Clean up temp HTML
fs.rmSync(tempDir, { recursive: true, force: true });
console.log('All high-resolution mobile screenshots rendered successfully!');
