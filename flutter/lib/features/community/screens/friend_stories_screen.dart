import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class FriendStoryItem {
  final String id;
  final String friendName;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final String location;
  final String rideStats;
  final DateTime timestamp;

  const FriendStoryItem({
    required this.id,
    required this.friendName,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.location,
    required this.rideStats,
    required this.timestamp,
  });
}

/// RiderMate 2.0 — Snapchat-Inspired Full-Screen Friend Memory Story Viewer
class FriendStoriesScreen extends StatefulWidget {
  final List<FriendStoryItem>? stories;
  final int initialIndex;

  const FriendStoriesScreen({
    super.key,
    this.stories,
    this.initialIndex = 0,
  });

  @override
  State<FriendStoriesScreen> createState() => _FriendStoriesScreenState();
}

class _FriendStoriesScreenState extends State<FriendStoriesScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  late List<FriendStoryItem> _storyList;

  @override
  void initState() {
    super.initState();
    _storyList = widget.stories ?? _getDemoStories();
    _currentIndex = widget.initialIndex.clamp(0, _storyList.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });

    _progressController.forward();
  }

  List<FriendStoryItem> _getDemoStories() {
    return [
      FriendStoryItem(
        id: 's1',
        friendName: 'Alex Rivera',
        avatarUrl: '',
        imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc',
        caption: 'Conquered Western Ghats twisties! 🏍️⚡',
        location: 'Western Ghats, MH',
        rideStats: '142 km • 68 km/h avg',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      FriendStoryItem(
        id: 's2',
        friendName: 'Sarah Chen',
        avatarUrl: '',
        imageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87',
        caption: 'Sunset coastal ride on the highway 🌅',
        location: 'Marine Drive, Mumbai',
        rideStats: '45 km • 52 km/h avg',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  void _nextStory() {
    if (_currentIndex < _storyList.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
    } else {
      context.pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.reset();
      _progressController.forward();
    } else {
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_storyList.isEmpty) return const SizedBox();

    final currentStory = _storyList[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth * 0.3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Full Screen Image/Content
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _storyList.length,
              itemBuilder: (context, index) {
                final story = _storyList[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      story.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => Container(
                        color: const Color(0xFF1C1C1E),
                        child: const Center(
                          child: Icon(Icons.directions_bike_rounded, size: 80, color: AppColors.circuitOrange),
                        ),
                      ),
                    ),
                    // Gradient overlays
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xD9000000), // ~85% black
                              Colors.transparent,
                              Colors.transparent,
                              Color(0xE6000000), // ~90% black
                            ],
                            stops: [0.0, 0.25, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top Header: Story Segmented Progress Bar & User Info
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Segmented Progress Bar
                    Row(
                      children: List.generate(_storyList.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                double progress = 0.0;
                                if (index < _currentIndex) {
                                  progress = 1.0;
                                } else if (index == _currentIndex) {
                                  progress = _progressController.value;
                                }
                                return LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white24,
                                  color: AppColors.circuitOrange,
                                  minHeight: 3,
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // User Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.circuitOrange,
                          child: Text(
                            currentStory.friendName.substring(0, 1),
                            style: AppTextStyles.headlineSm(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentStory.friendName, style: AppTextStyles.headlineSm(color: Colors.white)),
                            Text(currentStory.location, style: AppTextStyles.caption(color: Colors.white70)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Story Overlay: Geotag, Stats, Caption & Reply Bar
            Positioned(
              bottom: 40,
              left: AppSpacing.marginMobile,
              right: AppSpacing.marginMobile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStory.rideStats.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.circuitOrange.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.circuitOrange),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_bike, size: 14, color: AppColors.circuitOrange),
                          const SizedBox(width: 6),
                          Text(currentStory.rideStats, style: AppTextStyles.statLabel(color: Colors.white)),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    currentStory.caption,
                    style: AppTextStyles.headlineMd(color: Colors.white),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.md),
                  // Reaction bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: Colors.white.withValues(alpha: 0.15),
                              child: Text(
                                'Send reaction...',
                                style: AppTextStyles.bodySm(color: Colors.white70),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 28),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❤️ Reaction sent to rider!'),
                              backgroundColor: AppColors.circuitOrange,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppColors.circuitOrange, size: 28),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Story reply sent to chat!'),
                              backgroundColor: AppColors.circuitOrange,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
