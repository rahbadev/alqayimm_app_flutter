import 'package:flutter/material.dart';
import 'package:alqayimm_app_flutter/app_strings.dart';

class ShikScreen extends StatelessWidget {
  const ShikScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.navSheikh,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
