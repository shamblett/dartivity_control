/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/10/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_control;

class DartivityControlCfg {
  /// Default pages
  static const int defaultPage = DartivityControlPageManager.home;
  static const int errorPage = DartivityControlPageManager.error;

  /// Version
  static const VERSION = '0.0.1';

  /// Messaging

  /// Package name
  static const String MESS_PACKAGE_NAME = 'dartivity';

  /// Pubsub project id
  static const String MESS_PROJECT_ID = 'warm-actor-356';

  /// Topic for pubsub
  static const String MESS_TOPIC =
  "projects/${MESS_PROJECT_ID}/topics/${MESS_PACKAGE_NAME}";

  /// Pubsub credentials path
  static const String MESS_CRED_PATH =
  '/var/www/html/projects/dartivity_control/credentials/Development-87fde7970997.json';


}
