import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_controls.dart';
import 'package:alqayimm_app_flutter/widget/bottom_sheets.dart';
import 'package:alqayimm_app_flutter/widget/dialogs/bookmark_dialog.dart';
import 'package:alqayimm_app_flutter/widget/icons.dart';
import 'package:alqayimm_app_flutter/widget/toasts.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  final List<LessonModel> lessons;
  final int initialIndex;
  final void Function(LessonModel lesson, Duration position)? onAddNote;
  final void Function(LessonModel lesson)? onSpeedChange;

  const AudioPlayerScreen({
    super.key,
    required this.lessons,
    this.initialIndex = 0,
    this.onAddNote,
    this.onSpeedChange,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  bool _isPlaying = false;
  double _speed = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isInitAudioRunning = false;

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
      setState(() {
        _isPlaying = state.playing;
        _isLoading =
            state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });
    });
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initAudio() async {
    if (_isInitAudioRunning) return; // تجاهل إذا كان هناك تحميل جارٍ
    _isInitAudioRunning = true;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    final lesson = widget.lessons[_currentIndex];
    final filePath = lesson.url;
    if (filePath == null || !(filePath.endsWith('.mp3'))) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'الملف غير صالح أو غير مدعوم';
      });
      _isInitAudioRunning = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الملف غير صالح أو غير مدعوم')),
        );
      }
      return;
    }

    try {
      await _audioPlayer.setUrl(filePath);
      setState(() {
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
      });
      _audioPlayer.play();
    } catch (e) {
      logger.e('Error loading audio file', error: e);
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'خطأ في تحميل الملف: تحقق من الاتصال أو الملف غير موجود';
      });
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    }
    _isInitAudioRunning = false;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
    final maxPos = _duration;
    final safePos =
        newPos < Duration.zero
            ? Duration.zero
            : (newPos > maxPos ? maxPos : newPos);
    _audioPlayer.seek(safePos);
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
      showDragHandle: true,
      builder: (context) {
        return SpeedSliderSheet(
          speed: _speed,
          onSpeedChanged: (val) {
            setState(() => _speed = val);
            _audioPlayer.setSpeed(val);
            if (widget.onSpeedChange != null) {
              widget.onSpeedChange!(widget.lessons[_currentIndex]);
            }
          },
        );
      },
    );
  }

  /// إضافة/إزالة الدرس من المفضلة
  Future<void> _toggleFavorite(LessonModel lesson, int index) async {
    final success = await UserItemStatusRepository.toggleFavorite(
      lesson.id,
      ItemType.lesson,
    );
    if (success) {
      setState(() {
        widget.lessons[index] = lesson.copyWith(isFavorite: !lesson.isFavorite);
      });
    }
  }

  Future<void> _addNote() async {
    final result = await BookmarkDialog.showForLesson(
      context: context,
      lessonId: widget.lessons[_currentIndex].id,
      position: _currentPosition.inMilliseconds,
      materialName: widget.lessons[_currentIndex].materialName,
      lessonName: widget.lessons[_currentIndex].lessonName,
    );

    if (result == true) {
      AppToasts.showSuccess(
        context,
        title: 'تمت إضافة الملاحظة بنجاح',
        description: 'يمكنك مراجعة الملاحظات في قسم الملاحظات',
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lessons[_currentIndex];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // إذا لم يتم إغلاق الشاشة، قم بإيقاف الصوت وتحرير الموارد
        await _audioPlayer.stop();
        await _audioPlayer.dispose();
        if (context.mounted) {
          Navigator.of(context).pop(); // أغلق الشاشة
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.lessonName),
          actions: [
            FavIconButton(
              isFavorite: lesson.isFavorite,
              onTap: () => _toggleFavorite(lesson, _currentIndex),
            ),
            IconButton(
              icon: const Icon(Icons.speed),
              onPressed: _showSpeedSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 32),
            ClipOval(
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.scaleDown, // أو BoxFit.fill حسب رغبتك
              ),
            ),
            const SizedBox(height: 24),
            Text(
              lesson.materialName ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              lesson.lessonName,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            AudioControls(
              currentPosition: _currentPosition,
              duration: _duration,
              isPlaying: _isPlaying,
              onPlayPause: _playPause,
              onNext: _nextLesson,
              onPrev: _prevLesson,
              onForward: () => _seekRelative(10),
              onRewind: () => _seekRelative(-10),
              onSeek:
                  (val) => _audioPlayer.seek(Duration(seconds: val.toInt())),
              isLoading: _isLoading,
              hasError: _hasError,
              onRetry: _initAudio,
              errorMessage: _errorMessage,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('إضافة ملاحظة'),
              onPressed: _addNote,
            ),
            const SizedBox(height: 16),
            _buildPlaylistWidget(),
          ],
        ),
      ),
    );
  }

  Expanded _buildPlaylistWidget() {
    return Expanded(
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
    );
  }
}
