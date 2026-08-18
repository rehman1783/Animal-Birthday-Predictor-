import 'dart:async';
import 'dart:io';

/// Centralized Error Handler to detect Network/Connectivity issues
/// and provide clean, friendly messages for all application errors.
class ErrorHandler {
  /// Checks if the given error or exception is related to Internet connectivity or timeouts
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return true;
    }

    final str = error.toString().toLowerCase();
    return str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('network is unreachable') ||
        str.contains('connection refused') ||
        str.contains('connection closed') ||
        str.contains('connection reset') ||
        str.contains('connection timed out') ||
        str.contains('clientexception') ||
        str.contains('timeout') ||
        str.contains('timed out') ||
        str.contains('no address associated with hostname') ||
        str.contains('offline') ||
        str.contains('internet') ||
        str.contains('failed to connect') ||
        str.contains('handshake') ||
        str.contains('os error: 101') ||
        str.contains('os error: 110') ||
        str.contains('os error: 111') ||
        str.contains('os error: 7');
  }

  /// Returns a clean, user-friendly title for the error
  static String getUserFriendlyTitle(dynamic error) {
    if (isNetworkError(error)) {
      final str = error.toString().toLowerCase();
      if (str.contains('timeout') || str.contains('timed out')) {
        return 'Connection Timed Out';
      }
      return 'No Internet Connection';
    }
    return 'Something Went Wrong';
  }

  /// Returns a clean, human-readable description for the error
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';

    if (isNetworkError(error)) {
      final str = error.toString().toLowerCase();
      if (str.contains('timeout') || str.contains('timed out')) {
        return 'The request took too long to complete. Please check your internet connection and try again.';
      }
      return 'Unable to connect to the server. Please check your Wi-Fi or mobile data connection and try again.';
    }

    String errorString = error.toString();
    if (errorString.startsWith('Exception: ')) {
      errorString = errorString.substring(11);
    } else if (errorString.startsWith('AuthException: ')) {
      errorString = errorString.substring(15);
    }

    if (errorString.contains('PostgrestException')) {
      return 'Unable to load data from the server. Please try again.';
    }

    return errorString.trim().isNotEmpty
        ? errorString
        : 'An unexpected error occurred. Please try again.';
  }
}
