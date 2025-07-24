import 'package:flutter/material.dart';

class PageSelectorDialog extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageSelected;

  const PageSelectorDialog({super.key, 
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
  });

  /// دالة ثابتة لعرض مربع الحوار بسهولة من أي مكان
  static Future<void> show(
    BuildContext context, {
    required int currentPage,
    required int totalPages,
    required Function(int) onPageSelected,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => PageSelectorDialog(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageSelected: onPageSelected,
          ),
    );
  }

  @override
  State<PageSelectorDialog> createState() => _PageSelectorDialogState();
}

class _PageSelectorDialogState extends State<PageSelectorDialog> {
  late TextEditingController _pageController;
  late int _selectedPage;

  @override
  void initState() {
    super.initState();
    _selectedPage = widget.currentPage;
    _pageController = TextEditingController(text: _selectedPage.toString());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('الانتقال إلى صفحة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'رقم الصفحة (1-${widget.totalPages})',
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              final page = int.tryParse(value);
              if (page != null && page >= 1 && page <= widget.totalPages) {
                setState(() {
                  _selectedPage = page;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedPage.toDouble(),
            min: 1,
            max: widget.totalPages.toDouble(),
            divisions: widget.totalPages > 1 ? widget.totalPages - 1 : null,
            label: _selectedPage.toString(),
            onChanged: (value) {
              setState(() {
                _selectedPage = value.round();
                _pageController.text = _selectedPage.toString();
              });
            },
          ),
          Text('الصفحة $_selectedPage من ${widget.totalPages}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onPageSelected(_selectedPage);
            Navigator.of(context).pop();
          },
          child: const Text('انتقال'),
        ),
      ],
    );
  }
}
