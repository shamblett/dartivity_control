/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/10/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_control;

class DartivityControlPage {
  /// Default pages
  static const int home = 0;
  static const int error = 1;

  /// Page to file mapping list
  List<String> _pageMap = ['home.html', 'error.html'];

  String pageFile(int page) {
    return _pageMap[page];
  }
}
