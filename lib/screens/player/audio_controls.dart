import 'package:alqayimm_app_flutter/widget/icons/animated_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class AudioControls extends StatelessWidget {
  final Duration currentPosition;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onForward;
  final VoidCallback onRewind;
  final VoidCallback onRetry;
  final ValueChanged<double> onSeek;
  final String? errorMessage;

  const AudioControls({
    super.key,
    required this.currentPosition,
    required this.duration,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrev,
    required this.onForward,
    required this.onRewind,
    required this.onSeek,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    this.errorMessage,
  });

  static String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: currentPosition.inSeconds.toDouble().clamp(
            0,
            duration.inSeconds.toDouble(),
          ),
          min: 0,
          max:
              duration.inSeconds.toDouble() > 0
                  ? duration.inSeconds.toDouble()
                  : 1,
          onChanged: onSeek,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(currentPosition)),
              Text(formatDuration(duration)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            _buildControllIconButton(Icons.skip_next, onPrev),
            _buildControllIconButton(Icons.forward_10, onRewind),
            SizedBox(
              width: 60,
              height: 60,
              child: Center(child: _buildPlayPauseButton(context)),
            ),
            _buildControllIconButton(Icons.replay_10, onForward),
            _buildControllIconButton(Icons.skip_previous, onNext),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(BuildContext context) {
    final double iconSize = 56;

    if (isLoading) {
      return const CircularProgressIndicator(strokeWidth: 4);
    }

    if (hasError) {
      return IconButton(
        icon: AnimatedIconSwitcher(
          icon: Icon(
            Ionicons.ios_refresh_circle,
            color: Colors.red,
            size: iconSize,
          ),
        ),
        iconSize: iconSize,
        onPressed: onRetry,
        tooltip: 'إعادة المحاولة',
      );
    }

    return _playPauseIcon(iconSize, context);
  }

  IconButton _playPauseIcon(double iconSize, BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: AnimatedIconSwitcher(
        icon: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          key: ValueKey(isPlaying),
          size: iconSize,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      iconSize: iconSize,
      onPressed: onPlayPause,
      tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
    );
  }

  IconButton _buildControllIconButton(
    IconData icon,
    VoidCallback onPressed, {
    double size = 32,
  }) {
    return IconButton(icon: Icon(icon, size: size), onPressed: onPressed);
  }
}
