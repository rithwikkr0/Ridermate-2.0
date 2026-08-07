import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/permission_screen.dart';
import '../../features/auth/screens/privacy_policy_screen.dart';
import '../../features/auth/screens/terms_screen.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/home/screens/notification_center_screen.dart';
import '../../features/home/screens/weather_details_screen.dart';
import '../../features/rides/screens/ride_history_screen.dart';
import '../../features/rides/screens/ride_summary_screen.dart';
import '../../features/rides/screens/live_ride_tracking_screen.dart';
import '../../features/rides/screens/ride_story_screen.dart';
import '../../features/rides/screens/ride_hud_screen.dart';
import '../../features/rides/screens/ride_calendar_screen.dart';
import '../../features/rides/screens/success_ride_saved_screen.dart';
import '../../features/rides/screens/export_share_screen.dart';
import '../../features/maps/screens/live_navigation_screen.dart';
import '../../features/maps/screens/search_destination_screen.dart';
import '../../features/maps/screens/route_planning_screen.dart';
import '../../features/maps/screens/route_comparison_screen.dart';
import '../../features/maps/screens/heatmap_explorer_screen.dart';
import '../../features/maps/screens/live_group_map_screen.dart';
import '../../features/maps/screens/navigation_settings_screen.dart';
import '../../features/ai/screens/ai_copilot_home_screen.dart';
import '../../features/ai/screens/ai_listening_screen.dart';
import '../../features/ai/screens/ai_pre_ride_briefing_screen.dart';
import '../../features/ai/screens/ai_post_ride_analysis_screen.dart';
import '../../features/ai/screens/ai_coach_insights_screen.dart';
import '../../features/ai/screens/ai_insights_hub_screen.dart';
import '../../features/analytics/screens/analytics_dashboard_screen.dart';
import '../../features/analytics/screens/analytics_hub_screen.dart';
import '../../features/analytics/screens/performance_trends_screen.dart';
import '../../features/analytics/screens/personal_records_screen.dart';
import '../../features/community/screens/social_feed_screen.dart';
import '../../features/community/screens/friends_home_screen.dart';
import '../../features/community/screens/friend_profile_screen.dart';
import '../../features/community/screens/squads_community_screen.dart';
import '../../features/community/screens/squad_details_screen.dart';
import '../../features/community/screens/group_chat_screen.dart';
import '../../features/community/screens/community_challenges_screen.dart';
import '../../features/community/screens/leaderboard_screen.dart';
import '../../features/memories/screens/journal_dashboard_screen.dart';
import '../../features/memories/screens/journal_search_screen.dart';
import '../../features/memories/screens/collections_hub_screen.dart';
import '../../features/memories/screens/media_gallery_screen.dart';
import '../../features/memories/screens/photo_viewer_screen.dart';
import '../../features/memories/screens/voice_note_recorder_screen.dart';
import '../../features/achievements/screens/achievements_hub_screen.dart';
import '../../features/achievements/screens/goals_achievements_screen.dart';
import '../../features/sos/screens/safety_center_screen.dart';
import '../../features/sos/screens/sos_countdown_screen.dart';
import '../../features/sos/screens/emergency_contacts_screen.dart';
import '../../features/sos/screens/emergency_tracking_screen.dart';
import '../../features/sos/screens/safety_history_screen.dart';
import '../../features/sos/screens/safety_settings_screen.dart';
import '../../features/profile/screens/my_profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/settings/screens/settings_home_screen.dart';
import '../../features/settings/screens/appearance_settings_screen.dart';
import '../../features/settings/screens/privacy_security_screen.dart';
import '../../features/settings/screens/help_support_screen.dart';
import '../widgets/rm_bottom_nav.dart';

/// App route names — use these for navigation
class AppRoutes {
  static const splash           = '/';
  static const onboarding       = '/onboarding';
  static const login            = '/login';
  static const register         = '/register';
  static const otp              = '/otp';
  static const resetPassword    = '/reset-password';
  static const permission       = '/permission';
  static const privacyPolicy    = '/privacy-policy';
  static const terms            = '/terms';

  // Shell routes
  static const home             = '/home';
  static const nav              = '/nav';
  static const coach            = '/coach';
  static const stats            = '/stats';
  static const profile          = '/profile';

  // Sub-routes
  static const notifications    = '/notifications';
  static const weather          = '/weather';
  static const rideHistory      = '/rides';
  static const rides            = '/rides'; // alias
  static const rideSummary      = '/rides/summary';
  static const liveRide         = '/rides/live';
  static const rideStory        = '/rides/story';
  static const rideHud          = '/rides/hud';
  static const rideCalendar     = '/rides/calendar';
  static const rideSuccess      = '/rides/success';
  static const successRide      = '/rides/success'; // alias
  static const export           = '/rides/export';
  static const exportShare      = '/rides/export'; // alias
  static const liveNavigation   = '/nav/live';
  static const searchDest       = '/nav/search';
  static const routePlanning    = '/nav/route';
  static const routeComparison  = '/nav/compare';
  static const heatmap          = '/nav/heatmap';
  static const liveGroupMap     = '/nav/group-map';
  static const navSettings      = '/nav/settings';
  static const aiListening      = '/coach/listening';
  static const aiPreRide        = '/coach/pre-ride';
  static const aiPostRide       = '/coach/post-ride';
  static const aiCoachInsights  = '/coach/insights';
  static const aiInsightsHub    = '/coach/hub';
  static const analyticsDash    = '/stats/analytics';
  static const analyticsHub     = '/stats/hub';
  static const perfTrends       = '/stats/trends';
  static const personalRecords  = '/stats/records';
  static const socialFeed       = '/social';
  static const friends          = '/social/friends';
  static const friendProfile    = '/social/friend';
  static const squads           = '/social/squads';
  static const squadDetails     = '/social/squad';
  static const groupChat        = '/social/chat';
  static const challenges       = '/social/challenges';
  static const leaderboard      = '/social/leaderboard';
  static const journal          = '/journal';
  static const journalSearch    = '/journal/search';
  static const collections      = '/journal/collections';
  static const mediaGallery     = '/journal/gallery';
  static const photoViewer      = '/journal/photo';
  static const voiceNote        = '/journal/voice';
  static const achievements     = '/achievements';
  static const goals            = '/achievements/goals';
  static const safety           = '/safety';
  static const sos              = '/safety/sos';
  static const emergencyContacts = '/safety/contacts';
  static const emergencyTracking = '/safety/tracking';
  static const safetyHistory    = '/safety/history';
  static const safetySettings   = '/safety/settings';
  static const myProfile        = '/profile/me';
  static const editProfile      = '/profile/edit';
  static const settings         = '/settings';
  static const appearance       = '/settings/appearance';
  static const privacySecurity  = '/settings/privacy';
  static const helpSupport      = '/settings/help';
}

/// Shell scaffold with bottom nav
class _MainShell extends StatefulWidget {
  const _MainShell({required this.child, required this.navigationShell});
  final Widget child;
  final StatefulNavigationShell navigationShell;

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          RmBottomNav(
            currentIndex: widget.navigationShell.currentIndex,
            onTap: (i) => widget.navigationShell.goBranch(
              i,
              initialLocation: i == widget.navigationShell.currentIndex,
            ),
          ),
        ],
      ),
    );
  }
}

/// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // ── Auth & Onboarding ──────────────────────────────────
    GoRoute(path: AppRoutes.splash,        builder: (c, s) => const SplashScreen()),
    GoRoute(path: AppRoutes.onboarding,    builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: AppRoutes.login,         builder: (c, s) => const LoginScreen()),
    GoRoute(path: AppRoutes.register,      builder: (c, s) => const RegisterScreen()),
    GoRoute(path: AppRoutes.otp,           builder: (c, s) => const OtpScreen()),
    GoRoute(path: AppRoutes.resetPassword, builder: (c, s) => const ResetPasswordScreen()),
    GoRoute(path: AppRoutes.permission,    builder: (c, s) => const PermissionScreen()),
    GoRoute(path: AppRoutes.privacyPolicy, builder: (c, s) => const PrivacyPolicyScreen()),
    GoRoute(path: AppRoutes.terms,         builder: (c, s) => const TermsScreen()),

    // ── Main Shell (Bottom Nav) ───────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => _MainShell(
        navigationShell: navigationShell,
        child: navigationShell,
      ),
      branches: [
        // Branch 0: Home
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (c, s) => const DashboardScreen(),
            routes: [
              GoRoute(path: 'notifications', builder: (c, s) => const NotificationCenterScreen()),
              GoRoute(path: 'weather',       builder: (c, s) => const WeatherDetailsScreen()),
            ],
          ),
        ]),

        // Branch 1: Nav / Maps
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.nav,
            builder: (c, s) => const LiveNavigationScreen(),
            routes: [
              GoRoute(path: 'search',    builder: (c, s) => const SearchDestinationScreen()),
              GoRoute(path: 'route',     builder: (c, s) => const RoutePlanningScreen()),
              GoRoute(path: 'compare',   builder: (c, s) => const RouteComparisonScreen()),
              GoRoute(path: 'heatmap',   builder: (c, s) => const HeatmapExplorerScreen()),
              GoRoute(path: 'group-map', builder: (c, s) => const LiveGroupMapScreen()),
              GoRoute(path: 'settings',  builder: (c, s) => const NavigationSettingsScreen()),
            ],
          ),
        ]),

        // Branch 2: AI Coach
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.coach,
            builder: (c, s) => const AiCopilotHomeScreen(),
            routes: [
              GoRoute(path: 'listening', builder: (c, s) => const AiListeningScreen()),
              GoRoute(path: 'pre-ride',  builder: (c, s) => const AiPreRideBriefingScreen()),
              GoRoute(path: 'post-ride', builder: (c, s) => const AiPostRideAnalysisScreen()),
              GoRoute(path: 'insights',  builder: (c, s) => const AiCoachInsightsScreen()),
              GoRoute(path: 'hub',       builder: (c, s) => const AiInsightsHubScreen()),
            ],
          ),
        ]),

        // Branch 3: Stats / Analytics
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.stats,
            builder: (c, s) => const AnalyticsDashboardScreen(),
            routes: [
              GoRoute(path: 'analytics', builder: (c, s) => const AnalyticsHubScreen()),
              GoRoute(path: 'trends',    builder: (c, s) => const PerformanceTrendsScreen()),
              GoRoute(path: 'records',   builder: (c, s) => const PersonalRecordsScreen()),
            ],
          ),
        ]),

        // Branch 4: Profile
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (c, s) => const MyProfileScreen(),
            routes: [
              GoRoute(path: 'edit', builder: (c, s) => const EditProfileScreen()),
            ],
          ),
        ]),
      ],
    ),

    // ── Full-screen routes (outside shell) ────────────────
    GoRoute(path: AppRoutes.rideHistory, builder: (c, s) => const RideHistoryScreen()),
    GoRoute(path: AppRoutes.rideSummary, builder: (c, s) => const RideSummaryScreen()),
    GoRoute(path: AppRoutes.liveRide,   builder: (c, s) => const LiveRideTrackingScreen()),
    GoRoute(path: AppRoutes.rideStory,  builder: (c, s) => const RideStoryScreen()),
    GoRoute(path: AppRoutes.rideHud,    builder: (c, s) => const RideHudScreen()),
    GoRoute(path: AppRoutes.rideCalendar, builder: (c, s) => const RideCalendarScreen()),
    GoRoute(path: AppRoutes.rideSuccess, builder: (c, s) => const SuccessRideSavedScreen()),
    GoRoute(path: AppRoutes.export,     builder: (c, s) => const ExportShareScreen()),
    GoRoute(path: AppRoutes.socialFeed, builder: (c, s) => const SocialFeedScreen()),
    GoRoute(path: AppRoutes.friends,    builder: (c, s) => const FriendsHomeScreen()),
    GoRoute(path: AppRoutes.friendProfile, builder: (c, s) => const FriendProfileScreen()),
    GoRoute(path: AppRoutes.squads,     builder: (c, s) => const SquadsCommunityScreen()),
    GoRoute(path: AppRoutes.squadDetails, builder: (c, s) => const SquadDetailsScreen()),
    GoRoute(path: AppRoutes.groupChat,  builder: (c, s) => const GroupChatScreen()),
    GoRoute(path: AppRoutes.challenges, builder: (c, s) => const CommunityChallengesScreen()),
    GoRoute(path: AppRoutes.leaderboard, builder: (c, s) => const LeaderboardScreen()),
    GoRoute(path: AppRoutes.journal,    builder: (c, s) => const JournalDashboardScreen()),
    GoRoute(path: AppRoutes.journalSearch, builder: (c, s) => const JournalSearchScreen()),
    GoRoute(path: AppRoutes.collections, builder: (c, s) => const CollectionsHubScreen()),
    GoRoute(path: AppRoutes.mediaGallery, builder: (c, s) => const MediaGalleryScreen()),
    GoRoute(path: AppRoutes.photoViewer, builder: (c, s) => const PhotoViewerScreen()),
    GoRoute(path: AppRoutes.voiceNote,  builder: (c, s) => const VoiceNoteRecorderScreen()),
    GoRoute(path: AppRoutes.achievements, builder: (c, s) => const AchievementsHubScreen()),
    GoRoute(path: AppRoutes.goals,      builder: (c, s) => const GoalsAchievementsScreen()),
    GoRoute(path: AppRoutes.safety,     builder: (c, s) => const SafetyCenterScreen()),
    GoRoute(path: AppRoutes.sos,        builder: (c, s) => const SosCountdownScreen()),
    GoRoute(path: AppRoutes.emergencyContacts, builder: (c, s) => const EmergencyContactsScreen()),
    GoRoute(path: AppRoutes.emergencyTracking, builder: (c, s) => const EmergencyTrackingScreen()),
    GoRoute(path: AppRoutes.safetyHistory, builder: (c, s) => const SafetyHistoryScreen()),
    GoRoute(path: AppRoutes.safetySettings, builder: (c, s) => const SafetySettingsScreen()),
    GoRoute(path: AppRoutes.settings,   builder: (c, s) => const SettingsHomeScreen()),
    GoRoute(path: AppRoutes.appearance, builder: (c, s) => const AppearanceSettingsScreen()),
    GoRoute(path: AppRoutes.privacySecurity, builder: (c, s) => const PrivacySecurityScreen()),
    GoRoute(path: AppRoutes.helpSupport, builder: (c, s) => const HelpSupportScreen()),
  ],
);
