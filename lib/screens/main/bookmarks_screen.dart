import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/app_strings.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.bookmarksTitle,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
