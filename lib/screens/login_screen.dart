import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/providers/auth_provider.dart';
import 'package:medimatch/screens/home_screen.dart';
import 'package:medimatch/screens/signup_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailLogin = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSetupInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Firebase Setup Required'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'The authentication is not working because Firebase has not been properly configured.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('To set up Firebase authentication:'),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Create a Firebase project in the Firebase Console',
                  ),
                  const Text('2. Register your Android and iOS apps'),
                  const Text(
                    '3. Download the configuration files (google-services.json and GoogleService-Info.plist)',
                  ),
                  const Text(
                    '4. Replace the placeholder files with the real ones',
                  ),
                  const Text(
                    '5. Enable Authentication methods in the Firebase Console',
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://console.firebase.google.com/',
                      );
                      try {
                        await launchUrl(url);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open URL: $e')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Open Firebase Console',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please refer to the README_FIREBASE_AUTH.md file for detailed instructions.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showGoogleSignInErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Google Sign-In Error'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'There was an error signing in with Google. This is likely due to incorrect OAuth client configuration.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('To fix this issue:'),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Get the correct OAuth client ID from Firebase Console',
                  ),
                  const Text(
                    '2. Update the web/index.html file with the correct client ID',
                  ),
                  const Text(
                    '3. Update the FirebaseService class with the correct client ID',
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://console.firebase.google.com/',
                      );
                      try {
                        await launchUrl(url);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not open URL: $e')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Open Firebase Console',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please refer to the GOOGLE_SIGNIN_SETUP.md file for detailed instructions.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showForgotPasswordDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Password'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    try {
                      final success = await authProvider.sendPasswordResetEmail(
                        emailController.text.trim(),
                      );
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password reset email sent. Check your inbox.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        _showSetupInstructionsDialog(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        _showSetupInstructionsDialog(context);
                      }
                    }
                  }
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or image
                const Icon(
                  Icons.medical_services_rounded,
                  size: 80,
                  color: Colors.teal,
                ),
                const SizedBox(height: 24),

                // App name
                const Text(
                  'MediMatch',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),

                // App description
                const Text(
                  'Your personal medical assistant',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Toggle between email and social login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Social Login'),
                      selected: !_isEmailLogin,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isEmailLogin = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Email Login'),
                      selected: _isEmailLogin,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isEmailLogin = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_isEmailLogin)
                  // Email login form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        // Forgot password link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _showForgotPasswordDialog(context, authProvider);
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login button
                        if (authProvider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  final success = await authProvider
                                      .signInWithEmailAndPassword(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                      );

                                  if (success && context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const HomeScreen(),
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    _showSetupInstructionsDialog(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showSetupInstructionsDialog(context);
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Sign up link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  // Social login buttons
                  Column(
                    children: [
                      // Google Sign-In button
                      if (authProvider.isLoading)
                        const CircularProgressIndicator()
                      else
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final success =
                                      await authProvider.signInWithGoogle();
                                  if (success && context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const HomeScreen(),
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    _showGoogleSignInErrorDialog(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showGoogleSignInErrorDialog(context);
                                  }
                                }
                              },
                              icon: Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.g_translate,
                                    size: 24,
                                    color: Colors.red,
                                  );
                                },
                              ),
                              label: const Text('Sign in with Google'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Sign Up'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                _showSetupInstructionsDialog(context);
                              },
                              child: const Text('Firebase Setup Instructions'),
                            ),
                          ],
                        ),
                    ],
                  ),

                // Error message
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
