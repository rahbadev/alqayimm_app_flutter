import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/app_strings.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.searchScreenTitle,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
