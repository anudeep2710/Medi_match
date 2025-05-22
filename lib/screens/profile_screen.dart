import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/providers/auth_provider.dart';
import 'package:medimatch/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      // If user is not authenticated, redirect to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // User profile image
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: user.photoURL != null 
                  ? NetworkImage(user.photoURL!) 
                  : null,
                child: user.photoURL == null 
                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade700) 
                  : null,
              ),
              
              const SizedBox(height: 20),
              
              // User name
              Text(
                user.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // User email
              Text(
                user.email ?? 'No email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 30),
              
              // User information card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email verified status
                      _buildInfoRow(
                        'Email Verified',
                        user.emailVerified ? 'Yes' : 'No',
                        user.emailVerified ? Icons.check_circle : Icons.cancel,
                        user.emailVerified ? Colors.green : Colors.red,
                      ),
                      
                      const Divider(),
                      
                      // Account created date
                      _buildInfoRow(
                        'Account Created',
                        user.metadata.creationTime != null
                            ? _formatDate(user.metadata.creationTime!)
                            : 'Unknown',
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                      
                      const Divider(),
                      
                      // Last sign in date
                      _buildInfoRow(
                        'Last Sign In',
                        user.metadata.lastSignInTime != null
                            ? _formatDate(user.metadata.lastSignInTime!)
                            : 'Unknown',
                        Icons.login,
                        Colors.purple,
                      ),
                      
                      const Divider(),
                      
                      // Provider ID
                      _buildInfoRow(
                        'Sign In Method',
                        user.providerData.isNotEmpty
                            ? _getProviderName(user.providerData.first.providerId)
                            : 'Unknown',
                        Icons.security,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Sign out button
              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  String _getProviderName(String providerId) {
    switch (providerId) {
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      case 'twitter.com':
        return 'Twitter';
      case 'apple.com':
        return 'Apple';
      case 'password':
        return 'Email/Password';
      case 'phone':
        return 'Phone Number';
      default:
        return providerId;
    }
  }
}
