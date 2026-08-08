import 'package:flutter/material.dart';

/// Global notifier for bottom nav visibility.
/// Exposed to the widget tree via [RmNavScope].
class RmNavController extends ChangeNotifier {
  bool _visible = true;
  bool get visible => _visible;

  void show() {
    if (!_visible) {
      _visible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (_visible) {
      _visible = false;
      notifyListeners();
    }
  }

  /// Force-show — called when user taps a nav tab.
  void forceShow() {
    _visible = true;
    notifyListeners();
  }
}

/// InheritedWidget that exposes [RmNavController] to the subtree.
class RmNavScope extends InheritedNotifier<RmNavController> {
  const RmNavScope({
    super.key,
    required RmNavController controller,
    required super.child,
  }) : super(notifier: controller);

  static RmNavController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RmNavScope>()
        ?.notifier;
  }

  static RmNavController of(BuildContext context) {
    final ctrl = maybeOf(context);
    assert(ctrl != null, 'RmNavScope not found in widget tree');
    return ctrl!;
  }
}
