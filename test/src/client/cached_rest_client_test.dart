/*
 * Created by Archer on 2022/12/15.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:shrinex_io/src/client/dio_rest_client_factory.dart';
import 'package:shrinex_io/src/client/rest_client_factory.dart';
import 'package:shrinex_io/src/server_options.dart';

void main() {
  test(
    "CachedRestClientFactory.createRestClient() always returns the same object",
    () {
      final factory = CachedRestClientFactory(
        DioRestClientFactory(
          ServerOptions(
            "https://api.github.com/users",
          ),
        ),
      );
      final client = factory.createRestClient();
      expect(client, isNotNull);
      expect(factory.createRestClient(), client);
    },
  );
}
