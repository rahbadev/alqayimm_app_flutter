import 'package:flutter/material.dart';
import 'text_fileds.dart';

/// ودجيت مخصص لشريط البحث
/// يوفر تصميم موحد لشرائط البحث مع إمكانية التخصيص
class SearchField extends StatelessWidget {
  /// متحكم النص
  final TextEditingController? controller;

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
    this.controller,
    this.hintText = 'البحث...',
    this.label,
    this.icon = Icons.search_rounded,
    this.clearIcon = Icons.clear_rounded,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showClearButton = true,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
  });

  /// مُنشئ لشريط البحث العادي
  const SearchField.standard({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  }) : hintText = 'البحث...',
       label = 'بحث',
       icon = Icons.search_rounded,
       clearIcon = Icons.clear_rounded,
       showClearButton = true,
       autofocus = false,
       keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search;

  /// مُنشئ لشريط بحث الملاحظات
  const SearchField.notes({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  }) : hintText = 'ابحث في الملاحظات...',
       label = 'بحث في الملاحظات',
       icon = Icons.search_rounded,
       clearIcon = Icons.clear_rounded,
       showClearButton = true,
       autofocus = false,
       keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search;

  /// مُنشئ لشريط بحث العلامات
  const SearchField.tags({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  }) : hintText = 'ابحث في العلامات...',
       label = 'بحث في العلامات',
       icon = Icons.local_offer_rounded,
       clearIcon = Icons.clear_rounded,
       showClearButton = true,
       autofocus = false,
       keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller ?? TextEditingController(),
      label: label ?? 'بحث',
      hint: hintText,
      icon: icon,
      onFieldSubmitted: onSubmitted,
    );
  }
}
