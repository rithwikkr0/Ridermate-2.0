/**
 * RiderMate 2.0 — Central Download & Distribution Configuration
 * 
 * Verified Direct Download URL:
 * https://github.com/rithwikkr0/Ridermate-2.0/releases/download/v2.0.0-tester/app-debug.apk
 */

export interface DownloadConfig {
  appName: string;
  brandTagline: string;
  version: string;
  buildNumber: number;
  commitHash: string;
  releaseTag: string;
  releaseDate: string;
  apkSizeMB: number;
  sha256Checksum: string;
  minAndroidVersion: string;
  activeDistribution: 'github_release' | 'play_store' | 'direct_apk';
  links: {
    githubRelease: string;
    playStore: string;
    directApk: string;
    gitHubRepo: string;
    gitHubReleasePage: string;
  };
  referralBaseUrl: string;
}

export const downloadConfig: DownloadConfig = {
  appName: "RiderMate 2.0",
  brandTagline: "CircuitRider — The High-Performance Motorcycle Cockpit",
  version: "2.0.0",
  buildNumber: 51530205,
  commitHash: "362cb936",
  releaseTag: "v2.0.0-tester",
  releaseDate: "August 21, 2026",
  apkSizeMB: 160.4,
  sha256Checksum: "fa472922ce479155620fd71bf4e976b87ff489108730269d68116888cecf0686",
  minAndroidVersion: "Android 8.0 (Oreo) or higher",
  
  // Set to 'play_store' once published to Google Play
  activeDistribution: 'github_release',

  links: {
    // Verified working direct APK download link
    githubRelease: "https://github.com/rithwikkr0/Ridermate-2.0/releases/download/v2.0.0-tester/app-debug.apk",
    // Google Play Store URL
    playStore: "https://play.google.com/store/apps/details?id=com.ridermate.ridermate",
    // Fallback APK
    directApk: "https://github.com/rithwikkr0/Ridermate-2.0/releases/download/v2.0.0-tester/app-debug.apk",
    // GitHub Repo & Release Page
    gitHubRepo: "https://github.com/rithwikkr0/Ridermate-2.0",
    gitHubReleasePage: "https://github.com/rithwikkr0/Ridermate-2.0/releases/tag/v2.0.0-tester",
  },

  // Live Azure Static Web App URL
  referralBaseUrl: "https://green-coast-00868c100.7.azurestaticapps.net/join",
};

export function getActiveDownloadUrl(): string {
  switch (downloadConfig.activeDistribution) {
    case 'play_store':
      return downloadConfig.links.playStore;
    case 'direct_apk':
      return downloadConfig.links.directApk;
    case 'github_release':
    default:
      return downloadConfig.links.githubRelease;
  }
}

export function getDownloadButtonLabel(): string {
  if (downloadConfig.activeDistribution === 'play_store') {
    return 'Get it on Google Play';
  }
  return `Download APK (v${downloadConfig.version})`;
}
