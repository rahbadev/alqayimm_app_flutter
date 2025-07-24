import 'dart:io';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:alqayimm_app_flutter/db/main/models/base_content_model.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/reader_page_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:http/http.dart' as http;
import 'package:alqayimm_app_flutter/widgets/dialogs/bookmark_dialog.dart';
import 'package:alqayimm_app_flutter/widgets/dialogs/note_dialog.dart';

class PdfViewerScreenFinal extends StatefulWidget {
  final BookModel book;

  const PdfViewerScreenFinal({super.key, required this.book});

  @override
  State<PdfViewerScreenFinal> createState() => _PdfViewerScreenFinalState();
}

class _PdfViewerScreenFinalState extends State<PdfViewerScreenFinal>
    with WidgetsBindingObserver {
  PdfViewerController? _controller;
  PdfDocument? _document;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isVerticalScroll = true;
  bool _isDarkMode = false;
  double _downloadProgress = 0.0;
  String? filePath;
  String? get url => widget.book.bookUrl;
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
    WidgetsBinding.instance.removeObserver(this);
    _document?.dispose();
    super.dispose();
  }

  Future<void> _initializePdf() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _downloadProgress = 0.0;
      });

      if (filePath == null && url == null) {
        throw Exception('يجب تحديد مسار الملف أو الـ URL');
      }

      // filePath = FilesUtils.getBookFilePath(book);

      final cacheDir = await getTemporaryDirectory();
      final fileName = Uri.parse(url!).pathSegments.last;
      filePath = File('${cacheDir.path}/$fileName').path;

      if (url == null || url!.startsWith('http')) {
        throw Exception('الرابط URL غير صحيح أو غير متاح');
      }

      // تحقق إذا كان الرابط URL (يبدأ بـ http)
      if (url != null && url!.startsWith('http')) {
        // تحقق من وجود الملف في الكاش
        final cacheDir = await getTemporaryDirectory();
        final fileName = Uri.parse(url!).pathSegments.last;
        final cachedFile = File('${cacheDir.path}/$fileName');

        logger.i('Cached file path: ${cachedFile.path}');

        if (await cachedFile.exists()) {
          // استخدم الملف من الكاش
          filePath = cachedFile.path;
          _document = await PdfDocument.openFile(cachedFile.path);
        } else {
          // نزّل الملف واحتفظ به في الكاش
          final pdfData = await _loadNetworkPdf(url!);
          await cachedFile.writeAsBytes(pdfData);
          filePath = cachedFile.path;
          _document = await PdfDocument.openFile(cachedFile.path);
        }
      } else if (filePath != null && filePath!.isNotEmpty) {
        // ملف محلي من الجهاز
        _document = await PdfDocument.openFile(filePath!);
      } else {
        throw Exception('مسار الملف أو الـ URL غير صحيح');
      }

      setState(() {
        _totalPages = _document?.pages.length ?? 1;
        _isLoading = false;
        _controller = PdfViewerController();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'خطأ في تحميل الملف: $e';
      });
    }
  }

  Future<Uint8List> _loadNetworkPdf(String url) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = <int>[];
        final contentLength = response.contentLength ?? 0;
        int received = 0;

        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          received += chunk.length;

          if (contentLength > 0) {
            setState(() {
              _downloadProgress = received / contentLength;
            });
          }
        }

        return Uint8List.fromList(bytes);
      } else {
        throw Exception(
          'فشل في تحميل الملف من الإنترنت: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الشبكة: $e');
    }
  }

  void _toggleScrollMode() {
    setState(() {
      _isVerticalScroll = !_isVerticalScroll;
    });
  }

  void _toggleReadingMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages && _controller != null) {
      _controller!.goToPage(pageNumber: page);
    }
  }

  void _showPageSelector() {
    PageSelectorDialog.show(
      context,
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPageSelected: _goToPage,
    );
  }

  Future<void> _addBookmark() async {
    if (bookId != null) {
      await BookmarkDialog.showForLesson(context: context, lessonId: bookId!);
    }
  }

  Future<void> _addNote() async {
    await NoteDialog.showNoteDialog(
      context: context,
      source: '$title - صفحة $_currentPage',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              url != null
                  ? 'جاري تحميل الملف من الإنترنت...'
                  : 'جاري تحميل الملف...',
              style: const TextStyle(fontSize: 16),
            ),
            if (url != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(title),
      actions: [
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
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'scroll_mode',
                  child: Row(
                    children: [
                      Icon(
                        _isVerticalScroll ? Icons.swap_horiz : Icons.swap_vert,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isVerticalScroll
                            ? 'التقليب الأفقي'
                            : 'التقليب العمودي',
                      ),
                    ],
                  ),
                ),
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

  Widget _buildBody() {
    return _buildPdfViewer();
  }

  Widget _buildPdfViewer() {
    if (_document == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String filePathToUse;

    // حدد المسار الصحيح للملف
    if (filePath != null) {
      // استخدم الملف من الكاش
      filePathToUse = filePath!;
    } else if (filePath != null && !filePath!.startsWith('http')) {
      // استخدم الملف المحلي
      filePathToUse = filePath!;
    } else {
      // خطأ: لا يوجد مسار صالح
      return const Center(child: Text('خطأ: لا يمكن تحديد مسار الملف'));
    }

    Widget viewer = PdfViewer.file(
      filePathToUse,
      controller: _controller,
      params: _buildViewerParams(),
    );

    // دمج ColorFiltered لدعم الوضع الليلي
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.white,
        _isDarkMode ? BlendMode.difference : BlendMode.dst,
      ),
      child: viewer,
    );
  }

  PdfViewerParams _buildViewerParams() {
    return PdfViewerParams(
      enableTextSelection: true,
      maxScale: 5.0,
      minScale: 0.5,
      loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                value: totalBytes != null ? bytesDownloaded / totalBytes : null,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                totalBytes != null
                    ? 'تحميل: ${(bytesDownloaded / totalBytes * 100).toStringAsFixed(0)}%'
                    : 'جاري التحميل...',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
      onPageChanged: (pageNumber) {
        setState(() {
          _currentPage = pageNumber ?? 1;
        });
      },
      viewerOverlayBuilder:
          (context, size, handleLinkTap) => [_buildScrollThumb()],
    );
  }

  Widget _buildScrollThumb() {
    if (_controller == null) {
      return const SizedBox.shrink();
    }
    // Add vertical scroll thumb on viewer's right side
    return PdfViewerScrollThumb(
      controller: _controller!,
      orientation: ScrollbarOrientation.right,
      thumbSize: const Size(150, 40),
      margin: -14,
      thumbBuilder:
          (context, thumbSize, pageNumber, controller) => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  _showPageSelector();
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(70),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.more_vert, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(70),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "$pageNumber / $_totalPages",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'scroll_mode':
        _toggleScrollMode();
        break;
    }
  }
}
