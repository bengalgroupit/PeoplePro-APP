import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiUrl {
  static const Duration _checkTimeout = Duration(seconds: 5);
  static const Duration _cacheDuration = Duration(minutes: 5);

  static String? _cachedUrl;
  static DateTime? _cachedAt;
  static Future<String>? _inFlight;

  static Future<bool> _isIpOnline(String ipUrl) async {
    try {
      final response = await http.get(Uri.parse(ipUrl)).timeout(_checkTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Checks all URLs at the same time and returns the first one that
  /// answers with 200. If none of them do, returns [fallbackUrl].
  static Future<String> _getApiUrl(List<String> urls, String fallbackUrl) {
    if (urls.isEmpty) return Future.value(fallbackUrl);

    final completer = Completer<String>();
    var remaining = urls.length;

    for (final url in urls) {
      _isIpOnline("$url/hive").then((isOnline) {
        remaining--;
        if (completer.isCompleted) return;
        if (isOnline) {
          completer.complete(url);
        } else if (remaining == 0) {
          completer.complete(fallbackUrl);
        }
      });
    }

    return completer.future;
  }

  static Future<String> getApiUrl() async {
    const forced = String.fromEnvironment('HIVE_API_URL');
    if (forced.isNotEmpty) return forced;

    final cachedUrl = _cachedUrl;
    final cachedAt = _cachedAt;
    if (cachedUrl != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheDuration) {
      return cachedUrl;
    }

    // If several calls arrive together, they all wait for the same check.
    return _inFlight ??= _resolve().whenComplete(() => _inFlight = null);
  }

  static Future<String> _resolve() async {
    final urls = <String>[
      if (kDebugMode)
        "https://localhost:44390/api/v1", // Android Emulator (adb reverse)
      "http://182.163.117.78:4005/api/v1", // BOL
      "http://43.224.118.50:4005/api/v1", // Next Online
      "http://bgi.com.bd:4005/api/v1", // Cloudflare
    ];

    const fallbackUrl = "http://172.16.18.59:4005/api/v1"; // Local

    final apiUrl = await _getApiUrl(urls, fallbackUrl);

    _cachedUrl = apiUrl;
    _cachedAt = DateTime.now();

    return apiUrl;
  }

  /// Call this when an API request fails with a network error, so the
  /// next getApiUrl() checks all URLs again instead of using the cache.
  static void clearCache() {
    _cachedUrl = null;
    _cachedAt = null;
  }
}
