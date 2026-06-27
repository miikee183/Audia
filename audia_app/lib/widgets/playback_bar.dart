import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audia/theme/app_theme.dart';
import 'package:audia/providers/audio_provider.dart';

class PlaybackBar extends StatelessWidget {
  const PlaybackBar({super.key});

@override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final audio = provider.currentAudio;
        if (audio == null) return const SizedBox.shrink();
        final pos = provider.position;
        final dur = provider.duration ?? Duration.zero;
        final progress = dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;
        final isPlaying = provider.isPlaying;

        return Container(
          color: AppTheme.surfaceColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor.withAlpha(60),
                    backgroundImage: audio.fotoPerfil != null ? NetworkImage(audio.fotoPerfil!) : null,
                    child: audio.fotoPerfil == null
                        ? const Icon(Icons.person, size: 18, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio.nombreUsuario,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          ' / ',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white, size: 22),
                    onPressed: () => provider.seekRelative(-10),
                    splashRadius: 18,
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: AppTheme.primaryColor, size: 32),
                    onPressed: () => provider.togglePlay(),
                    splashRadius: 22,
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white, size: 22),
                    onPressed: () => provider.seekRelative(10),
                    splashRadius: 18,
                  ),
                  GestureDetector(
                    onTap: () {
                      final speeds = [PlaybackSpeed.x1, PlaybackSpeed.x2, PlaybackSpeed.x4];
                      final idx = speeds.indexOf(provider.speed);
                      final next = speeds[(idx + 1) % speeds.length];
                      provider.setSpeed(next);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withAlpha(60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: AppTheme.primaryColor,
                  inactiveTrackColor: Colors.white12,
                  thumbColor: AppTheme.primaryColor,
                  overlayColor: AppTheme.primaryColor.withAlpha(30),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) {
                    final seekPos = Duration(milliseconds: (v * dur.inMilliseconds).round());
                    provider.seek(seekPos);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


