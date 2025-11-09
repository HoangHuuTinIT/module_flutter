// lib/app/networking/dio/interceptors/error_logging_interceptor.dart

import 'package:nylo_framework/nylo_framework.dart';

class ErrorLoggingInterceptor extends Interceptor {

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

    // Xây dựng một chuỗi (String) log chi tiết.
    String errorMessage = """
    Path: ${err.requestOptions.path}
    Status Code: ${err.response?.statusCode}
    Error: ${err.error.toString()}
    Response Data: ${err.response?.data.toString()}
    Stack Trace:
    ${err.stackTrace.toString()}
    """;

    // Ghi toàn bộ chuỗi lỗi đã được định dạng
    // Đây là cách sử dụng đúng vì NyLogger.error chỉ nhận một String
    NyLogger.error(errorMessage);

    // ... (handler.next(err)
    handler.next(err);
  }

  // ... (onRequest và onResponse) ...
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}