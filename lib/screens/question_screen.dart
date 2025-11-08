import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/experience_provider.dart';
import '../theme.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/video_recorder_widget.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answerState = ref.watch(questionAnswerProvider);
    final hasAudio = answerState.audioPath != null;
    final hasVideo = answerState.videoPath != null;

    return Scaffold(
      backgroundColor: AppTheme.base2Dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text1),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildProgressIndicator(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.text1),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '02',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.text4.withOpacity(0.24),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Why do you want to host with us?',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tell us about your intent and what motivates you to create experiences.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.text3.withOpacity(0.46),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTextAnswerField(),
                  const SizedBox(height: 24),
                  if (hasAudio) ...[
                    AudioRecorderWidget(
                      audioPath: answerState.audioPath,
                      onDelete: () {
                        ref.read(questionAnswerProvider.notifier).clearAudio();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (hasVideo) ...[
                    VideoRecorderWidget(
                      videoPath: answerState.videoPath,
                      onDelete: () {
                        ref.read(questionAnswerProvider.notifier).clearVideo();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          _buildActionButtons(hasAudio, hasVideo),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4,
      width: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAnswerField() {
    return TextField(
      controller: _textController,
      maxLines: 6,
      maxLength: 600,
      style: const TextStyle(color: AppTheme.text1),
      decoration: InputDecoration(
        hintText: '/ Start typing here',
        hintStyle: TextStyle(color: AppTheme.text3.withOpacity(0.46)),
        counterStyle: TextStyle(color: AppTheme.text4.withOpacity(0.24)),
      ),
      onChanged: (value) {
        ref.read(questionAnswerProvider.notifier).updateTextAnswer(value);
      },
    );
  }

  Widget _buildActionButtons(bool hasAudio, bool hasVideo) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.base2Dark,
        border: Border(
          top: BorderSide(color: AppTheme.border1.withOpacity(0.08), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Audio Button
            if (!hasAudio)
              _buildCircleButton(
                icon: Icons.mic,
                onPressed: () => _showAudioRecorder(),
              ),
            if (!hasAudio) const SizedBox(width: 12),

            // Video Button
            if (!hasVideo)
              _buildCircleButton(
                icon: Icons.videocam,
                onPressed: () => _showVideoRecorder(),
              ),
            if (!hasVideo) const SizedBox(width: 12),

            // Next Button
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: AppTheme.text1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite1.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border1.withOpacity(0.08)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.text1),
        onPressed: onPressed,
      ),
    );
  }

  void _showAudioRecorder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.base2Dark,
      isScrollControlled: true,
      builder: (context) => AudioRecorderWidget(
        onRecordComplete: (path) {
          ref.read(questionAnswerProvider.notifier).setAudioPath(path);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showVideoRecorder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.base2Dark,
      isScrollControlled: true,
      builder: (context) => VideoRecorderWidget(
        onRecordComplete: (path) {
          ref.read(questionAnswerProvider.notifier).setVideoPath(path);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleNext() {
    final answerState = ref.read(questionAnswerProvider);

    // Log the complete state
    print('=== Question Answer ===');
    print('Text Answer: ${answerState.textAnswer}');
    print('Audio Path: ${answerState.audioPath}');
    print('Video Path: ${answerState.videoPath}');

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceBlack1,
        title: const Text(
          'Submission Complete',
          style: TextStyle(color: AppTheme.text1),
        ),
        content: const Text(
          'Your answers have been recorded. Check the console for logged data.',
          style: TextStyle(color: AppTheme.text2),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
