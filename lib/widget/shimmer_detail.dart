import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget _shimmerDetail() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: 120,
      height: 14,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),
  );
}
