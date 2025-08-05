import 'dart:async';
import 'dart:io';
import 'package:alqayimm_app_flutter/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkUtils {
  static Future<ConnectionCheckResult> checkConnectionType({
    String? url,
    required bool isWifiOnly,
  }) async {
    try {
      // 1. فحص وجود اتصال بالشبكة
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return ConnectionCheckResult(
          canProceed: false,
          message: 'لا يوجد اتصال بالشبكة',
        );
      }

      // 2. فحص وجود إنترنت فعلي
      final hasInternet = await _hasRealInternet();
      if (!hasInternet) {
        return ConnectionCheckResult(
          canProceed: false,
          message: 'لا يوجد اتصال فعلي بالإنترنت',
        );
      }

      // 3. التحقق من تحذير بيانات الجوال قبل إرسال أي طلبات شبكة
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        if (isWifiOnly) {
          return ConnectionCheckResult(
            canProceed: false,
            message:
                'لا يمكن التنزيل عبر بيانات الجوال، يرجى الاتصال بشبكة Wi-Fi أو تغيير الإعدادات',
          );
        }
      }

      // 4. فحص صحة الرابط إذا تم تمريره
      if (url != null && url.isNotEmpty) {
        final urlResult = await _checkUrlReachability(url);
        if (!urlResult.isReachable) {
          return ConnectionCheckResult(
            canProceed: false,
            message:
                urlResult.errorMessage ?? 'لا يمكن الوصول إلى الرابط المحدد',
          );
        }
      }

      return ConnectionCheckResult(canProceed: true);
    } catch (e) {
      logger.e('Error checking connection: $e');
      return ConnectionCheckResult(
        canProceed: false,
        message: 'خطأ في فحص الاتصال: ${_cleanErrorMessage(e.toString())}',
      );
    }
  }

  /// فحص وجود إنترنت فعلي عبر DNS lookup
  static Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup(
        '1.1.1.1',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// فحص إمكانية الوصول إلى رابط معين مع معالجة أخطاء مفصلة
  static Future<UrlCheckResult> _checkUrlReachability(String url) async {
    try {
      // التحقق من صحة تنسيق الرابط
      final uri = Uri.tryParse(url);
      if (uri == null ||
          (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https'))) {
        return UrlCheckResult(
          isReachable: false,
          errorMessage: 'تنسيق الرابط غير صحيح',
        );
      }

      final response = await http.head(uri).timeout(const Duration(seconds: 8));

      // فحص حالة الاستجابة
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return UrlCheckResult(isReachable: true);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        return UrlCheckResult(
          isReachable: false,
          errorMessage: 'الرابط غير موجود (خطأ ${response.statusCode})',
        );
      } else if (response.statusCode >= 500) {
        return UrlCheckResult(
          isReachable: false,
          errorMessage: 'خطأ في الخادم (${response.statusCode})',
        );
      } else {
        return UrlCheckResult(
          isReachable: false,
          errorMessage: 'استجابة غير متوقعة من الخادم',
        );
      }
    } on SocketException {
      return UrlCheckResult(
        isReachable: false,
        errorMessage: 'لا يمكن الوصول إلى الخادم',
      );
    } on TimeoutException {
      return UrlCheckResult(
        isReachable: false,
        errorMessage: 'انتهت مهلة الاتصال بالخادم',
      );
    } on FormatException {
      return UrlCheckResult(
        isReachable: false,
        errorMessage: 'تنسيق الرابط غير صحيح',
      );
    } catch (e) {
      return UrlCheckResult(
        isReachable: false,
        errorMessage: 'خطأ غير متوقع: ${_cleanErrorMessage(e.toString())}',
      );
    }
  }

  /// إزالة كلمة "Exception:" من رسائل الخطأ
  static String _cleanErrorMessage(String message) {
    return message.replaceFirst(RegExp(r'^Exception: ?'), '');
  }

  /// فحص سريع للإنترنت فقط (بدون فحص الرابط أو تحذيرات)
  static Future<bool> hasInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }
      return await _hasRealInternet();
    } catch (_) {
      return false;
    }
  }

  /// فحص حالة الاتصال الحالية فقط (بدون DNS lookup)
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  /// الحصول على نوع الاتصال الحالي
  static Future<ConnectivityResult> getConnectionType() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.wifi)) {
        return ConnectivityResult.wifi;
      } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
        return ConnectivityResult.mobile;
      } else if (connectivityResults.contains(ConnectivityResult.ethernet)) {
        return ConnectivityResult.ethernet;
      } else {
        return ConnectivityResult.none;
      }
    } catch (_) {
      return ConnectivityResult.none;
    }
  }

  /// Stream للاستماع لتغيرات الاتصال
  static Stream<ConnectivityResult> get connectivityStream {
    return Connectivity().onConnectivityChanged.map((results) {
      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectivityResult.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        return ConnectivityResult.mobile;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectivityResult.ethernet;
      } else {
        return ConnectivityResult.none;
      }
    });
  }
}

/// نتيجة فحص الاتصال
class ConnectionCheckResult {
  final bool canProceed;
  final String? message;

  const ConnectionCheckResult({required this.canProceed, this.message});

  @override
  String toString() {
    return 'ConnectionCheckResult(canProceed: $canProceed, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionCheckResult &&
        other.canProceed == canProceed &&
        other.message == message;
  }

  @override
  int get hashCode {
    return canProceed.hashCode ^ message.hashCode;
  }
}

/// نتيجة فحص الرابط
class UrlCheckResult {
  final bool isReachable;
  final String? errorMessage;

  const UrlCheckResult({required this.isReachable, this.errorMessage});

  @override
  String toString() {
    return 'UrlCheckResult(isReachable: $isReachable, errorMessage: $errorMessage)';
  }
}
