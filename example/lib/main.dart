import 'package:flutter/material.dart';
import 'package:key_enclave/key_enclave.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String publicKey = '';
  String signMessage = "";
  String TAG = "KEY_TAG";

  @override
  void initState() {
    super.initState();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                final pub = await KeyEnclave().generateKeyPair(TAG);
                setState(() {
                  this.publicKey = pub;
                });
              },
              child: Text("GENERATE KEY PAIR"),
            ),
            Text("PUBLIC KEY " + this.publicKey),
             RaisedButton(
              onPressed: () async {
                try {
                  // change message that you want to sign
                final signed = await KeyEnclave().signMessage(TAG,"SECURE MESSAGE");
                setState(() {
                  this.signMessage = signed;
                });
                  
                } catch (e) {
                  setState(() {
                    this.signMessage = e.toString();
                  });
                }
              },
              child: Text("SIGN MESSAGE"),
            ),
            Text("SIGN MESSAGE " + this.signMessage)
          ],
        ),
      ),
    );
  }
}
