import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/rm_text_field.dart';

class VoiceNoteRecorderScreen extends StatefulWidget {
  const VoiceNoteRecorderScreen({super.key});

  @override
  State<VoiceNoteRecorderScreen> createState() => _VoiceNoteRecorderScreenState();
}

class _VoiceNoteRecorderScreenState extends State<VoiceNoteRecorderScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final TextEditingController _titleController = TextEditingController();

  bool isRecording = false;
  bool isPlaying = false;
  String? recordedFilePath;
  int seconds = 0;
  Timer? timer;

  Future<void> toggleRecording() async {
    if (isRecording) {
      // Stop recording
      timer?.cancel();
      try {
        final path = await _recorder.stop();
        setState(() {
          isRecording = false;
          recordedFilePath = path;
        });
      } catch (_) {
        setState(() => isRecording = false);
      }
    } else {
      // Start recording
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required to record voice notes.')),
          );
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      setState(() {
        isRecording = true;
        seconds = 0;
        recordedFilePath = null;
      });

      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted) setState(() => seconds++);
      });
    }
  }

  void _togglePlayback() {
    if (recordedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record a voice note first before playing.')),
      );
      return;
    }
    setState(() => isPlaying = !isPlaying);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPlaying ? 'Playing voice note preview...' : 'Playback paused'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveVoiceNote() {
    final title = _titleController.text.trim().isEmpty ? 'Ride Memory Note' : _titleController.text.trim();
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice note "$title" saved to memories!'),
        backgroundColor: AppColors.circuitOrange,
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _recorder.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = '00:${seconds.toString().padLeft(2, '0')}';
    if (seconds >= 60) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      formattedTime = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('New Voice Note', style: AppTextStyles.headlineSm()),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: 1.2,
                colors: [Color(0x1AFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RmTextField(
                    controller: _titleController,
                    hintText: 'Note Title',
                  ).animate().fadeIn().slideY(begin: -0.1),
                  
                  const Spacer(),
                  
                  // Animated Waveform
                  SizedBox(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(20, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8,
                          height: isRecording ? 20.0 + Random().nextDouble() * 80 : 10.0,
                          decoration: BoxDecoration(
                            color: AppColors.circuitOrange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text(formattedTime, style: AppTextStyles.headlineLg().copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  
                  const Spacer(),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerHigh,
                        ),
                        child: IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.onSurfaceVariant),
                          onPressed: _togglePlayback,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      GestureDetector(
                        onTap: toggleRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecording ? Colors.redAccent : AppColors.circuitOrange,
                            boxShadow: [
                              BoxShadow(
                                color: (isRecording ? Colors.redAccent : AppColors.circuitOrange).withValues(alpha: 0.3),
                                blurRadius: 24,
                                spreadRadius: 8,
                              )
                            ],
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerHigh,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.check, color: AppColors.circuitOrange),
                          onPressed: _saveVoiceNote,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
