/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/10/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_control;

class DartivityControlPageManager {
  /// Default pages
  static const int home = 0;
  static const int error = 1;
  static const int monitoring = 2;

  /// Page names
  static const String HOME = "home.html";
  static const String ERROR = "error.html";
  static const String MONITORING = "monitoring.html";

  /// Page to file mapping list
  List<String> _pageMap = [HOME, ERROR, MONITORING];

  /// Sections
  static const String ABOUT = "about.html";
  static const String CONTACT = "contact.html";
  static const String FOOTER = "footer.html";
  static const String RESOURCE = "resource.html";

  /// Page accessors
  String pageFile(int page) {
    return _pageMap[page];
  }

  String fullPageFile(int page) {
    return _htmlPath + _pageMap[page];
  }

  /// Directory names
  static const String LIB_DIR = "lib/";
  static const String HTML_DIR = "html/";
  static const String CSS_DIR = "css/";
  static const String IMAGE_DIR = "image/";
  static const String JS_DIR = "js/";

  /// HTML path
  String _htmlPath;

  /// CSS path/url
  String _cssPath;
  String _cssUrl;

  /// Image path/url
  String _imagePath;
  String _imageUrl;

  /// JS path/url
  String _jsPath;
  String _jsUrl;

  /// Base Ref
  String _baseHref;

  /// Messager
  DartivityControlMessaging _messager;

  DartivityControlPageManager(String documentRoot, String httpHost,
                              DartivityControlMessaging messager) {
    // Set the site paths
    _htmlPath = documentRoot + '/' + LIB_DIR + HTML_DIR;
    _cssPath = documentRoot + '/' + CSS_DIR;
    _imagePath = documentRoot + '/' + IMAGE_DIR;
    _jsPath = documentRoot + '/' + JS_DIR;

    // Set the site URL's
    _cssUrl = "http://" + httpHost + '/' + CSS_DIR;
    _imageUrl = "http://" + httpHost + '/' + IMAGE_DIR;
    _jsUrl = "http://" + httpHost + '/' + JS_DIR;
    _baseHref = "http://" + httpHost + '/';

    _messager = messager;
  }

  /// pageValid
  /// Checks if a page id is valid
  bool pageValid(int pageId) {
    if ((pageId >= home) && (pageId <= _pageMap.length)) return true;
    return false;
  }

  /// getHtmlFileContents
  /// Page file contents getter
  String getHtmlFileContents(int pageId) {
    String path = _htmlPath + _pageMap[pageId];
    final File file = new File(path);
    String contents = file.readAsStringSync();
    return contents;
  }

  /// getHtmlSectionContents
  /// Section file contents getter
  String getHtmlSectionContents(String section) {
    String path = _htmlPath + section;
    final File file = new File(path);
    String contents = file.readAsStringSync();
    return contents;
  }

  /// buildResourceList
  /// Construct a list of resources
  String _buildResourceList(List<DartivityControlMessage> resources) {
    //TODO
    return getHtmlSectionContents(RESOURCE);
  }

  /// doPage
  /// Construct and return the requested page.
  Future<String> doPage(int pageId, Map request) async {
    String output;

    // Common sections
    String footerTpl = getHtmlSectionContents(FOOTER);
    tpl.Template footerTemplate = new tpl.Template(footerTpl);
    String footerOutput =
        footerTemplate.renderString({'version': DartivityControlCfg.VERSION});

    switch (pageId) {
      case home:
        String homeTpl = getHtmlFileContents(home);
        tpl.Template template = new tpl.Template(homeTpl,
            name: 'home.html', htmlEscapeValues: false);
        String homeTplUrl = _cssUrl + HOME.split('.')[0];
        String about = getHtmlSectionContents(ABOUT);
        String contact = getHtmlSectionContents(CONTACT);
        output = template.renderString({
          'baseHref': _baseHref,
          'homeTpl': homeTplUrl,
          'about': about,
          'contact': contact,
          'footer': footerOutput
        });
        break;

      case error:
        String errorTpl = getHtmlFileContents(error);
        tpl.Template template = new tpl.Template(errorTpl,
            name: 'error.html', htmlEscapeValues: false);
        String errorTplUrl = _cssUrl + ERROR.split('.')[0];
        output = template.renderString({
          'baseHref': _baseHref,
          'errorTpl': errorTplUrl,
          'footer': footerOutput
        });
        break;

      case monitoring:
        String monitoringTpl = getHtmlFileContents(monitoring);
        tpl.Template template = new tpl.Template(monitoringTpl,
        name: 'monitoring.html', htmlEscapeValues: false);
        String monitoringTplUrl = _cssUrl + MONITORING.split('.')[0];
        String resourceList;

        // Check for a submission
        bool refresh;
        bool discover;
        request.containsKey('res-refresh') ? refresh = true : refresh = false;
        request.containsKey('res-discover')
        ? discover = true
        : discover = false;
        if (refresh) {
          // Get the resources and return them
          List<DartivityControlMessage> messageList = new List<DartivityControlMessage>();
          pubsub.Message message = await _messager.receive();
          if (message != null) {
            String messageString = message.asString;
            DartivityControlMessage dartivityMessage =
            new DartivityControlMessage.fromJSON(messageString);
            messageList.add(dartivityMessage);
          }

          resourceList = _buildResourceList(messageList);
        }
        if (discover) {
          // Send a who has to all clients
          DartivityControlMessage whoHas = new DartivityControlMessage.whoHas(DartivityControlMessage.ADDRESS_WEB_SERVER,
          "/oic/res");
          await _messager.send(whoHas.toJSON());
        }

        output = template.renderString({
          'baseHref': _baseHref,
          'monitoringTpl': monitoringTplUrl,
          'resourceList': resourceList
        });
        break;
    }

    return output;
  }

  /// initialiseMessaging
  /// Only initialise messaging if we need it
  static bool initialiseMessaging(int pageId, Map postData) {
    bool out = false;
    // If the request is for monitoring and POST data is present
    // we need messaging.
    if (pageId == monitoring) {
      if (!postData.isEmpty) out = true;
    }

    return out;
  }
}
