/*
 * Created by Archer on 2022/12/15.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shrinex_io/src/client/dio_rest_client.dart';
import 'package:shrinex_io/src/client/rest_options.dart';
import 'package:shrinex_io/src/http/http_method.dart';
import 'package:shrinex_io/src/http/http_request.dart';

import '../mocks/types.mocks.dart';

class StubRequest extends HttpRequest {
  @override
  String get path => "/xyz";

  @override
  HttpMethod get method => HttpMethod.get;
}

void main() {
  test(
    "DioRestClient.execute() calls Dio.fetch()",
    () async {
      final dio = MockDio();
      final restOptions = RestOptions(
        "https://example.com",
      );
      final client = DioRestClient(
        restClient: dio,
        restOptions: restOptions,
      );

      // expect
      when(dio.options).thenReturn(
        BaseOptions(
          baseUrl: restOptions.baseUrl,
        ),
      );
      when(dio.fetch(argThat(const TypeMatcher<RequestOptions>()))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: "xyz",
            data: {},
          ),
        ),
      );

      // run
      client.execute(StubRequest());

      // verify
      verify(dio.fetch(argThat(const TypeMatcher<RequestOptions>()))).called(1);
    },
  );
}
