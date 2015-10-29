/*
 * Package : dartivity_control
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/10/2015
 * Copyright :  S.Hamblett 2015
 */


import 'dart:io';
import 'dart:convert';

import 'package:dartivity_control/dartivity_control.dart';

void main(List<String> arguments) async {

  // Get Apache
  Apache myAp = new Apache();

  // Get and initialise Dartivity Control
  DartivityControl control = new DartivityControl(myAp);
  try {
    await control.initialise();
  } catch (e) {
    control.despatch(DartivityControlPageManager.error);
    myAp.flushBuffers(true);
  }

  // Pre-process the input parameters and despatch the request.
  if ( myAp.Request.containsKey('id')) {

    String id = myAp.Request['id'];
    if ( id != null ) {

      try {

        int pageId = int.parse(id);
        control.despatch(pageId);

      } catch(e) {

        control.despatch(DartivityControlCfg.defaultPage);
      }
    } else {

      control.despatch(DartivityControlCfg.errorPage);
    }
  } else {
    control.despatch(DartivityControlCfg.defaultPage);
  }

  // Flush buffers and exit
  myAp.flushBuffers();
	  
}
