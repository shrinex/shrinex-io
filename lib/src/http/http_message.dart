/*
 * Created by Archer on 2022/12/11.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

/// Defines common part for client HTTP request & response
abstract class HttpMessage {
  /// HTTP headers
  Map<String, List<String>> get headers => {};
}
