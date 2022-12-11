/*
 * Created by Archer on 2022/12/11.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

/// Defines common part for a client HTTP request
mixin HttpMessage {
  /// HTTP headers
  Map<String, List<String>> get headers => {};
}