import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audia/models/audio_model.dart';
import 'package:audia/services/audio_service.dart';

enum PlaybackSpeed { x1, x1_5, x2, x4 }

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final AudioPlayer _player = AudioPlayer();

  final Map<String, List<AudioModel>> _audiosBySource = {};
  final Map<String, AudioModel> _audioMap = {};
  AudioModel? _currentAudio;
  bool _isLoading = false;
  DateTime _lastPlayTime = DateTime.now().subtract(const Duration(seconds: 1));
  String? _error;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration? _duration;
  PlaybackSpeed _speed = PlaybackSpeed.x1;
  StreamSubscription? _positionSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;

  List<AudioModel> audiosForSource(String source) => _audiosBySource[source] ?? [];
  AudioModel? get currentAudio => _currentAudio;
  AudioModel? audioById(String id) => _audioMap[id];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration? get duration => _duration;
  PlaybackSpeed get speed => _speed;
  double get speedValue {
    switch (_speed) {
      case PlaybackSpeed.x1: return 1.0;
      case PlaybackSpeed.x1_5: return 1.5;
      case PlaybackSpeed.x2: return 2.0;
      case PlaybackSpeed.x4: return 4.0;
    }
  }
  double get progress => _duration != null && _duration!.inMilliseconds > 0
      ? (_position.inMilliseconds / _duration!.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;

  void _syncMap() {
    _audioMap.clear();
    for (final list in _audiosBySource.values) {
      for (final audio in list) {
        _audioMap[audio.id] = audio;
      }
    }
  }

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
    });
  }

  Future<void> loadAudios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final audios = await _audioService.getAudios();
      _audiosBySource['para_ti'] = audios;
      _syncMap();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play(AudioModel audio) async {
    if (_currentAudio?.id == audio.id) {
      if (_player.playing) return;
      await _player.play();
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastPlayTime).inMilliseconds < 1000) return;
    _lastPlayTime = now;

    await _player.stop();
    _currentAudio = audio;
    notifyListeners();

    try {
      await _player.setUrl(audio.audioUrl);
      await _player.setSpeed(speedValue);
      await _player.play();
    } catch (e) {
      _error = 'Error al reproducir audio';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      await _player.play();
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
    await _player.stop();
    _currentAudio = null;
    _position = Duration.zero;
    _duration = null;
    _isPlaying = false;
    notifyListeners();
  }

  bool _togglingLike = false;

  Future<void> toggleLike(String audioId) async {
    if (_togglingLike) return;
    _togglingLike = true;
    final audio = _audioMap[audioId];
    if (audio == null) { _togglingLike = false; return; }
    try {
      final result = await _audioService.toggleLike(audioId);
      audio.isLiked = result['liked'] as bool;
      audio.numLikes = (result['num_likes'] as num).toInt();
      notifyListeners();
    } catch (_) {
    } finally {
      _togglingLike = false;
    }
  }

  Future<ComentarioModel> addComment(String audioId, String texto) async {
    final comment = await _audioService.addComment(audioId, texto);
    final audio = _audioMap[audioId];
    if (audio != null) {
      audio.numComentarios++;
      notifyListeners();
    }
    return comment;
  }

  Future<List<ComentarioModel>> getComments(String audioId) async {
    return await _audioService.getComments(audioId);
  }

  Future<Map<String, dynamic>> toggleLikeComment(String audioId, String comentarioId) async {
    try {
      return await _audioService.toggleLikeComment(audioId, comentarioId);
    } catch (_) {
      return {'liked': false, 'num_likes': 0};
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    _audioService.dispose();
    super.dispose();
  }
}
