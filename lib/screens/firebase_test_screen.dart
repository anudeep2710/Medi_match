import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medimatch/utils/firebase_test.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'test123456');
  bool _isLoading = false;
  String _status = 'Ready to test Firebase';
  Color _statusColor = Colors.blue;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateStatus(String message, Color color) {
    setState(() {
      _status = message;
      _statusColor = color;
    });
  }

  Future<void> _runFirebaseTests() async {
    setState(() {
      _isLoading = true;
    });

    _updateStatus('Running Firebase diagnostics...', Colors.orange);

    try {
      // Run comprehensive Firebase tests
      final results = await FirebaseTest.testFirebaseConnection();

      // Display results
      String statusMessage = '';
      Color statusColor = Colors.green;

      if (results['firebase_initialized'] == true) {
        statusMessage += '✅ Firebase initialized\n';
      } else {
        statusMessage += '❌ Firebase initialization failed\n';
        statusColor = Colors.red;
      }

      if (results['auth_configured'] == true) {
        statusMessage += '✅ Auth configured\n';
      } else {
        statusMessage += '❌ Auth configuration error\n';
        statusColor = Colors.red;
      }

      if (results['network_connectivity'] == true) {
        statusMessage += '✅ Network connectivity\n';
      } else {
        statusMessage += '❌ Network connectivity failed\n';
        statusColor = Colors.red;
      }

      if (results['email_auth_enabled'] == true) {
        statusMessage += '✅ Email/Password auth enabled\n';
      } else {
        statusMessage += '❌ Email/Password auth NOT enabled\n';
        statusColor = Colors.red;
      }

      _updateStatus(statusMessage.trim(), statusColor);

    } catch (e) {
      _updateStatus('Test failed: $e', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testRegistration() async {
    setState(() {
      _isLoading = true;
    });

    _updateStatus('Testing user registration...', Colors.orange);

    try {
      final results = await FirebaseTest.testUserRegistration(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (results['registration_success'] == true) {
        _updateStatus('✅ Registration test successful!', Colors.green);
      } else {
        final errorCode = results['error_code'] ?? 'unknown';
        final errorMessage = results['error_message'] ?? 'Unknown error';
        _updateStatus('❌ Registration failed:\nCode: $errorCode\nMessage: $errorMessage', Colors.red);
      }

    } catch (e) {
      _updateStatus('Registration test failed: $e', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testFirestore() async {
    setState(() {
      _isLoading = true;
    });

    _updateStatus('Testing Firestore connection...', Colors.orange);

    try {
      final firestore = FirebaseFirestore.instance;

      // Try to write a test document
      await firestore.collection('test').doc('connection_test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
      });

      // Try to read it back
      final doc = await firestore.collection('test').doc('connection_test').get();

      if (doc.exists) {
        _updateStatus('✅ Firestore connection successful!', Colors.green);

        // Clean up test document
        await firestore.collection('test').doc('connection_test').delete();
      } else {
        _updateStatus('❌ Firestore read failed', Colors.red);
      }

    } catch (e) {
      _updateStatus('❌ Firestore test failed: $e', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Firebase Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _statusColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 14,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Test Email Field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Test Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Test Password Field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Test Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 24),

            // Test Buttons
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _runFirebaseTests,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Run Firebase Diagnostics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _testRegistration,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Test User Registration'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _testFirestore,
                    icon: const Icon(Icons.storage),
                    label: const Text('Test Firestore Database'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Instructions Card
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Setup Instructions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Go to Firebase Console\n'
                      '2. Enable Authentication → Email/Password\n'
                      '3. Enable Firestore Database\n'
                      '4. Run tests above to verify setup',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Open Firebase Console
                        // You can add URL launcher here if needed
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open Firebase Console'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
