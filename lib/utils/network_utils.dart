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
          message: 'لا يوجد اتصال بالإنترنت',
        );
      }

      // التحقق إذا كان الاتصال عبر بيانات الجوال
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        final showWarning = !PreferencesUtils.getWifiWarningDontShowAgain();

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
