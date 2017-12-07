/*
 * Copyright (c) 2017, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 * 
 * All Rights Reserved.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
     
library fcm_push.cmdline;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:validate/validate.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:logging_handlers/logging_handlers_shared.dart';

import 'package:fcm_push/fcm_push.dart';

part 'cmdline/Application.dart';
part 'cmdline/Config.dart';
part 'cmdline/Options.dart';

/// Define some Pens to use it everywhere
final AnsiPen _penGreen = new AnsiPen()..green();
final AnsiPen _penError = new AnsiPen()..red();
