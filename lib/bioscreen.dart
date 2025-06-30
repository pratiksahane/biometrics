import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class Bioscreen extends StatefulWidget {
  const Bioscreen({super.key});

  @override
  State<Bioscreen> createState() => _BioscreenState();
}

class _BioscreenState extends State<Bioscreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  String _authError = '';
  TextEditingController textEditingController=TextEditingController();

  Future<void> _authenticate() async {
  try {
    final bool deviceSupported = await auth.isDeviceSupported();
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

    if (!deviceSupported) {
      setState(() => _authError = 'Device not supported for authentication');
      return;
    }

    if (!canCheckBiometrics || availableBiometrics.isEmpty) {
      setState(() => _authError = 'No biometrics enrolled or hardware unavailable');
      return;
    }

    final bool authenticated = await auth.authenticate(
      localizedReason: 'Authenticate to access secure data',
      options: const AuthenticationOptions(
        biometricOnly: false,
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );

    setState(() {
      _isAuthenticated = authenticated;
      _authError = authenticated ? '' : 'Authentication failed';
    });
  } catch (e) {
    setState(() => _authError = 'Error: ${e.toString()}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Authenciation")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                obscureText:true,
                controller: textEditingController,
                decoration: InputDecoration(
                  helperText: "Enter Pin or password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
              
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                const validPin = '1234'; 
                if (textEditingController.text == validPin) {
                  setState(() {
                    _isAuthenticated = true;
                    _authError = '';
                  });
                } else {
                  setState(() {
                    _authError = 'Invalid PIN';
                  });
                }
              },
              child: const Text("Submit PIN"),
            ),
            const SizedBox(height: 20),
            Icon(
              _isAuthenticated ? Icons.lock_open : Icons.lock,
              size: 50,
              color: _isAuthenticated ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            if (_authError.isNotEmpty)
              Text(
                _authError,
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: const Text("Scan FingerPrint"),
            ),
          ],
        ),
      ),
    );
  }
}