import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../theme.dart';

class VideoRecorderWidget extends StatefulWidget {
  final String? videoPath;
  final Function(String)? onRecordComplete;
  final VoidCallback? onDelete;

  const VideoRecorderWidget({
    super.key,
    this.videoPath,
    this.onRecordComplete,
    this.onDelete,
  });

  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;
  String? _recordedPath;
  bool _isRecording = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _recordedPath = widget.videoPath;
    if (_recordedPath == null && widget.onRecordComplete != null) {
      _initializeCamera();
    } else if (_recordedPath != null) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_recordedPath == null) return;

    _videoPlayerController = VideoPlayerController.file(File(_recordedPath!));
    await _videoPlayerController!.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _cameraController!.startVideoRecording();

      setState(() => _isRecording = true);
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;

    try {
      final file = await _cameraController!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _recordedPath = file.path;
      });

      await _cameraController?.dispose();
      _cameraController = null;
      _isInitialized = false;

      await _initializeVideoPlayer();

      if (widget.onRecordComplete != null) {
        widget.onRecordComplete!(_recordedPath!);
      }
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  void _deleteRecording() {
    if (_recordedPath != null) {
      final file = File(_recordedPath!);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    _videoPlayerController?.dispose();
    _videoPlayerController = null;

    setState(() => _recordedPath = null);
    widget.onDelete?.call();
  }

  Future<void> _togglePlayback() async {
    if (_videoPlayerController == null) return;

    if (_videoPlayerController!.value.isPlaying) {
      await _videoPlayerController!.pause();
    } else {
      await _videoPlayerController!.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_recordedPath != null) {
      return _buildPlaybackWidget();
    } else if (_isInitialized) {
      return _buildRecordingWidget();
    } else {
      return _buildLoadingWidget();
    }
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.surfaceBlack1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryAccent),
      ),
    );
  }

  Widget _buildRecordingWidget() {
    if (_cameraController == null) return const SizedBox.shrink();

    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox.expand(child: CameraPreview(_cameraController!)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRecording)
                      ElevatedButton.icon(
                        onPressed: _startRecording,
                        icon: const Icon(Icons.fiber_manual_record),
                        label: const Text('Start Recording'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.negative,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Recording'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.negative,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isRecording)
              const Positioned(
                top: 24,
                right: 24,
                child: Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      color: AppTheme.negative,
                      size: 12,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Recording',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackWidget() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return _buildLoadingWidget();
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.positive.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox.expand(child: VideoPlayer(_videoPlayerController!)),
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _videoPlayerController!.value.isPlaying
                          ? 0.0
                          : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.positive.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Video Recording',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.negative,
                      ),
                      onPressed: _deleteRecording,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
