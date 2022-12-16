/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:rxdart/rxdart.dart';
import 'package:shrinex_io/src/client/auth/bearer_token.dart';
import 'package:shrinex_io/src/client/rest_client.dart';
import 'package:shrinex_io/src/http/http_request.dart';
import 'package:shrinex_io/src/servicex.dart';

/// A type that knows how to fetch ShrineX data
abstract class Service {
  /// Used to fire HTTP request
  RestClient get restClient;

  /// Used to authenticate ShrineX api
  BearerToken? get bearerToken;

  /// Factory method that helps create [Service] instance
  factory Service.using({
    BearerToken? bearerToken,
    required RestClient restClient,
  }) =>
      _Service(
        restClient: restClient,
        bearerToken: bearerToken,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Service &&
        other.restClient == restClient &&
        other.bearerToken == bearerToken;
  }

  @override
  int get hashCode => (bearerToken?.hashCode ?? 7) ^ restClient.hashCode;
}

/// Reactive extension for [Service]
extension ReactiveX on Service {
  /// Entry point for making HTTP request
  /// Once called, the method returns a cold but broadcast stream
  Stream<Map<String, dynamic>> observe(
    HttpRequest request, {
    RequestHandler requestHandler = defaultRequestHandler,
    ExceptionHandler exceptionHandler = defaultExceptionHandler,
    ResponseErrorHandler responseErrorHandler = defaultResponseErrorHandler,
  }) {
    requestHandler(request);
    return Rx.defer(
      () {
        return Stream.fromFuture(() async {
          try {
            final response = await restClient.execute(request);
            if (responseErrorHandler.hasError(response)) {
              return Future<Map<String, dynamic>>.error(
                  responseErrorHandler.handleError(request, response));
            }
            return Future<Map<String, dynamic>>.value(response.body!);
          } on Exception catch (ex) {
            return Future<Map<String, dynamic>>.error(exceptionHandler(ex));
          }
        }());
      },
      reusable: true,
    );
  }
}

extension ShrinexSessionApi on Service {
  /// Returns a new service with the [Service] token replaced
  Service login(BearerToken bearerToken) {
    return Service.using(
      restClient: restClient,
      bearerToken: bearerToken,
    );
  }

  /// Returns a new service with the bearer token set to `null`
  Service logout() {
    return Service.using(
      bearerToken: null,
      restClient: restClient,
    );
  }
}

class _Service with Service {
  @override
  final RestClient restClient;

  @override
  final BearerToken? bearerToken;

  _Service({
    this.bearerToken,
    required this.restClient,
  });
}
