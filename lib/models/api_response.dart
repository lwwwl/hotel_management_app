class ApiResponse<T> {
  final int timestamp;
  final int statusCode;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.timestamp,
    required this.statusCode,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      timestamp: json['timestamp'] ?? 0,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'statusCode': statusCode,
      'message': message,
      'data': data,
      'error': error,
    };
  }

  bool get isSuccess => statusCode == 200;
}
