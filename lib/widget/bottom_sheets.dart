import 'package:flutter/material.dart';

class SpeedSliderSheet extends StatefulWidget {
  final double speed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedSliderSheet({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
  });

  @override
  State<SpeedSliderSheet> createState() => _SpeedSliderSheetState();
}

class _SpeedSliderSheetState extends State<SpeedSliderSheet> {
  late double tempSpeed;

  @override
  void initState() {
    super.initState();
    tempSpeed = widget.speed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Text(
          "سرعة التشغيل (x ${tempSpeed.toStringAsFixed(1)})",
          style: const TextStyle(fontSize: 18),
        ),
        Slider(
          value: tempSpeed,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          label: '${tempSpeed.toStringAsFixed(1)}x',
          onChanged: (val) {
            setState(() => tempSpeed = val);
            widget.onSpeedChanged(val);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
