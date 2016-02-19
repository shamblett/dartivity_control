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
  static const String ALERT = "alert.html";
  static const String MONITORING_RESOURCE_PREFIX = "monitoring_resource_";
  static const String MONITORING_RESOURCE_POSTFIX = ".html";
  static const String NO_PROVIDER = 'none';

  /// Alert types
  static const ALERT_INFO = "alert-info";
  static const ALERT_WARNING = "alert-warning";
  static const ALERT_DANGER = "alert-danger";
  static const ALERT_SUCCESS = "alert-success";

  /// Alert text
  static const ALERT_TEXT_DISCOVER_OK =
      "Discovery has completed, please refresh the resource list after approx 5 seconds";
  static const ALERT_TEXT_REFRESH_OK = "Refresh has completed";
  static const ALERT_TEXT_NO_DATABASE = "Unable to connect to the dartivity database";
  static const ALERT_TEXT_UNABLE_TO_GET_DATA = "Unable to read from the database";

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
  mess.DartivityMessaging _messager;

  DartivityControlPageManager(String documentRoot, String httpHost,
      mess.DartivityMessaging messager) {
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

  /// buildResourceListMessage
  /// Construct a list of resources filtering duplicates from a list of messages
  String _buildResourceListMessage(List<mess.DartivityMessage> resources) {
    String output = "";
    if (resources == null) return output;
    String resourceTpl = getHtmlSectionContents(RESOURCE);
    tpl.Template template = new tpl.Template(resourceTpl,
        name: 'resource.html', htmlEscapeValues: false);
    resources.forEach((resource) {
      output += template.renderString(
          {'deviceId': resource.resourceName, 'dartivityId': resource.source,
            'provider': resource.provider[0].toUpperCase() +
                resource.provider.substring(1),
            'source': 'Live'});
    });
    return output;
  }

  /// buildResourceListDatabase
  /// Construct a list of resources filtering duplicates from the database
  String _buildResourceListDatabase(
      Map<String, db.DartivityResource>resources) {
    String output = "";
    if (resources == null) return output;
    String resourceTpl = getHtmlSectionContents(RESOURCE);
    tpl.Template template = new tpl.Template(resourceTpl,
        name: 'resource.html', htmlEscapeValues: false);
    resources.forEach((key, resource) {
      output += template.renderString(
          {
            'deviceId': resource.id,
            'dartivityId': resource.clientId,
            'provider': resource.provider[0].toUpperCase() +
                resource.provider.substring(1),
            'source': 'Storage'
          });
    });
    return output;
  }

  /// buildAlertList
  /// Build the alert list for the monitoring page
  String _buildAlertList(String type, String text) {
    String alertTpl = getHtmlSectionContents(ALERT);
    tpl.Template template =
    new tpl.Template(alertTpl, name: 'alert.html', htmlEscapeValues: false);
    String output =
    template.renderString({'alertType': type, 'alertText': text});
    return output;
  }

  /// buildResourceDetails
  /// Build the resource details apnel for the monitoring page
  String _buildResourceDetails(String provider, dynamic resource) {
    String templateName = MONITORING_RESOURCE_PREFIX +
        provider + MONITORING_RESOURCE_POSTFIX;
    String resourceTpl = getHtmlSectionContents(templateName);
    tpl.Template template =
    new tpl.Template(resourceTpl, name: templateName, htmlEscapeValues: false);
    String output;

    switch (provider) {
      case NO_PROVIDER:
        output = template.renderString(null);
        break;

      default:
        break;
    }

    return output;
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
        String resourceList = "";
        String alertList = "";
        DateTime now = new DateTime.now();
        String tableStatus = "Discovery not yet performed";
        String resourceDetails = _buildResourceDetails(NO_PROVIDER, null);

        // Check for a submission
        bool refresh;
        bool discover;
        request.containsKey('res-refresh') ? refresh = true : refresh = false;
        request.containsKey('res-discover')
            ? discover = true
            : discover = false;
        if (refresh) {
          // Get the resources and return them
          if (request.containsKey('typeDatabase')) {
            // Get the resources from the database
            db.DartivityResourceDatabase dbase =
            new db.DartivityResourceDatabase(db_hostName, db_user, db_password);
            if (!dbase.initialised) {
              alertList += _buildAlertList(ALERT_INFO, ALERT_TEXT_NO_DATABASE);
            } else {
              Map<String, db.DartivityResource>resourceMap = new Map<String,
                  db.DartivityResource>();
              try {
                resourceMap = await dbase.all();
              } catch (e) {
                alertList +=
                    _buildAlertList(ALERT_INFO, ALERT_TEXT_UNABLE_TO_GET_DATA);
              }
              resourceList = _buildResourceListDatabase(resourceMap);
            }
          } else {
            List<mess.DartivityMessage> messageList =
            new List<mess.DartivityMessage>();
            while (true) {
              mess.DartivityMessage message = await _messager.receive();
              if (message == null) break;
              if (message.type == mess.MessageType.iHave) {
                if (!messageList.contains(message)) messageList.add(message);
              }
            }
            _messager.close(false);
            if (messageList != null) resourceList =
                _buildResourceListMessage(messageList);
          }
          alertList += _buildAlertList(ALERT_INFO, ALERT_TEXT_REFRESH_OK);
          tableStatus = "Refreshed at - ${now.toIso8601String()}";
        }
        if (discover) {
          // Send a who has globally
          String resourceName =
          request['res-name'] == "" ? "/oic/res" : request['res-name'];
          mess.DartivityMessage whoHas = new mess.DartivityMessage.whoHas(
              mess.DartivityMessage.ADDRESS_WEB_SERVER, resourceName);
          await _messager.send(whoHas);
          _messager.close(false);
          alertList += _buildAlertList(ALERT_INFO, ALERT_TEXT_DISCOVER_OK);
          tableStatus = "Discovery performed at - ${now.toIso8601String()}";
        }

        output = template.renderString({
          'baseHref': _baseHref,
          'monitoringTpl': monitoringTplUrl,
          'resourceList': resourceList,
          'alertList': alertList,
          'tableStatus': tableStatus,
          'resourceDetails': resourceDetails
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
