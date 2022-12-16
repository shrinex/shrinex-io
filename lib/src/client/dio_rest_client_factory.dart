/*
 * Created by Archer on 2022/12/15.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:shrinex_io/src/client/dio_rest_client.dart';
import 'package:shrinex_io/src/client/rest_client.dart';
import 'package:shrinex_io/src/client/rest_client_factory.dart';
import 'package:shrinex_io/src/server_options.dart';

class DioRestClientFactory implements RestClientFactory {
  final ServerOptions serverOptions;

  const DioRestClientFactory(this.serverOptions);

  @override
  T createRestClient<T extends RestClient>() {
    return DioRestClient.using(serverOptions) as T;
  }
}
