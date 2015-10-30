/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 28/09/2015
 * Copyright :  S.Hamblett 2015
 */

part of dartivity_control;

class DartivityControlMessaging {
  /// Authenticated
  bool _authenticated = false;

  /// Initialised
  bool _initialised = false;

  /// Ready, as in for use
  bool get ready => _authenticated && _initialised;

  /// Pubsub topic
  final String _topic = DartivityControlCfg.MESS_TOPIC;

  String get topic => _topic;

  /// Pubsub subscription
  pubsub.Subscription _subscription;

  /// PubSub client
  pubsub.PubSub _pubsub;

  /// Dartivity client id
  String _dartivityId;

  /// Auth client, needed for closing
  auth.AutoRefreshingAuthClient _client;

  DartivityControlMessaging(String dartivityId) {
    _dartivityId = dartivityId;
  }

  /// initialise
  /// Initialises the messaging class.
  ///
  /// Must be called before class usage
  ///
  /// credentialsFile - Path to the credentials file
  /// which should be in JSON format
  /// projectName - The project name(actually the google project id)
  Future<bool> initialise(String credentialsFile, String projectName) async {
    // Get the credentials file as a string and create a credentials class
    String jsonCredentials = new File(credentialsFile).readAsStringSync();
    auth.ServiceAccountCredentials credentials =
    new auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    // Create a scoped pubsub client with our authenticated credentials
    List<String> scopes = []
      ..addAll(pubsub.PubSub.SCOPES);
    _client = await auth.clientViaServiceAccount(credentials, scopes);
    _pubsub = new pubsub.PubSub(_client, projectName);
    _authenticated = true;

    // Subscribe to our topic, 409 means already subscribed from this client
    try {
      _subscription = await _pubsub.createSubscription(_dartivityId, topic);
    } catch (e) {
      if (e.status != 409) {
        throw new DartivityControlException(
            DartivityControlException.SUBSCRIPTION_FAILED);
      } else {
        _subscription = await _pubsub.lookupSubscription(_dartivityId);
      }
    }
    _initialised = true;
    return _initialised;
  }

  /// recieve
  ///
  /// Recieve a message from our subscription
  ///
  /// wait - whether to wait for a message or not, default is not
  Future<pubsub.Message> receive({wait: true}) async {
    if (ready) {
      var pullEvent = await _subscription.pull(wait: false);
      if (pullEvent != null) {
        await pullEvent.acknowledge();
        return pullEvent.message;
      }
    }
    return null;
  }

  /// send
  ///
  /// Send a message to our subscription
  ///
  /// message - the message string to send
  Future send(String message) async {
    if (ready) await _subscription.topic.publishString(message);
  }

  /// close
  ///
  /// Close the messager
  void close() {
    // We don't need to wait, just assume pubsub will do this
    _initialised = false;

    // Close the auth client
    _client.close();
    _authenticated = false;
  }
}
