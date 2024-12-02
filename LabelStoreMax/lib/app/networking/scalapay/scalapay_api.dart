import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/app/models/scalapay/configuration.dart';
import 'package:flutter_app/app/models/scalapay/order_response.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/order.dart';

class ScalapayApi {
  get _baseUrl => getEnv('SCALAPAY_LIVE_MODE') == true ? 'https://api.scalapay.com' : 'https://integration.api.scalapay.com';
  final dio = Dio();

  Future<ScalapayConfiguration> getConfiguration() async {
    final response = await dio.get(
      _baseUrl + '/v2/configurations',
      options: Options(
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${getEnv('SCALAPAY_API_TOKEN')}",
        },
      ),
    );

    final json = jsonDecode(response.data);
    return ScalapayConfiguration.fromJson(json);
  }

  Future<ScalapayOrderResponse> createOrder(Order order) async {
    final response = await dio.post(
      _baseUrl + '/v2/orders',
      options: Options(
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${getEnv('SCALAPAY_API_TOKEN')}",
          HttpHeaders.acceptHeader: "application/json",
        },
      ),
      data: jsonEncode(order.toJson()),
    );

    final json = jsonDecode(response.data);
    return ScalapayOrderResponse.fromJson(json);
  }
}
