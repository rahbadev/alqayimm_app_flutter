import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String? url;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.filePath,
    this.url,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfControllerPinch _pdfController;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.filePath),
    );
    _pdfController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pdfController.page;
      _totalPages = _pdfController.pagesCount ?? 1;
    });
  }

  @override
  void dispose() {
    _pdfController.removeListener(_onPageChanged);
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {}, // إضافة علامة مرجعية
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () {}, // إضافة تعليق
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {}, // إضافة للمفضلة
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PdfViewPinch(
              controller: _pdfController,
              onDocumentLoaded: (doc) {
                setState(() {
                  _totalPages = doc.pagesCount;
                });
              },
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('صفحة $_currentPage من $_totalPages'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      _currentPage > 1
                          ? () => _pdfController.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.ease,
                          )
                          : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      _currentPage < _totalPages
                          ? () => _pdfController.nextPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.ease,
                          )
                          : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
