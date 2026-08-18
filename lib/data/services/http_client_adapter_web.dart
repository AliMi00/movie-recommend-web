import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

HttpClientAdapter? createWebHttpClientAdapter({bool withCredentials = false}) {
  final adapter = BrowserHttpClientAdapter()..withCredentials = withCredentials;
  return adapter;
}
