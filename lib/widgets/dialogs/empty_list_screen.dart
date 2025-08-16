import 'package:flutter/material.dart';

class LoadingEmptyListScreen extends StatelessWidget {
  const LoadingEmptyListScreen({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.title,
    required this.desc,
    required this.icon,
    this.reLoadingButton,
    required this.childWidget,
  });

  final String title;
  final String desc;
  final IconData icon;
  final bool isLoading;
  final bool isEmpty;
  final Widget childWidget;

  final (String text, VoidCallback onPressed)? reLoadingButton;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (isEmpty) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          if (reLoadingButton != null)
            ElevatedButton(
              onPressed: reLoadingButton!.$2,
              child: Text(reLoadingButton!.$1),
            ),
        ],
      );
    } else {
      content = childWidget;
    }

    return Padding(padding: const EdgeInsets.all(8.0), child: content);
  }
}
