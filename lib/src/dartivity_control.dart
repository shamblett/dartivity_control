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

  /// Messaging client
  mess.DartivityMessaging _messager;

  /// Our id
  String _id = mess.DartivityMessage.ADDRESS_WEB_SERVER;

  DartivityControl(var apache) {
    _apache = apache;
  }

  /// despatch
  /// Despatch the incoming request dependant on its incoming
  /// page identifier
  Future despatch(int pageId) async {
    // Get a page manager
    String docRoot = _apache.Server['DOCUMENT_ROOT'];
    String httpHost = _apache.Server['HTTP_HOST'];
    DartivityControlPageManager pageManager =
    new DartivityControlPageManager(docRoot, httpHost, _messager);

    // Valid page check
    if (!pageManager.pageValid(pageId)) pageId =
    DartivityControlPageManager.error;

    // Construct and write the output back to apache
    String page = await pageManager.doPage(pageId, _apache.Request);
    _apache.writeOutput(page);
  }

  /// initialise
  /// Initialise messaging etc.
  Future<bool> initialise() async {
    Completer completer = new Completer();
    _messager = new mess.DartivityMessaging(_id);
    await _messager.initialise(DartivityControlCfg.MESS_CRED_PATH,
        DartivityControlCfg.MESS_PROJECT_ID, DartivityControlCfg.MESS_TOPIC);
    if (!_messager.ready) {
      throw new DartivityControlException(
          DartivityControlException.FAILED_TO_INITIALISE_MESSAGER);
    } else {
      completer.complete(_messager.ready);
    }
    return completer.future;
  }

  /// close
  ///
  /// Close the controller
  void close() {
    _messager.close(false);
  }
}
