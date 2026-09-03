/**
 * RiderMate 2.0 — Central Download & Distribution Configuration
 * 
 * Direct APK hosted on Azure Static Web App (/downloads/RiderMate-2.0.apk)
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
  buildNumber: 20260901,
  commitHash: "release",
  releaseTag: "v2.0.0-release",
  releaseDate: "September 1, 2026",
  apkSizeMB: 67.7,
  sha256Checksum: "B73A43D912FCA47B7348DFCB6DF06F304D405F61749A311D8D053CD6EF502BFC",
  minAndroidVersion: "Android 8.0 (Oreo) or higher",
  
  // Hosted direct on the website
  activeDistribution: 'direct_apk',

  links: {
    githubRelease: "/downloads/RiderMate-2.0.apk",
    playStore: "https://play.google.com/store/apps/details?id=com.ridermate.ridermate",
    directApk: "/downloads/RiderMate-2.0.apk",
    gitHubRepo: "https://github.com/rithwikkr0/Ridermate-2.0",
    gitHubReleasePage: "https://github.com/rithwikkr0/Ridermate-2.0/releases",
  },

  referralBaseUrl: "https://green-coast-00868c100.7.azurestaticapps.net/join",
};

export function getActiveDownloadUrl(): string {
  switch (downloadConfig.activeDistribution) {
    case 'play_store':
      return downloadConfig.links.playStore;
    case 'github_release':
      return downloadConfig.links.githubRelease;
    case 'direct_apk':
    default:
      return downloadConfig.links.directApk;
  }
}

export function getDownloadButtonLabel(): string {
  switch (downloadConfig.activeDistribution) {
    case 'play_store':
      return 'Get on Google Play';
    case 'direct_apk':
      return 'Download APK (v2.0.0)';
    case 'github_release':
    default:
      return 'Download Release APK';
  }
}
