/**
 * RiderMate 2.0 — Central Download & Deployment Configuration
 * 
 * To switch from GitHub Release to Google Play Store after publication,
 * change `activeDistribution` from 'github_release' to 'play_store'.
 */

export interface DownloadConfig {
  version: string;
  buildNumber: number;
  commitHash: string;
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
  };
  referralBaseUrl: string;
}

export const downloadConfig: DownloadConfig = {
  version: "2.0.0",
  buildNumber: 51524378,
  commitHash: "c5844db",
  releaseDate: "August 20, 2026",
  apkSizeMB: 160.4,
  sha256Checksum: "fa472922ce479155620fd71bf4e976b87ff489108730269d68116888cecf0686",
  minAndroidVersion: "Android 8.0 (Oreo) or higher",
  
  // Toggle this single value to switch download destination across the entire website
  activeDistribution: 'github_release',

  links: {
    // Current GitHub Release download link
    githubRelease: "https://github.com/rithwikkr0/Ridermate-2.0/releases/latest/download/app-debug.apk",
    // Future Play Store URL once published
    playStore: "https://play.google.com/store/apps/details?id=com.ridermate.ridermate",
    // Direct link fallback
    directApk: "https://github.com/rithwikkr0/Ridermate-2.0/releases/download/v2.0.0/app-debug.apk",
    // Source repo
    gitHubRepo: "https://github.com/rithwikkr0/Ridermate-2.0",
  },

  // Referral URL used in marketing and sharing
  referralBaseUrl: "https://green-coast-00868c100.7.azurestaticapps.net/join",
};

/**
 * Returns the currently active download link based on `activeDistribution`
 */
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

/**
 * Returns human-readable label for the active download button
 */
export function getDownloadButtonLabel(): string {
  if (downloadConfig.activeDistribution === 'play_store') {
    return 'Get it on Google Play';
  }
  return `Download for Android (v${downloadConfig.version})`;
}
