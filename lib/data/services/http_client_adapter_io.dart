import 'package:dio/dio.dart';

// Non-web platforms: no special adapter needed. Keep the same signature as web.
HttpClientAdapter? createWebHttpClientAdapter({bool withCredentials = false}) =>
    null;
