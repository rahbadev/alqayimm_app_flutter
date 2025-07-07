// يمكنك وضع هذا في ملف جديد مثل speed_slider_sheet.dart أو في نفس الملف مؤقتاً

import 'package:flutter/material.dart';

class SpeedSliderSheet extends StatelessWidget {
  final double speed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedSliderSheet({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    double tempSpeed = speed;
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              "سرعة التشغيل (x ${speed.toStringAsFixed(1)})",
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: tempSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '${tempSpeed.toStringAsFixed(1)}x',
              onChanged: (val) {
                setModalState(() => tempSpeed = val);
                onSpeedChanged(val);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
