import 'dart:io';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:alqayimm_app_flutter/utils/preferences_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static Future<ConnectionCheckResult> checkConnectionType() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return ConnectionCheckResult(
          canProceed: false,
          message: 'لا يوجد اتصال بالشبكة',
        );
      }

      // تحقق من وجود إنترنت فعلي
      final hasInternet = await _hasRealInternet();
      if (!hasInternet) {
        return ConnectionCheckResult(
          canProceed: false,
          message: 'لا يوجد اتصال فعلي بالإنترنت',
        );
      }

      // التحقق إذا كان الاتصال عبر بيانات الجوال
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        final showWarning = !PreferencesUtils.wifiWarningDontShowAgain;
        if (showWarning) {
          return ConnectionCheckResult(
            canProceed: false,
            message: 'تحذير: ستستخدم بيانات الجوال للتنزيل',
            showWifiWarning: true,
          );
        }
      }

      return ConnectionCheckResult(canProceed: true);
    } catch (e) {
      logger.e('Error checking connection: $e');
      return ConnectionCheckResult(
        canProceed: false,
        message: 'خطأ في فحص الاتصال',
      );
    }
  }

  static Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('1.1.1.1');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

/// نتيجة فحص الاتصال
class ConnectionCheckResult {
  final bool canProceed;
  final String? message;
  final bool showWifiWarning;

  const ConnectionCheckResult({
    required this.canProceed,
    this.message,
    this.showWifiWarning = false,
  });
}
