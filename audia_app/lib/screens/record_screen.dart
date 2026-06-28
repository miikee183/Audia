import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import 'publish_audio_screen.dart';

const _maxDuration = 60;
const _micSize = 120.0;
const _lockSize = 56.0;
const _lockSizeHover = 72.0;

enum _PlaybackSpeed { x1, x1_5, x2 }

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final GlobalKey _micKey = GlobalKey();
  final GlobalKey _lockKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  bool _isRecording = false;
  bool _isLocked = false;
  double _progress = 0.0;
  Timer? _timer;
  DateTime? _recordingStart;

  bool _hasRecording = false;
  String? _recordedPath;
  double? _recordedDuration;
  bool _isUploading = false;

  bool _showLock = false;
  bool _micTouched = false;
  bool _overLock = false;

  bool _isPlaying = false;
  Duration _pos = Duration.zero;
  Duration? _dur;
  _PlaybackSpeed _speed = _PlaybackSpeed.x1;
  StreamSubscription? _posSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _durSub;

  bool _permissionGranted = false;

  double get _speedValue => _speed == _PlaybackSpeed.x1
      ? 1.0
      : _speed == _PlaybackSpeed.x1_5 ? 1.5 : 2.0;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _posSub = _player.positionStream.listen((p) {
      if (mounted) setState(() => _pos = p);
    });
    _durSub = _player.durationStream.listen((d) {
      if (mounted) setState(() => _dur = d);
    });
    _stateSub = _player.playerStateStream.listen((s) {
      if (mounted) setState(() => _isPlaying = s.playing);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _posSub?.cancel();
    _stateSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final ok = await _recorder.hasPermission(request: true);
    if (mounted) setState(() => _permissionGranted = ok);
  }

  String _fmt(double sec) {
    final m = sec ~/ 60;
    final s = sec.round() % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    if (!_permissionGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.micPermission)),
        );
      }
      return;
    }
    if (_hasRecording) {
      await _player.stop();
      _hasRecording = false;
      _recordedPath = null;
      _recordedDuration = null;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/audia_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _isLocked = false;
      _showLock = true;
      _overLock = false;
      _progress = 0.0;
      _recordingStart = DateTime.now();
      _recordedPath = path;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) { t.cancel(); return; }
      final e = DateTime.now().difference(_recordingStart!).inMilliseconds / 1000;
      setState(() => _progress = (e / _maxDuration).clamp(0.0, 1.0));
      if (e >= _maxDuration) {
        t.cancel();
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    final dur = _recordingStart != null
        ? DateTime.now().difference(_recordingStart!).inMilliseconds / 1000
        : 0.0;
    setState(() {
      _isRecording = false;
      _isLocked = false;
      _showLock = false;
      _overLock = false;
      _micTouched = false;
      _progress = 0.0;
    });
    if (path != null && dur > 1.0) {
      _recordedPath = path;
      _recordedDuration = dur;
      if (mounted) {
        setState(() => _hasRecording = true);
        await _player.setFilePath(path);
        await _player.setSpeed(_speedValue);
        await _player.setLoopMode(LoopMode.one);
      }
    }
  }

  void _onPointerDown(PointerEvent e) {
    if (_isUploading) return;
    // Touch is already on the mic (mic's own Listener fires this).
    // Convert touch Y from mic-local to Stack-local so _onPointerMove
    // (from the outer Listener) can compute offsets in the same space.
    _micTouched = true;
    _startRecording();
  }

  void _onPointerMove(PointerEvent e) {
    if (!_micTouched || !_isRecording || _isLocked) return;

    final lockBox = _lockKey.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (lockBox != null && lockBox.hasSize && stackBox != null && stackBox.hasSize) {
      final lockCenter = lockBox.localToGlobal(lockBox.size.center(Offset.zero));
      final lockCenterLocal = stackBox.globalToLocal(lockCenter);
      final pointerPos = e.position;
      final dist = (pointerPos - lockCenterLocal).distance;
      final hit = dist < lockBox.size.width / 2 + 40;

      if (hit != _overLock || hit) {
        setState(() {
          _overLock = hit;
          if (hit) _isLocked = true;
        });
      }
    }
  }

  void _onPointerUp(PointerEvent e) {
    if (!_micTouched) return;
    _micTouched = false;
    setState(() => _overLock = false);
    if (!_isLocked) {
      _stopRecording();
    }
  }

  void _togglePlay() async {
    if (_isPlaying) { await _player.pause(); }
    else { await _player.play(); }
  }

  void _seek(double v) {
    if (_dur != null) {
      _player.seek(Duration(milliseconds: (v * _dur!.inMilliseconds).round()));
    }
  }

  void _seekRelative(int seconds) {
    if (_dur != null) {
      final target = (_pos.inMilliseconds + (seconds * 1000))
          .clamp(0, _dur!.inMilliseconds);
      _player.seek(Duration(milliseconds: target));
    }
  }

  void _cycleSpeed() async {
    final speeds = [_PlaybackSpeed.x1, _PlaybackSpeed.x1_5, _PlaybackSpeed.x2];
    final idx = speeds.indexOf(_speed);
    final next = speeds[(idx + 1) % speeds.length];
    setState(() => _speed = next);
    await _player.setSpeed(_speedValue);
  }

  void _delete() {
    _player.stop();
    setState(() {
      _hasRecording = false;
      _recordedPath = null;
      _recordedDuration = null;
      _pos = Duration.zero;
      _dur = null;
      _isPlaying = false;
    });
  }

  void _publish() {
    if (_recordedPath == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublishAudioScreen(
          filePath: _recordedPath!,
          duration: _recordedDuration ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.record, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sh = constraints.maxHeight;
            final lockTop = sh * 0.12;
            final curLockSize = _overLock ? _lockSizeHover : _lockSize;

            return Listener(
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              behavior: HitTestBehavior.translucent,
              child: Stack(
              key: _stackKey,
              children: [

                if (_showLock || _isLocked)
                  Positioned(
                    top: lockTop,
                    left: 0,
                    right: 0,
                    height: _lockSizeHover,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            key: _lockKey,
                            duration: const Duration(milliseconds: 150),
                            width: curLockSize,
                            height: curLockSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isLocked
                                  ? AppTheme.primaryColor
                                  : _overLock
                                      ? AppTheme.primaryColor.withAlpha(120)
                                      : Colors.white12,
                            ),
                            child: Icon(
                              _isLocked ? Icons.lock : Icons.lock_open,
                              color: _isLocked ? Colors.black : Colors.white70,
                              size: 28,
                            ),
                          ),
                          if (_isLocked) ...[
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: _stopRecording,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 28),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                Center(
                  child: Listener(
                      onPointerDown: _onPointerDown,
                      child: Container(
                        key: _micKey,
                        width: _micSize,
                        height: _micSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? Colors.red.withAlpha(60)
                              : AppTheme.primaryColor.withAlpha(40),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isRecording)
                              SizedBox(
                                width: _micSize,
                                height: _micSize,
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.white12,
                                  valueColor: AlwaysStoppedAnimation(
                                    _isLocked ? const Color(0xFF6C63FF) : AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            Icon(
                              Icons.mic,
                              size: 56,
                              color: _isRecording
                                  ? (_isLocked ? const Color(0xFF6C63FF) : Colors.red)
                                  : AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                Positioned(
                            top: sh / 2 + _micSize / 2 + 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _hasRecording
                          ? AppStrings.recordingReady
                          : _isRecording
                              ? (_isLocked ? AppStrings.lockedTapCheck : AppStrings.swipeUpToLock)
                              : AppStrings.holdToRecord,
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ),

                if (_isRecording)
                  Positioned(
                    top: sh / 2 - _micSize / 2 - 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        _fmt((_progress * _maxDuration).clamp(0, _maxDuration).toDouble()),
                        style: const TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ),
                  ),

                if (_hasRecording && !_isRecording)
                  Positioned(
                    top: sh / 2 - _micSize / 2 - 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        _fmt(_recordedDuration!),
                        style: const TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ),
                  ),

                if (_hasRecording && !_isRecording)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: _buildPlaybackBar(),
                  ),
              ],
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaybackBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(
                    onPressed: _togglePlay,
                    child: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                  _controlButton(
                    onPressed: () => _seekRelative(-10),
                    child: const Icon(Icons.replay_10, color: Colors.white70, size: 28),
                  ),
                  _controlButton(
                    onPressed: () => _seekRelative(10),
                    child: const Icon(Icons.forward_10, color: Colors.white70, size: 28),
                  ),
                  _controlButton(
                    onPressed: _cycleSpeed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${_speed.name.substring(1).replaceAll('_', '.')}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _controlButton(
                    onPressed: _isUploading ? null : _delete,
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        activeTrackColor: AppTheme.primaryColor,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: AppTheme.primaryColor,
                        overlayColor: AppTheme.primaryColor.withAlpha(30),
                      ),
                      child: Slider(
                        value: _dur != null && _dur!.inMilliseconds > 0
                            ? (_pos.inMilliseconds / _dur!.inMilliseconds).clamp(0.0, 1.0)
                            : 0.0,
                        onChanged: _seek,
                      ),
                    ),
                  ),
                  Text(
                    '${_fmt(_pos.inSeconds.toDouble())} / ${_dur != null ? _fmt(_dur!.inSeconds.toDouble()) : '0:00'}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUploading ? null : _publish,
            icon: _isUploading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.cloud_upload, size: 20),
            label: Text(_isUploading ? AppStrings.publishing : AppStrings.publishAudio),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlButton({VoidCallback? onPressed, required Widget child}) {
    return IconButton(
      onPressed: onPressed,
      icon: child,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: EdgeInsets.zero,
    );
  }
}
