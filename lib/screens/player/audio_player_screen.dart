import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/main_db/lesson_model.dart';

class AudioPlayerScreen extends StatefulWidget {
  final List<LessonModel> lessons;
  final int initialIndex;
  final void Function(LessonModel lesson, Duration position)? onAddNote;
  final void Function(LessonModel lesson)? onToggleFavorite;
  final void Function(LessonModel lesson)? onSpeedChange;

  const AudioPlayerScreen({
    super.key,
    required this.lessons,
    this.initialIndex = 0,
    this.onAddNote,
    this.onToggleFavorite,
    this.onSpeedChange,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  bool _isPlaying = false;
  double _speed = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _currentIndex = widget.initialIndex;
    _initAudio();
    _audioPlayer.positionStream.listen((pos) {
      setState(() => _currentPosition = pos);
    });
    _audioPlayer.durationStream.listen((dur) {
      setState(() => _duration = dur ?? Duration.zero);
    });
    _audioPlayer.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  Future<void> _initAudio() async {
    final lesson = widget.lessons[_currentIndex];
    final filePath = lesson.url;
    if (filePath == null || !(filePath.endsWith('.mp3'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الملف غير صالح أو غير مدعوم')),
      );
      return;
    }
    try {
      await _audioPlayer.setUrl(filePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تشغيل الملف: $e')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _seekRelative(int seconds) {
    final newPos = _currentPosition + Duration(seconds: seconds);
    _audioPlayer.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void _nextLesson() {
    if (_currentIndex < widget.lessons.length - 1) {
      setState(() => _currentIndex++);
      _initAudio();
    }
  }

  void _prevLesson() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _initAudio();
    }
  }

  void _showSpeedSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('سرعة التشغيل', style: TextStyle(fontSize: 18)),
            Slider(
              value: _speed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${_speed.toStringAsFixed(1)}x',
              onChanged: (val) {
                setState(() => _speed = val);
                _audioPlayer.setSpeed(val);
                if (widget.onSpeedChange != null) {
                  widget.onSpeedChange!(widget.lessons[_currentIndex]);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lessons[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.lessonName),
        actions: [
          IconButton(
            icon: Icon(
              lesson.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed:
                widget.onToggleFavorite != null
                    ? () => widget.onToggleFavorite!(lesson)
                    : null,
          ),
          IconButton(icon: const Icon(Icons.speed), onPressed: _showSpeedSheet),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          // صورة المشغل أو رمز التطبيق
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/icons/app_icon.png'),
          ),
          const SizedBox(height: 24),
          Text(
            lesson.lessonName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            lesson.authorName ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // شريط التقدم
          Slider(
            value: _currentPosition.inSeconds.toDouble(),
            min: 0,
            max:
                _duration.inSeconds.toDouble() > 0
                    ? _duration.inSeconds.toDouble()
                    : 1,
            onChanged:
                (val) => _audioPlayer.seek(Duration(seconds: val.toInt())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_currentPosition)),
                Text(_formatDuration(_duration)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // أزرار التحكم الرئيسية
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 32),
                onPressed: _prevLesson,
              ),
              IconButton(
                icon: const Icon(Icons.replay_10, size: 32),
                onPressed: () => _seekRelative(-10),
              ),
              GestureDetector(
                onTap: _playPause,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    key: ValueKey(_isPlaying),
                    size: 56,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10, size: 32),
                onPressed: () => _seekRelative(10),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 32),
                onPressed: _nextLesson,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // زر إضافة ملاحظة
          ElevatedButton.icon(
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('إضافة ملاحظة'),
            onPressed:
                widget.onAddNote != null
                    ? () => widget.onAddNote!(lesson, _currentPosition)
                    : null,
          ),
          const SizedBox(height: 16),
          // قائمة التشغيل
          Expanded(
            child: ListView.builder(
              itemCount: widget.lessons.length,
              itemBuilder: (context, idx) {
                final l = widget.lessons[idx];
                final isCurrent = idx == _currentIndex;
                return ListTile(
                  title: Text(l.lessonName),
                  subtitle: Text(l.authorName ?? ''),
                  leading:
                      isCurrent
                          ? const Icon(Icons.play_arrow, color: Colors.teal)
                          : const Icon(Icons.music_note),
                  selected: isCurrent,
                  onTap: () {
                    setState(() => _currentIndex = idx);
                    _initAudio();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
