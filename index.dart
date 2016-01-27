/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/10/2015
 * Copyright :  S.Hamblett 2015
 */


import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:dartivity_control/dartivity_control.dart';

Future main(List<String> arguments) async {

  // Get Apache
  Apache myAp = new Apache();

  // Get Dartivity Control
  DartivityControl control = new DartivityControl(myAp);

  // Pre-process the input parameters and despatch the request.
  if ( myAp.Request.containsKey('id')) {

    String id = myAp.Request['id'];
    if ( id != null ) {

      try {

        int pageId = int.parse(id);
        // If we need messaging initialise it
        if (DartivityControlPageManager.initialiseMessaging(pageId, myAp.Post)) {
          try {
            await control.initialise();
          } catch (e) {
            await control.despatch(DartivityControlPageManager.error);
            myAp.flushBuffers(true);
          }
        }
        await control.despatch(pageId);

      } catch(e) {
        await control.despatch(DartivityControlCfg.defaultPage);
      }
    } else {
      await control.despatch(DartivityControlCfg.errorPage);
    }
  } else {
    await control.despatch(DartivityControlCfg.defaultPage);
  }

  // Flush buffers and exit
  myAp.flushBuffers();
	  
}
