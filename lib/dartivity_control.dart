/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/10/2015
 * Copyright :  S.Hamblett 2015
 */

library dartivity_control;

import 'dart:io';
import 'dart:async';

import 'package:gcloud/pubsub.dart' as pubsub;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:json_object/json_object.dart' as jsonobject;
import 'package:mustache/mustache.dart' as tpl;

part 'src/dartivity_control.dart';
part 'src/dartivity_control_cfg.dart';
part 'src/dartivity_control_page_manager.dart';
part 'src/dartivity_control_messaging.dart';
part 'src/dartivity_control_message.dart';
part 'src/dartivity_control_exception.dart';

/// Message types
enum Type {
  whoHas, iHave, resourceDetails, clientInfo, unknown
}