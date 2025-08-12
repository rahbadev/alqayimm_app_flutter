import 'package:flutter/material.dart';

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
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            _buildControllIconButton(Icons.skip_next_rounded, onPrev),
            _buildControllIconButton(Icons.forward_10_rounded, onRewind),
            SizedBox(
              width: 60,
              height: 60,
              child: Center(child: _buildPlayPauseButton(context)),
            ),
            _buildControllIconButton(Icons.replay_10_rounded, onForward),
            _buildControllIconButton(Icons.skip_previous_rounded, onNext),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(BuildContext context) {
    final double iconSize = 56;

    if (isLoading) {
      return const CircularProgressIndicator(
        strokeWidth: 4,
        strokeCap: StrokeCap.round,
      );
    }

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: IconButton.filled(
        icon: Icon(
          hasError
              ? Icons.refresh_rounded
              : isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
        ),
        highlightColor: hasError ? Colors.red : null,
        iconSize: iconSize / 1.3,
        padding: EdgeInsets.zero,
        onPressed: hasError ? onRetry : onPlayPause,
        tooltip:
            hasError ? 'إعادة المحاولة' : (isPlaying ? 'إيقاف مؤقت' : 'تشغيل'),
        style: IconButton.styleFrom(
          backgroundColor: hasError ? Colors.red : null,
        ),
      ),
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
