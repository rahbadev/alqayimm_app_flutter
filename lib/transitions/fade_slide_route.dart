import 'package:flutter/material.dart';

PageRoute<T> fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      );
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}
