/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/10/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_control;

class DartivityControl {
  /// Apache
  var _apache;

  DartivityControl(var apache) {
    _apache = apache;
  }

  /// despatch
  /// Despatch the incoming request dependant on its incoming
  /// pge identifier
  void despatch(int pageId) {
  }
}
