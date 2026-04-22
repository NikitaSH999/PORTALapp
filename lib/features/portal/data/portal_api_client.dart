import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hiddify/features/portal/config/portal_public_config.dart';
import 'package:hiddify/features/portal/data/portal_session_store.dart';

abstract interface class PortalApiClient {
  Future<Map<String, dynamic>> getJson(String path);

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  );
}

class DioPortalApiClient implements PortalApiClient {
  DioPortalApiClient({
    required this.config,
    this.sessionStore,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  final PortalPublicConfig config;
  final PortalSessionStore? sessionStore;
  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _dio.get<Object?>(
      _resolve(path).toString(),
      options: Options(headers: _headers()),
    );
    return _decode(response);
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Object?>(
      _resolve(path).toString(),
      data: body,
      options: Options(
        headers: _headers(contentType: true),
        contentType: Headers.jsonContentType,
      ),
    );
    return _decode(response);
  }

  Uri _resolve(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    return Uri.parse('${config.apiBaseUrl}$path');
  }

  Map<String, String> _headers({bool contentType = false}) {
    final runtimeSessionToken = sessionStore?.readSessionTokenSync() ?? '';
    final bundledSessionToken = kIsWeb ? config.webSessionToken : '';
    final bundledTelegramInitData = kIsWeb ? config.telegramInitData : '';
    final authToken = runtimeSessionToken.isNotEmpty
        ? runtimeSessionToken
        : bundledSessionToken;
    final installId = sessionStore?.readInstallIdSync() ?? '';

    return {
      if (contentType) 'Content-Type': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      if (authToken.isNotEmpty) 'X-Web-Auth-Token': authToken,
      if (runtimeSessionToken.isNotEmpty)
        'X-App-Session-Token': runtimeSessionToken,
      if (installId.isNotEmpty) 'X-Portal-Install-Id': installId,
      if (bundledTelegramInitData.isNotEmpty)
        'X-Telegram-Init-Data': bundledTelegramInitData,
    };
  }

  Map<String, dynamic> _decode(Response<Object?> response) {
    final statusCode = response.statusCode ?? 500;
    if (statusCode < 200 || statusCode >= 300) {
      throw StateError(
        'Portal API error $statusCode: ${response.data}',
      );
    }

    final payload = response.data;
    if (payload == null) return const {};
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) {
      return payload.map((key, value) => MapEntry(key.toString(), value));
    }
    if (payload is String) {
      final normalized = payload.trim();
      if (normalized.isEmpty) return const {};
      final decoded = jsonDecode(normalized);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    throw const FormatException('Portal API payload is not an object');
  }
}
