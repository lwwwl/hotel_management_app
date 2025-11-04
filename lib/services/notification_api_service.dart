import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/api_models.dart';
import '../models/api_requests.dart';
import '../models/api_response.dart';
import 'task_api_service.dart';

class NotificationApiService {
  static const String _baseUrl = TaskApiService.baseUrl;

  static Future<ApiResponse<NotificationListData>> getNotificationList({
    int? lastNotificationId,
    int size = 100,
  }) async {
    final request = NotificationListRequest(
      lastNotificationId: lastNotificationId,
      size: size,
    );

    try {
      final requestHeaders = await TaskApiService.headers;
      final url = '$_baseUrl/app/notification/list';
      final requestBody = jsonEncode(request.toJson());
      
      debugPrint('========== NOTIFICATION LIST REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Headers: $requestHeaders');
      debugPrint('Body: $requestBody');
      debugPrint('===============================================');
      
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
      );
      
      debugPrint('========== NOTIFICATION LIST RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('================================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<NotificationListData>.fromJson(
          jsonData,
          (data) => NotificationListData.fromJson(data as Map<String, dynamic>),
        );
        return apiResponse;
      } else {
        return ApiResponse<NotificationListData>(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          statusCode: response.statusCode,
          message: '请求失败',
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<NotificationListData>(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusCode: 500,
        message: '网络错误',
        error: e.toString(),
      );
    }
  }
}
