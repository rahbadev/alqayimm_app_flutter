import 'dart:async';

import 'package:alqayimm_app_flutter/db/enums.dart';
import 'package:alqayimm_app_flutter/db/user/db_constants.dart';
import 'package:alqayimm_app_flutter/db/user/repos/user_item_status_repository.dart';
import 'package:alqayimm_app_flutter/downloader/download_provider.dart';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/screens/reader/scroll_thumb.dart';
import 'package:alqayimm_app_flutter/utils/file_utils.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/utils/network_utils.dart';
import 'package:alqayimm_app_flutter/utils/preferences_utils.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/bookmark_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/note_dialog.dart';
import 'package:provider/provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final BookModel book;
  final int? initialPage;

  const PdfViewerScreen({super.key, required this.book, this.initialPage});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen>
    with WidgetsBindingObserver {
  final documentRef = ValueNotifier<PdfDocumentRef?>(null);
  final controller = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDarkMode = false;
  String get title => widget.book.name;
  int? get bookId => widget.book.id;
  bool get isFavorite => widget.book.isFavorite;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePdf();
  }

  @override
  void dispose() {
    documentRef.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) setState(() {});
  }

  Future<void> _initializePdf() async {
    final downloadProvider = Provider.of<DownloadProvider>(
      context,
      listen: false,
    );

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final book = widget.book;
      final isFileDownloaded =
          downloadProvider.getDownloadStatus(book) == DownloadStatus.downloaded;

      if (isFileDownloaded) {
        final fileExists = await FileUtils.isItemFileExists(book);
        if (!fileExists) {
          throw Exception('الملف غير موجود يرجى إعادة تنزيله');
        }
        final filePath = await FileUtils.getItemFileFullPath(book, true);

        if (filePath == null || !filePath.endsWith('.pdf')) {
          throw Exception('الملف غير صالح أو غير متاح');
        }

        documentRef.value = PdfDocumentRefFile(filePath);
      } else if (book.bookUrl != null && book.bookUrl!.isNotEmpty) {
        logger.i('Loading book from URL: ${book.bookUrl}');

        final isWifiOnly = PreferencesUtils.requireWiFi;
        // فحص الاتصال بالشبكة قبل تحميل الكتاب
        final isNetworkAvailable = await NetworkUtils.checkConnectionType(
          isWifiOnly: isWifiOnly,
          url: book.bookUrl,
        );

        if (!isNetworkAvailable.canProceed) {
          throw Exception(isNetworkAvailable.message);
        }

        documentRef.value = PdfDocumentRefUri(
          Uri.parse(book.bookUrl!),
          useProgressiveLoading: true,
        );
      } else {
        throw Exception(
          'لا يمكن تشغيل هذا الدرس ربما يكون الملف معطوباً أو أن الرابط غير صالح',
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
      logger.e('Error loading PDF', error: e);
    }
  }

  Future<void> _loadLastPage() async {
    int? pageToGo = 0;
    if (widget.initialPage != null) {
      pageToGo = widget.initialPage;
    } else if (bookId != null) {
      try {
        pageToGo = await UserItemStatusRepository.getLastPosition(
          bookId!,
          ItemType.book,
        );
      } catch (e) {
        logger.e('Error loading last page', error: e);
      }
    }
    if (pageToGo != null && pageToGo > 0 && pageToGo <= _totalPages) {
      _currentPage = pageToGo;
      if (controller.isReady) {
        controller.goToPage(pageNumber: pageToGo);
      }
      logger.i('Restored page: $pageToGo');
    }
  }

  Future<void> _saveLastPage(int page) async {
    if (bookId == null) return;
    try {
      await UserItemStatusRepository.saveLastPosition(
        bookId!,
        ItemType.book,
        page,
      );
    } catch (e) {
      logger.e('Error saving last page', error: e);
    }
  }

  void _toggleReadingMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> _addBookmark() async {
    if (bookId != null) {
      await BookmarkDialog.showForBook(
        context: context,
        book: widget.book,
        pageNumber: _currentPage,
      );
    }
  }

  Future<void> _addNote() async {
    await NoteDialog.showNoteDialog(
      context: context,
      source: formatSource(widget.book, _currentPage),
    );
  }

  static String formatSource(BookModel book, int currentPage) {
    return '${book.name} [$currentPage]';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _hasError ? _buildErrorScreen() : _buildPdfViewer(),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // دمج ColorFiltered لدعم الوضع الليلي
    return ValueListenableBuilder(
      valueListenable: documentRef,
      builder: (context, docRef, child) {
        if (docRef == null) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'لا يوجد مستند محمل';
          });
          return _buildErrorScreen();
        }
        try {
          return ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white,
              _isDarkMode ? BlendMode.difference : BlendMode.dst,
            ),
            child: PdfViewer(
              docRef,
              controller: controller,
              params: _buildViewerParams(),
            ),
          );
        } catch (e) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = e.toString();
          });
          return _buildErrorScreen();
        }
      },
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializePdf,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen({int? totalBytes, int? bytesDownloaded}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value:
                (totalBytes != null &&
                        bytesDownloaded != null &&
                        totalBytes != 0)
                    ? bytesDownloaded / totalBytes
                    : null,
            strokeCap: StrokeCap.round,
          ),
          const SizedBox(height: 16),
          Text(
            (totalBytes != null && bytesDownloaded != null && totalBytes != 0)
                ? 'تحميل: ${(bytesDownloaded / totalBytes * 100).toStringAsFixed(0)}%'
                : 'جاري التحميل...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(title),
      actions:
          _isLoading || _hasError
              ? []
              : [
                IconButton(
                  icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: _toggleReadingMode,
                  tooltip: _isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  onPressed: _addBookmark,
                  tooltip: 'إضافة علامة مرجعية',
                ),
                IconButton(
                  icon: const Icon(Icons.note_add_outlined),
                  onPressed: _addNote,
                  tooltip: 'إضافة ملاحظة',
                ),
                PopupMenuButton<String>(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'fullscreen',
                          child: Row(
                            children: [
                              Icon(Icons.fullscreen),
                              SizedBox(width: 8),
                              Text('ملء الشاشة'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
    );
  }

  PdfViewerParams _buildViewerParams() {
    return PdfViewerParams(
      enableTextSelection: true,
      maxScale: 5.0,
      minScale: 0.5,
      backgroundColor: Theme.of(context).colorScheme.surface,

      onDocumentChanged: (document) {
        if (document != null) {
          setState(() {
            _totalPages = document.pages.length;
          });
        }
      },

      onViewerReady: (document, controller) async {
        await _loadLastPage();
      },

      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
        return _buildLoadingScreen(
          bytesDownloaded: bytesDownloaded,
          totalBytes: totalBytes,
        );
      },

      errorBannerBuilder: (context, error, stackTrace, documentRef) {
        return _buildErrorScreen();
      },

      onPageChanged: (pageNumber) {
        setState(() {
          _currentPage = pageNumber ?? 1;
        });
        if (pageNumber != null) {
          _saveLastPage(pageNumber); // حفظ آخر صفحة
        }
      },

      viewerOverlayBuilder:
          (context, size, handleLinkTap) => [
            PdfScrollThumb(totalPages: _totalPages, controller: controller),
          ],
    );
  }
}
