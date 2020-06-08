import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:key_enclave/key_enclave.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String signMessage = "";

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = "ss";
    String _signMessage = "assss";
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await new KeyEnclave().generateKeyPair("th.co.dopa.bora.imauth.secure");
      _signMessage = await new KeyEnclave().signMessage("th.co.dopa.bora.imauth.secure", "Hello Worldskndsmnfdsnlkfsnklgdsnkgdsngdsnklgsdnklsdgnklgds");
    } on PlatformException catch(e){
      platformVersion = 'Failed to get platform version. ' +e.toString();
    } catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      signMessage = _signMessage;
    
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("PUBLIC KEY " + this._platformVersion),
            Text("SIGN MESSAGE " + this.signMessage)
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: (){
          this.initPlatformState();
        }),
      ),
    );
  }
}
