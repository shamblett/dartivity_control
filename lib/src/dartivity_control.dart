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
  /// page identifier
  void despatch(int pageId) {
    // Get a page manager
    String docRoot = _apache.Server['DOCUMENT_ROOT'];
    String httpHost = _apache.Server['HTTP_HOST'];
    DartivityControlPageManager pageManager =
    new DartivityControlPageManager(docRoot, httpHost);

    // Valid page check
    if (!pageManager.pageValid(pageId)) pageId = DartivityControlPageManager.error;

    //TODO for now
    String page = pageManager.getHtmlFileContents(pageId);
    _apache.writeOutput(page);

  }
}
