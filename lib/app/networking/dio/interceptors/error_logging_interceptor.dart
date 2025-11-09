import 'package:nylo_framework/nylo_framework.dart';

class ErrorLoggingInterceptor extends Interceptor {

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

    String errorMessage = """
    Path: ${err.requestOptions.path}
    Status Code: ${err.response?.statusCode}
    Error: ${err.error.toString()}
    Response Data: ${err.response?.data.toString()}
    Stack Trace:
    ${err.stackTrace.toString()}
    """;
    NyLogger.error(errorMessage);
    handler.next(err);
  }
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}