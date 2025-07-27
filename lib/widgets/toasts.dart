import 'package:alqayimm_app_flutter/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:toastification/toastification.dart';

class AppToasts {
  // Shadow مخصص
  static const List<BoxShadow> lowModeShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
  ];

  static void baseToast(
    BuildContext context, {
    required ToastificationType type,
    required IconData icon,
    required String title,
    Color? primaryColor,
    Color? foregroundColor,
    Color? backgroundColor,
    String? description,
    Duration? duration,
    VoidCallback? onUndo,
    ToastificationStyle style = ToastificationStyle.flat,
    Alignment alignment = Alignment.topCenter,
  }) {
    toastification.show(
      primaryColor: primaryColor,
      foregroundColor: foregroundColor,
      context: context,
      type: type,
      style: style,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description:
          description != null
              ? Text(description, style: const TextStyle(fontSize: 14))
              : null,
      alignment: alignment,
      showProgressBar: true,
      autoCloseDuration: duration ?? const Duration(seconds: 4),
      icon: Icon(icon, color: foregroundColor),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: lowModeShadow,
      direction: TextDirection.rtl,
      backgroundColor: backgroundColor,
      closeButton: ToastCloseButton(
        showType:
            onUndo != null
                ? CloseButtonShowType.always
                : CloseButtonShowType.none,
        buttonBuilder:
            onUndo == null
                ? null
                : (context, onClose) {
                  return TextButton(
                    onPressed: () {
                      onUndo();
                      onClose();
                    },
                    child: const Text(
                      "تراجع",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
      ),
      closeOnClick: true,
      dragToClose: true,
    );
  }

  static void showSuccess(
    BuildContext context, {
    String title = "نجح",
    String? description,
    Duration? duration,
    VoidCallback? onUndo,
  }) {
    baseToast(
      context,
      foregroundColor: MaterialTheme.onSuccess(context),
      primaryColor: Theme.of(context).colorScheme.onSurface,
      backgroundColor: MaterialTheme.success(context),
      type: ToastificationType.success,
      icon: Ionicons.checkmark_circle_sharp,
      title: title,
      description: description,
      duration: duration,
      onUndo: onUndo,
    );
  }

  static void showError(
    BuildContext context, {
    String title = "فشل",
    String? description,
    Duration? duration,
    VoidCallback? onUndo,
  }) {
    baseToast(
      context,
      foregroundColor: Theme.of(context).colorScheme.error,
      primaryColor: Theme.of(context).colorScheme.onSurface,
      backgroundColor: Theme.of(context).colorScheme.onError,
      type: ToastificationType.error,
      icon: Ionicons.close_circle_sharp,
      title: title,
      description: description,
      duration: duration,
      onUndo: onUndo,
    );
  }

  static void showInfo(
    BuildContext context, {
    String title = "معلومات",
    String? description,
    Duration? duration,
    VoidCallback? onUndo,
  }) {
    baseToast(
      context,
      foregroundColor: MaterialTheme.onInfo(context),
      primaryColor: Theme.of(context).colorScheme.onSurface,
      backgroundColor: MaterialTheme.info(context),
      type: ToastificationType.info,
      icon: Ionicons.information_circle_sharp,
      title: title,
      description: description,
      duration: duration,
      onUndo: onUndo,
    );
  }
}
