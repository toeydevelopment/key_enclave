# key_enclave

For more secure when you want to communicate to ... and you want to make sure this message came from real user.

Using Keystore and Secure Enclave for stored private key 

use ECDSA512 for sign message

**NOTE THAT you can't retreve private key from mobile, I can't even do it too.**  

**NOT SUPPORTED background process because i'm not allowed to access private key when mobile turn off or locked**

for more information 

-  <a href="https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_secure_enclave"> secure enclave </a>
-  <a href="https://developer.android.com/training/articles/keystore"> keystore </a>

## Usage
To use this plugin, add `key_enclave` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).



## Features

- generate key pair (EC Algorithm) and return public key back **private key store in secure enclave(ios) and tte|keystore(android)**

- delete private key
- sign message by using private key 

## Example

``` dart
import 'package:key_enclave/key_enclave.dart';


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

```

## Upcomming Features

- verify message
- encrpyt message
- decrypt message
- add option generate key (RSA OR EC)  now supported only EC
- add option user must authen when need to use private key first


