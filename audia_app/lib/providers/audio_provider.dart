import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audia/models/audio_model.dart';
import 'package:audia/services/audio_service.dart';

enum PlaybackSpeed { x1, x2, x4 }

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final AudioPlayer _player = AudioPlayer();

  final Map<String, List<AudioModel>> _audiosBySource = {};
  AudioModel? _currentAudio;
  bool _isLoading = false;
  String? _error;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;
  PlaybackSpeed _speed = PlaybackSpeed.x1;
  StreamSubscription? _positionSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;
  Timer? _progressTimer;

  List<AudioModel> audiosForSource(String source) => _audiosBySource[source] ?? [];
  AudioModel? get currentAudio => _currentAudio;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration? get duration => _duration;
  PlaybackSpeed get speed => _speed;
  double get speedValue => _speed == PlaybackSpeed.x1 ? 1.0 : (_speed == PlaybackSpeed.x2 ? 2.0 : 4.0);

  AudioProvider() {
    _positionSub = _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _durationSub = _player.durationStream.listen((dur) {
      _duration = dur;
      notifyListeners();
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      final wasPlaying = _isPlaying;
      _isPlaying = state.playing;
      if (wasPlaying != _isPlaying) {
        notifyListeners();
      }
      if (state.processingState == ProcessingState.completed) {
        _onAudioComplete();
      }
    });
  }

  double listenProgress(String audioId) {
    if (_currentAudio?.id == audioId && _duration != null && _duration!.inMilliseconds > 0) {
      return (_position.inMilliseconds / _duration!.inMilliseconds).clamp(0.0, 1.0);
    }
    for (final list in _audiosBySource.values) {
      for (final a in list) {
        if (a.id == audioId) {
          if (a.isCompleted) return 1.0;
          if (a.duration > 0) return (a.listenProgress / a.duration).clamp(0.0, 1.0);
          return 0.0;
        }
      }
    }
    return 0.0;
  }

  bool isCompleted(String audioId) {
    if (_currentAudio?.id == audioId) {
      return _player.processingState == ProcessingState.completed;
    }
    for (final list in _audiosBySource.values) {
      for (final a in list) {
        if (a.id == audioId) return a.isCompleted;
      }
    }
    return false;
  }

  Future<void> loadAudios(String source) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _audiosBySource[source] = await _audioService.getAudios(source);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play(AudioModel audio) async {
    _progressTimer?.cancel();

    if (_currentAudio?.id == audio.id) {
      if (_player.playing) return;
      await _player.play();
      _startProgressTimer();
      return;
    }

    await _player.stop();
    _currentAudio = audio;
    notifyListeners();

    try {
      await _player.setUrl(audio.cloudinaryUrl);
      await _player.setSpeed(speedValue);

      if (audio.listenProgress > 0 && !audio.isCompleted) {
        await _player.seek(Duration(milliseconds: (audio.listenProgress * 1000).round()));
      }

      await _player.play();
      _startProgressTimer();
    } catch (e) {
      _error = 'Error al reproducir audio';
      notifyListeners();
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) => _saveProgress());
  }

  Future<void> _saveProgress() async {
    if (_currentAudio == null) return;
    final seconds = _position.inMilliseconds / 1000.0;
    final completed = _player.processingState == ProcessingState.completed;

    for (final list in _audiosBySource.values) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == _currentAudio!.id) {
          list[i].listenProgress = seconds;
          list[i].isCompleted = completed;
        }
      }
    }

    try {
      await _audioService.updateProgress(_currentAudio!.id, seconds, completed);
    } catch (_) {}
  }

  Future<void> _onAudioComplete() async {
    _progressTimer?.cancel();
    if (_currentAudio != null) {
      for (final list in _audiosBySource.values) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].id == _currentAudio!.id) {
            list[i].isCompleted = true;
            list[i].listenProgress = _currentAudio!.duration;
          }
        }
      }
      try {
        await _audioService.updateProgress(_currentAudio!.id, _currentAudio!.duration, true);
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    _progressTimer?.cancel();
    await _saveProgress();
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      await _player.play();
      _startProgressTimer();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekRelative(int seconds) async {
    final newPos = _position + Duration(seconds: seconds);
    var clamped = newPos;
    if (clamped < Duration.zero) clamped = Duration.zero;
    if (_duration != null && clamped > _duration!) clamped = _duration!;
    await _player.seek(clamped);
  }

  Future<void> setSpeed(PlaybackSpeed newSpeed) async {
    _speed = newSpeed;
    await _player.setSpeed(speedValue);
    notifyListeners();
  }

  Future<void> stop() async {
    _progressTimer?.cancel();
    await _saveProgress();
    await _player.stop();
    _currentAudio = null;
    _position = Duration.zero;
    _duration = null;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> toggleLike(String audioId) async {
    for (final list in _audiosBySource.values) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == audioId) {
          try {
            final result = await _audioService.toggleLike(audioId);
            list[i].isLiked = result['liked'] as bool;
            list[i].likeCount = (result['like_count'] as num).toInt();
            notifyListeners();
          } catch (_) {}
          return;
        }
      }
    }
  }

  Future<AudioCommentModel> addComment(String audioId, String text) async {
    final comment = await _audioService.addComment(audioId, text);
    for (final list in _audiosBySource.values) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].id == audioId) {
          list[i].commentCount++;
          notifyListeners();
        }
      }
    }
    return comment;
  }

  Future<List<AudioCommentModel>> getComments(String audioId) async {
    return await _audioService.getComments(audioId);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    _audioService.dispose();
    super.dispose();
  }
}


