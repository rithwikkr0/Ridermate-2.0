import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'rm_nav_controller.dart';

/// Wraps any scrollable content and automatically hides / shows the
/// global bottom nav bar via [RmNavScope].
///
/// Place this as a direct child of [Stack] in your screen body, wrapping
/// your [SingleChildScrollView], [CustomScrollView], or [ListView].
class RmScrollBody extends StatefulWidget {
  const RmScrollBody({super.key, required this.child});
  final Widget child;

  @override
  State<RmScrollBody> createState() => _RmScrollBodyState();
}

class _RmScrollBodyState extends State<RmScrollBody> {
  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final ctrl = RmNavScope.maybeOf(context);
    if (ctrl == null) return false;

    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        ctrl.hide();
      } else if (notification.direction == ScrollDirection.forward ||
          notification.direction == ScrollDirection.idle) {
        ctrl.show();
      }
    } else if (notification is ScrollEndNotification) {
      // Re-show nav when user reaches the very top
      if (notification.metrics.pixels <=
          notification.metrics.minScrollExtent + 1) {
        ctrl.show();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: widget.child,
    );
  }
}
