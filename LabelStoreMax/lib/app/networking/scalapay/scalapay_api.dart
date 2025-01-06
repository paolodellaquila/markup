import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/app/models/scalapay/configuration.dart';
import 'package:flutter_app/app/models/scalapay/order.dart';
import 'package:flutter_app/app/models/scalapay/order_response.dart';
import 'package:flutter_app/utils/Dio/dio_logger_interceptor.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ScalapayApi {
  String get _baseUrl => getEnv('SCALAPAY_LIVE_MODE') == true ? 'https://api.scalapay.com' : 'https://integration.api.scalapay.com';
  String get _apiToken => getEnv('SCALAPAY_LIVE_MODE') == true ? getEnv('SCALAPAY_API_TOKEN') : getEnv('SCALAPAY_API_TOKEN_DEV');

  final Dio dio = Dio();

  init() {
    dio.interceptors.add(DioLoggerInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
      error: true,
      compact: false,
      maxWidth: 120,
    ));
  }

  // Fetch payment configurations
  Future<ScalapayConfiguration> getConfiguration() async {
    final response = await dio.get(
      '$_baseUrl/v2/configurations',
      options: _defaultHeaders(),
    );
    return ScalapayConfiguration.fromJson(jsonDecode(response.data));
  }

  // Create an order
  Future<ScalapayOrderResponse> createOrder(ScalapayOrder order) async {
    final response = await dio.post(
      '$_baseUrl/v2/orders',
      options: _defaultHeaders(),
      data: jsonEncode(order.toJson()),
    );
    return ScalapayOrderResponse.fromJson(response.data);
  }

  // Delay an order
  Future<void> delayOrder(String token) async {
    await dio.post(
      '$_baseUrl/v2/payments/$token/delay',
      options: _defaultHeaders(),
    );
  }

  // Capture payment for an order
  Future<void> capturePayment(String token) async {
    await dio.post(
      '$_baseUrl/v2/payments/capture',
      options: _defaultHeaders(),
      data: jsonEncode({"token": token}),
    );
  }

  // Void an order
  Future<void> voidOrder(String token) async {
    await dio.post(
      '$_baseUrl/v2/payments/$token/void',
      options: _defaultHeaders(),
    );
  }

  // Common headers method
  Options _defaultHeaders() {
    return Options(
      headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_apiToken}",
      },
    );
  }
}
