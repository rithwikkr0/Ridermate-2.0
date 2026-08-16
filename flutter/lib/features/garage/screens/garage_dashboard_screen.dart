import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

import '../controllers/garage_controller.dart';
import '../models/garage_models.dart';

/// RiderMate 2.0 — Comprehensive Garage & Vehicle Management Dashboard Screen
class GarageDashboardScreen extends StatefulWidget {
  const GarageDashboardScreen({super.key});

  @override
  State<GarageDashboardScreen> createState() => _GarageDashboardScreenState();
}

class _GarageDashboardScreenState extends State<GarageDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GarageController>();
    final primaryVehicle = controller.primaryVehicle;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Garage',
          style: AppTextStyles.headlineMd(color: AppColors.onSurface),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.circuitOrange),
            onPressed: () => _showAddVehicleDialog(context),
            tooltip: 'Add Vehicle',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.circuitOrange,
          labelColor: AppColors.circuitOrange,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Primary Vehicle'),
            Tab(text: 'My Vehicles'),
            Tab(text: 'Service History'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.6, -0.4),
                radius: 1.2,
                colors: [Color(0x1AFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPrimaryVehicleTab(context, controller, primaryVehicle),
                _buildVehiclesListTab(context, controller),
                _buildServiceHistoryTab(context, controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryVehicleTab(
    BuildContext context,
    GarageController controller,
    VehicleModel? vehicle,
  ) {
    if (vehicle == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.two_wheeler_rounded, size: 64, color: AppColors.onSurfaceVariant),
              const SizedBox(height: AppSpacing.md),
              Text('No Vehicles in Garage', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
              const SizedBox(height: 6),
              Text('Add your motorcycle or scooter to track service, insurance, and PUC status.',
                  style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.circuitOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () => _showAddVehicleDialog(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Vehicle Now', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.md,
        AppSpacing.marginMobile,
        100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Header Card
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.circuitOrange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler_rounded, size: 36, color: AppColors.circuitOrange),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${vehicle.brand} ${vehicle.model}', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                            Text('${vehicle.registrationNumber.isNotEmpty ? vehicle.maskedRegistrationNumber : "REG NOT SET"} • ${vehicle.year} • ${vehicle.fuelType}',
                                style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickMetric('ODOMETER', '${vehicle.odometerKm.toStringAsFixed(0)} km'),
                      _buildQuickMetric('SERVICE DUE', '${vehicle.serviceKmRemaining.toStringAsFixed(0)} km'),
                      _buildQuickMetric('ENGINE', '${vehicle.engineCc} cc'),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: AppSpacing.xl),

          // Status Cards Grid (Service, Insurance, PUC, Challan)
          _buildSectionHeader('VEHICLE COMPLIANCE & SERVICE STATUS'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  title: 'SERVICE',
                  status: vehicle.isServiceDue ? 'DUE NOW' : 'OK',
                  subtitle: '${vehicle.serviceKmRemaining.toStringAsFixed(0)} km left',
                  icon: Icons.build_rounded,
                  color: vehicle.isServiceDue ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatusCard(
                  title: 'INSURANCE',
                  status: vehicle.isInsuranceExpired
                      ? 'EXPIRED'
                      : (vehicle.isInsuranceExpiringSoon ? 'EXPIRING' : 'VALID'),
                  subtitle: vehicle.insuranceDaysRemaining != null
                      ? '${vehicle.insuranceDaysRemaining} days'
                      : 'Not set',
                  icon: Icons.verified_user_rounded,
                  color: vehicle.isInsuranceExpired
                      ? Colors.redAccent
                      : (vehicle.isInsuranceExpiringSoon ? Colors.amber : Colors.greenAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  title: 'PUC TEST',
                  status: vehicle.isPucExpired
                      ? 'EXPIRED'
                      : (vehicle.isPucExpiringSoon ? 'EXPIRING' : 'VALID'),
                  subtitle: vehicle.pucDaysRemaining != null
                      ? '${vehicle.pucDaysRemaining} days'
                      : 'Not set',
                  icon: Icons.eco_rounded,
                  color: vehicle.isPucExpired
                      ? Colors.redAccent
                      : (vehicle.isPucExpiringSoon ? Colors.amber : Colors.greenAccent),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatusCard(
                  title: 'CHALLANS',
                  status: 'CHECK',
                  subtitle: 'Manual Lookup',
                  icon: Icons.gavel_rounded,
                  color: Colors.lightBlueAccent,
                  onTap: () => _showChallanDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.circuitOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _showAddServiceRecordDialog(context, vehicle),
                  icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                  label: const Text('Log Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.glassBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _showUpdateOdometerDialog(context, vehicle),
                  icon: const Icon(Icons.speed_rounded, color: AppColors.onSurface),
                  label: const Text('Update Odometer', style: TextStyle(color: AppColors.onSurface)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesListTab(BuildContext context, GarageController controller) {
    final vehicles = controller.vehicles;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final v = vehicles[index];
        final isPrimary = v.id == controller.primaryVehicle?.id;
        return GlassCard(
          child: ListTile(
            leading: Icon(
              Icons.two_wheeler_rounded,
              color: isPrimary ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
              size: 32,
            ),
            title: Text('${v.brand} ${v.model}', style: AppTextStyles.headlineSm()),
            subtitle: Text('Odometer: ${v.odometerKm.toStringAsFixed(0)} km • ${v.maskedRegistrationNumber}',
                style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
            trailing: isPrimary
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.circuitOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.circuitOrange),
                    ),
                    child: const Text('PRIMARY', style: TextStyle(color: AppColors.circuitOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                : TextButton(
                    onPressed: () => controller.setPrimaryVehicle(v.id),
                    child: const Text('Make Primary', style: TextStyle(color: AppColors.circuitOrange)),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildServiceHistoryTab(BuildContext context, GarageController controller) {
    final history = controller.serviceHistory;

    if (history.isEmpty) {
      return Center(
        child: Text('No service records logged for this vehicle.',
            style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = history[index];
        return GlassCard(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.circuitOrange,
              child: Icon(Icons.build, color: Colors.white, size: 20),
            ),
            title: Text(item.serviceType, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
            subtitle: Text('Odo: ${item.odometer.toStringAsFixed(0)} km • ${item.workshopName}',
                style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
            trailing: Text('₹${item.cost.toStringAsFixed(0)}', style: AppTextStyles.statLabel(color: Colors.greenAccent)),
          ),
        );
      },
    );
  }

  Widget _buildQuickMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineSm(color: AppColors.circuitOrange)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String status,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 20),
                  Text(status, style: AppTextStyles.statLabel(color: color)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySm(color: AppColors.onSurface)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(title, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    final brandCtrl = TextEditingController(text: 'Royal Enfield');
    final modelCtrl = TextEditingController(text: 'Classic 350');
    final regCtrl = TextEditingController(text: 'KA01AB1234');
    final odoCtrl = TextEditingController(text: '12450');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Vehicle to Garage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Authorized API Warning Banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Automatic vehicle verification is currently unavailable. Enter details manually.',
                        style: TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brandCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Brand (e.g. Royal Enfield)', labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: modelCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Model (e.g. Classic 350)', labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: regCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Reg Number (e.g. KA01AB1234)', labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: odoCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Current Odometer (km)', labelStyle: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
            onPressed: () {
              final newVehicle = VehicleModel(
                id: 'veh_${DateTime.now().millisecondsSinceEpoch}',
                userId: '',
                brand: brandCtrl.text.trim(),
                model: modelCtrl.text.trim(),
                year: 2024,
                registrationNumber: regCtrl.text.trim().toUpperCase(),
                odometerKm: double.tryParse(odoCtrl.text.trim()) ?? 0.0,
                insuranceExpiry: DateTime.now().add(const Duration(days: 180)),
                pucExpiry: DateTime.now().add(const Duration(days: 90)),
                lastServiceDate: DateTime.now().subtract(const Duration(days: 30)),
                isPrimary: true,
              );
              context.read<GarageController>().saveVehicle(newVehicle);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Vehicle', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddServiceRecordDialog(BuildContext context, VehicleModel vehicle) {
    final typeCtrl = TextEditingController(text: 'General Service');
    final odoCtrl = TextEditingController(text: vehicle.odometerKm.toStringAsFixed(0));
    final costCtrl = TextEditingController(text: '2500');
    final workshopCtrl = TextEditingController(text: 'Authorized Service Center');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Maintenance / Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Service Type', labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: odoCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Odometer (km)', labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Cost (₹)', labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: workshopCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Workshop / Mechanic', labelStyle: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
            onPressed: () {
              final rec = MaintenanceRecord(
                id: 'maint_${DateTime.now().millisecondsSinceEpoch}',
                vehicleId: vehicle.id,
                userId: '',
                serviceType: typeCtrl.text.trim(),
                date: DateTime.now(),
                odometer: double.tryParse(odoCtrl.text.trim()) ?? vehicle.odometerKm,
                cost: double.tryParse(costCtrl.text.trim()) ?? 0.0,
                workshopName: workshopCtrl.text.trim(),
                createdAt: DateTime.now(),
              );
              context.read<GarageController>().addMaintenanceRecord(rec);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Record', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateOdometerDialog(BuildContext context, VehicleModel vehicle) {
    final odoCtrl = TextEditingController(text: vehicle.odometerKm.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Vehicle Odometer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: odoCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'New Odometer (km)', labelStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
            onPressed: () {
              final newOdo = double.tryParse(odoCtrl.text.trim()) ?? vehicle.odometerKm;
              final updated = vehicle.copyWith(odometerKm: newOdo);
              context.read<GarageController>().saveVehicle(updated);
              Navigator.of(ctx).pop();
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChallanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Traffic Challan Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Automatic government challan lookup is currently unavailable without an official API key.\n\nPlease visit the official Parivahan e-Challan portal to check pending challans safely.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
