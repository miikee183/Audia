import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../providers/audio_provider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasRecording = false;
  String? _recordedPath;
  double? _recordedDuration;
  bool _isUploading = false;
  DateTime? _recordingStart;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      final duration = _recordingStart != null
          ? DateTime.now().difference(_recordingStart!).inMilliseconds / 1000.0
          : 0.0;
      if (path != null && mounted) {
        setState(() {
          _isRecording = false;
          _hasRecording = true;
          _recordedPath = path;
          _recordedDuration = duration;
        });
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de micrófono requerido')),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/audia_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      if (mounted) {
        setState(() {
          _isRecording = true;
          _hasRecording = false;
          _recordedPath = null;
          _recordedDuration = null;
          _recordingStart = DateTime.now();
        });
      }
    }
  }

  Future<void> _uploadRecording() async {
    if (_recordedPath == null) return;
    setState(() => _isUploading = true);
    try {
      final audioService = AudioService();
      await audioService.uploadAudio(
        _recordedPath!,
        _recordedDuration ?? 0.0,
      );
      audioService.dispose();
      if (mounted) {
        setState(() {
          _isUploading = false;
          _hasRecording = false;
          _recordedPath = null;
          _recordedDuration = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio subido con éxito'), backgroundColor: AppTheme.surfaceColor),
        );
        context.read<AudioProvider>().loadAudios('para_ti');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e}'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }

  String _formatDuration(double seconds) {
    final m = seconds ~/ 60;
    final s = seconds.round() % 60;
    return '${m}:${s.toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabar', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isUploading ? null : _toggleRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? Colors.red.withAlpha(60)
                      : AppTheme.primaryColor.withAlpha(40),
                  border: Border.all(
                    color: _isRecording ? Colors.red : AppTheme.primaryColor,
                    width: 3,
                  ),
                ),
                child: _isRecording
                    ? const Icon(Icons.stop, size: 56, color: Colors.red)
                    : const Icon(Icons.mic, size: 56, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isRecording ? 'Grabando...' : (_hasRecording ? 'Grabación lista' : 'Toca para grabar'),
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
            if (_recordedDuration != null) ...[
              const SizedBox(height: 8),
              Text(
                _formatDuration(_recordedDuration!),
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
            if (_hasRecording) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadRecording,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Subiendo...' : 'Subir audio'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
