/*
 * Created by Archer on 2022/12/11.
 * Copyright © 2022 Archer. All rights reserved.
 * Github: https://github.com/shrinex
 * Home: http://anyoptional.com
 */

import 'package:shrinex_core/shrinex_core.dart';

/// Represents HTTP Bearer Auth Token
class BearerToken implements RawRepresentable<String> {
  @override
  final String rawValue;

  const BearerToken(this.rawValue);
}
