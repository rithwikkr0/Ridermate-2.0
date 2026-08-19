import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class ReportDialog extends StatefulWidget {
  final String itemId;
  final String itemType; // 'post', 'comment', 'user'
  final Future<void> Function(String reason, String details) onReport;

  const ReportDialog({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.onReport,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  static const _reasons = [
    'Spam or Scam',
    'Harassment or Hate Speech',
    'Dangerous Riding / Stunts',
    'Inappropriate Content',
    'Violence or Threats',
    'Other Issue',
  ];

  String _selectedReason = _reasons.first;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.onReport(_selectedReason, _detailsController.text.trim());
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you for keeping RiderMate safe.'),
            backgroundColor: AppColors.surfaceContainerHigh,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Report ${widget.itemType.toUpperCase()}', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why are you reporting this?', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            ..._reasons.map((reason) {
              final isSelected = _selectedReason == reason;
              return GestureDetector(
                onTap: () => setState(() => _selectedReason = reason),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          reason,
                          style: AppTextStyles.bodyMd(
                            color: isSelected ? AppColors.circuitOrange : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _detailsController,
              maxLines: 2,
              style: AppTextStyles.bodySm(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Additional details (optional)...',
                hintStyle: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('CANCEL', style: AppTextStyles.button(color: AppColors.onSurfaceVariant)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('SUBMIT REPORT', style: AppTextStyles.button(color: Colors.white)),
        ),
      ],
    );
  }
}
