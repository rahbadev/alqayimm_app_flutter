import 'package:alqayimm_app_flutter/widgets/dialogs/reader_page_selector_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfScrollThumb extends StatelessWidget {
  final PdfViewerController controller;
  final int totalPages;

  const PdfScrollThumb({
    super.key,
    required this.controller,
    required this.totalPages,
  });

  void _showPageSelector(
    BuildContext context,
    int currentPage,
    int totalPages,
    Function(int) onPageSelected,
  ) {
    PageSelectorDialog.show(
      context,
      currentPage: currentPage,
      totalPages: totalPages,
      onPageSelected: onPageSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PdfViewerScrollThumb(
      controller: controller,
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
                  _showPageSelector(context, pageNumber ?? 0, totalPages, (
                    page,
                  ) {
                    if (page >= 1 && page <= totalPages && controller.isReady) {
                      controller.goToPage(pageNumber: page);
                    }
                  });
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
                  "$pageNumber / $totalPages",
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
}
