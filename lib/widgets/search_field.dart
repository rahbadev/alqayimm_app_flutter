import 'package:flutter/material.dart';
import 'text_fileds.dart';

/// ودجيت مخصص لشريط البحث
/// يوفر تصميم موحد لشرائط البحث مع إمكانية التخصيص
class SearchField extends StatelessWidget {
  /// متحكم النص
  final TextEditingController controller;

  /// النص التوضيحي
  final String hintText;

  /// تسمية الحقل
  final String? label;

  /// الأيقونة الرئيسية
  final IconData icon;

  /// أيقونة المسح (اختياري)
  final IconData? clearIcon;

  /// دالة استدعاء عند التغيير
  final Function(String)? onChanged;

  /// دالة استدعاء عند الإرسال
  final Function(String)? onSubmitted;

  /// دالة استدعاء عند الضغط على مسح
  final VoidCallback? onClear;

  /// إظهار زر المسح
  final bool showClearButton;

  /// التركيز التلقائي
  final bool autofocus;

  /// نوع لوحة المفاتيح
  final TextInputType keyboardType;

  /// عمل المحتوى
  final TextInputAction textInputAction;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.label,
    this.icon = Icons.search_rounded,
    this.clearIcon = Icons.clear_rounded,
    this.onSubmitted,
    this.onClear,
    this.showClearButton = true,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomTextField(
        controller: controller,
        label: label ?? hintText,
        hint: hintText,
        icon: icon,
        showClearButton: showClearButton,
        onFieldSubmitted: onSubmitted,
        onChanged: onChanged,
        onClear: onClear,
      ),
    );
  }
}
