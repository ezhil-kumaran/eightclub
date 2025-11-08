import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import '../theme.dart';

class AudioRecorderWidget extends StatefulWidget {
  final String? audioPath;
  final Function(String)? onRecordComplete;
  final VoidCallback? onDelete;

  const AudioRecorderWidget({
    Key? key,
    this.audioPath,
    this.onRecordComplete,
    this.onDelete,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  FlutterSoundRecorder? _audioRecorder;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedPath;
  int _recordDuration = 0;
  Timer? _timer;
  List<double> _waveformData = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _recordedPath = widget.audioPath;
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _audioRecorder = FlutterSoundRecorder();

    try {
      await _audioRecorder!.openRecorder();
      setState(() => _isInitialized = true);

      if (_recordedPath == null && widget.onRecordComplete != null) {
        await _checkPermissionAndRecord();
      }
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder?.closeRecorder();
    _audioRecorder = null;
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionAndRecord() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _startRecording();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required'),
            backgroundColor: AppTheme.negative,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (_audioRecorder == null || !_isInitialized) {
      print('Recorder not initialized');
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder!.startRecorder(toFile: path, codec: Codec.aacADTS);

      setState(() {
        _isRecording = true;
        _recordDuration = 0;
        _recordedPath = path;
      });

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (mounted) {
          setState(() {
            _recordDuration += 100;
            // Simulate waveform data
            _waveformData.add((timer.tick % 10) / 10);
            if (_waveformData.length > 50) {
              _waveformData.removeAt(0);
            }
          });
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recording error: ${e.toString()}'),
            backgroundColor: AppTheme.negative,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_audioRecorder == null || !_isRecording) return;

    try {
      await _audioRecorder!.stopRecorder();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
      });

      if (_recordedPath != null && widget.onRecordComplete != null) {
        widget.onRecordComplete!(_recordedPath!);
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _cancelRecording() async {
    if (_audioRecorder != null && _isRecording) {
      await _audioRecorder!.stopRecorder();
    }
    _timer?.cancel();

    // Delete the file
    if (_recordedPath != null) {
      try {
        final file = File(_recordedPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting file: $e');
      }
    }

    setState(() {
      _isRecording = false;
      _recordDuration = 0;
      _waveformData.clear();
      _recordedPath = null;
    });

    if (widget.onRecordComplete != null && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordedPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play(DeviceFileSource(_recordedPath!));
        setState(() => _isPlaying = true);

        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        });
      }
    } catch (e) {
      print('Playback error: $e');
    }
  }

  void _deleteRecording() {
    if (_recordedPath != null) {
      try {
        final file = File(_recordedPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Delete error: $e');
      }
    }
    setState(() {
      _recordedPath = null;
      _recordDuration = 0;
      _waveformData.clear();
    });
    widget.onDelete?.call();
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryAccent),
        ),
      );
    }

    if (_recordedPath != null && widget.onRecordComplete == null) {
      return _buildPlaybackWidget();
    } else if (_isRecording) {
      return _buildRecordingWidget();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildRecordingWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite1.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border1.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.negative.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.stop, color: AppTheme.negative),
                  onPressed: _stopRecording,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recording Audio...',
                      style: TextStyle(
                        color: AppTheme.text1,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildWaveform(),
                  ],
                ),
              ),
              Text(
                _formatDuration(_recordDuration),
                style: TextStyle(
                  color: AppTheme.text3.withOpacity(0.46),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _cancelRecording,
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.text3.withOpacity(0.46)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(30, (index) {
          final value = index < _waveformData.length
              ? _waveformData[index]
              : 0.2;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
              height: 40 * value,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlaybackWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite1.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.positive.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.positive.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppTheme.positive,
              ),
              onPressed: _togglePlayback,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Recording',
                  style: TextStyle(
                    color: AppTheme.text1,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(_recordDuration),
                  style: TextStyle(
                    color: AppTheme.text3.withOpacity(0.46),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.negative),
            onPressed: _deleteRecording,
          ),
        ],
      ),
    );
  }
}
