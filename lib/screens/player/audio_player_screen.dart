import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/screens/player/audio_controls.dart';
import 'package:alqayimm_app_flutter/utils/file_utils.dart';
import 'package:alqayimm_app_flutter/widgets/bottom_sheets/speed_slider_bottom_sheet.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/bookmark_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/note_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
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
      logger.i('Current position: ${pos.inMilliseconds}');
      setState(() => _currentPosition = pos);
      // احفظ الموضع فقط إذا كان المشغل جاهز وليس في البداية
      if (_isPlaying && pos.inMilliseconds > 1000) {
        // أكثر من ثانية واحدة
        _saveLastPosition(pos);
      }
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
    if (_isInitAudioRunning) return;
    _isInitAudioRunning = true;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    final lesson = widget.lessons[_currentIndex];
    try {
      final filePath = await FileUtils.getItemFileFullPath(lesson, true);

      if (filePath != null &&
          filePath.isNotEmpty &&
          filePath.endsWith('.mp3') &&
          await FileUtils.isItemFileExists(lesson)) {
        logger.i('Loading audio from: $filePath');
        await _audioPlayer.setFilePath(filePath);
      } else if (lesson.url != null && lesson.url!.isNotEmpty) {
        logger.i('Loading audio from URL: ${lesson.url}');
        await _audioPlayer.setUrl(lesson.url!);
      } else {
        _showError(
          filePath == null
              ? 'الملف غير موجود أو غير صالح يرجى حذف الملف وإعادة تحميله'
              : 'خطأ في تحميل الملف: تحقق من الاتصال',
        );
        return;
      }

      // استرجاع آخر موضع محفوظ
      final lastPositionMs = await UserItemStatusRepository.getLastPosition(
        lesson.id,
        ItemType.lesson,
      );
      logger.i('Last position for ${lesson.id}: $lastPositionMs ms');
      if (lastPositionMs != null && lastPositionMs > 0) {
        final lastPosition = Duration(milliseconds: lastPositionMs);
        await _audioPlayer.seek(lastPosition);
        setState(() {
          _currentPosition = lastPosition;
        });
      } else {
        await _audioPlayer.seek(Duration.zero);
        setState(() {
          _currentPosition = Duration.zero;
        });
      }

      setState(() {
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
      });
      _audioPlayer.play();
      _isInitAudioRunning = false;
    } catch (e) {
      logger.e('Error loading audio file', error: e);
      _showError(e.toString());
    }
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

  void _showError(String message) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = message;
    });
    AppToasts.showError(
      title: 'خطأ في تشغيل الملف',
      description: _errorMessage,
    );
    _isInitAudioRunning = false;
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

  // add bookmark
  Future<void> _addBookmark(LessonModel lesson) async {
    await BookmarkDialog.showForLesson(
      context: context,
      lesson: lesson,
      position: _currentPosition.inMilliseconds,
    );
  }

  Future<void> _addNote() async {
    _currentPosition = _audioPlayer.position;
    final lesson = widget.lessons[_currentIndex];

    final result = await NoteDialog.showNoteDialog(
      context: context,
      source:
          '${lesson.materialName} - ${lesson.lessonName} (${AudioControls.formatDuration(_currentPosition)}s) | ${lesson.authorName}',
    );

    if (result == true) {}
  }

  Future<void> _cleanupAndExit() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
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
        await _cleanupAndExit();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text("المشغل")),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 12,
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${lesson.materialName} (${lesson.lessonNumber})',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (lesson.authorName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        lesson.authorName!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 15,
                child: AudioControls(
                  currentPosition: _currentPosition,
                  duration: _duration,
                  isPlaying: _isPlaying,
                  onPlayPause: _playPause,
                  onNext: _nextLesson,
                  onPrev: _prevLesson,
                  onForward: () => _seekRelative(10),
                  onRewind: () => _seekRelative(-10),
                  onSeek:
                      (val) =>
                          _audioPlayer.seek(Duration(seconds: val.toInt())),
                  isLoading: _isLoading,
                  hasError: _hasError,
                  onRetry: _initAudio,
                  errorMessage: _errorMessage,
                ),
              ),
              Expanded(
                flex: 6,
                child: Center(
                  child: _buildPlayerActions(lesson, _currentIndex),
                ),
              ),

              Expanded(flex: 40, child: _buildPlaylistWidget()),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLesson(int index) {
    if (index >= 0 && index < widget.lessons.length && index != _currentIndex) {
      setState(() => _currentIndex = index);
      _initAudio();
    }
  }

  Widget _buildPlaylistWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6),
      child: ListView.builder(
        itemCount: widget.lessons.length,
        itemBuilder: (context, idx) {
          final l = widget.lessons[idx];
          final isCurrent = idx == _currentIndex;
          return ListTile(
            title: Text(l.lessonName),
            subtitle: Text(l.materialName ?? ''),
            leading:
                isCurrent
                    ? Icon(Ionicons.play, color: Colors.teal)
                    : const Icon(Ionicons.ios_musical_notes),
            selected: isCurrent,
            onTap: () => _navigateToLesson(idx),
          );
        },
      ),
    );
  }

  Future<void> _saveLastPosition(Duration position) async {
    logger.i('Saving last position: ${position.inMilliseconds}');
    final lesson = widget.lessons[_currentIndex];
    await UserItemStatusRepository.saveLastPosition(
      lesson.id,
      ItemType.lesson,
      position.inMilliseconds,
    );
  }

  Row _buildPlayerActions(LessonModel lesson, int index) {
    Widget iconButton({
      required IconData icon,
      Color? color,
      required VoidCallback onPressed,
      String? tooltip,
    }) {
      return IconButton.outlined(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 24,
        tooltip: tooltip,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        iconButton(
          icon: Icons.note_add_outlined,
          onPressed: _addNote,
          tooltip: 'إضافة ملاحظة',
        ),
        iconButton(
          icon: Icons.bookmark_add_outlined,
          onPressed: () => _addBookmark(lesson),
          tooltip: 'إضافة إشارة مرجعية',
        ),
        iconButton(
          icon: Icons.download_outlined,
          onPressed: () {
            // TODO: Implement download functionality
          },
          tooltip: 'تحميل',
        ),
        iconButton(
          icon: Icons.speed,
          color: _speed != 1.0 ? Theme.of(context).colorScheme.primary : null,
          onPressed: _showSpeedSheet,
        ),
      ],
    );
  }
}
