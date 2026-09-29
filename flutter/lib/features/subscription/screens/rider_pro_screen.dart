import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/monetization/revenuecat_controller.dart';

class RiderProScreen extends StatelessWidget {
  const RiderProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RevenueCatController>();
    final packages =
        controller.offerings?.current?.availablePackages ?? const <Package>[];

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      appBar: AppBar(
        title: const Text('RiderMate Pro'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Ride smarter. Keep safety free.',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Text(
            'Unlock advanced rider intelligence without putting SOS or essential safety features behind a paywall.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 20),
          const _Feature('Advanced ride analytics'),
          const _Feature('AI ride insights'),
          const _Feature('Advanced vehicle intelligence'),
          const _Feature('Long-term rider trends'),
          const _Feature('Enhanced cloud features'),
          const SizedBox(height: 20),
          if (controller.isPro)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('RiderMate Pro is active.'),
              ),
            )
          else if (!controller.isConfigured)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'RevenueCat is not configured. Build with '
                  '--dart-define=REVENUECAT_ANDROID_API_KEY=...',
                ),
              ),
            )
          else if (packages.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'No packages are available. Configure the RiderMate '
                  'products and default offering in RevenueCat.',
                ),
              ),
            )
          else
            ...packages.map(
              (pkg) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton(
                  onPressed: controller.loading ? null : () => controller.purchase(pkg),
                  child: Text(
                    'Unlock ${pkg.storeProduct.title} • ${pkg.storeProduct.priceString}',
                  ),
                ),
              ),
            ),
          OutlinedButton(
            onPressed: controller.loading ? null : controller.restore,
            child: const Text('Restore purchases'),
          ),
          if (controller.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                controller.error!,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.check_circle, color: Color(0xFFFF6B00)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        contentPadding: EdgeInsets.zero,
      );
}
