/*
 * Created by Archer on 2022/12/10.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:shrinex_io/src/http_method.dart';

mixin HttpMessage {
  Map<String, List<String>> get headers => {};
}

mixin HttpOutputMessage on HttpMessage {
  dynamic get body => null;
}

mixin HttpRequest on HttpOutputMessage {
  String get path;

  HttpMethod get method;

  String? get baseUrl => null;

  int? get readTimeout => null;

  int? get connectTimeout => null;

  Map<String, dynamic> get queryParams => {};
}
