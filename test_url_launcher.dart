import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const UrlLauncherTestApp());
}

class UrlLauncherTestApp extends StatelessWidget {
  const UrlLauncherTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Launcher Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UrlLauncherTestScreen(),
    );
  }
}

class UrlLauncherTestScreen extends StatefulWidget {
  const UrlLauncherTestScreen({super.key});

  @override
  State<UrlLauncherTestScreen> createState() => _UrlLauncherTestScreenState();
}

class _UrlLauncherTestScreenState extends State<UrlLauncherTestScreen> {
  final List<Map<String, String>> testUrls = [
    {
      'name': '1mg.com (Main Site)',
      'url': 'https://www.1mg.com',
    },
    {
      'name': 'Cipran-500 Search',
      'url': 'https://www.1mg.com/search/all?name=Cipran-500',
    },
    {
      'name': 'Supradyn Search',
      'url': 'https://www.1mg.com/search/all?name=Supradyn',
    },
    {
      'name': 'Google (Test)',
      'url': 'https://www.google.com',
    },
    {
      'name': 'Invalid URL (Test Error)',
      'url': 'invalid-url-test',
    },
  ];

  Future<void> _launchUrl(String url) async {
    try {
      // Clean and validate the URL
      String cleanUrl = url.trim();
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Opening browser...'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      }

      // Try different launch modes
      bool launched = false;

      // First try: External application (preferred for shopping links)
      try {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (e) {
        print('External application launch failed: $e');
      }

      // Second try: Platform default
      if (!launched) {
        try {
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
            );
          }
        } catch (e) {
          print('Platform default launch failed: $e');
        }
      }

      // Third try: In-app web view
      if (!launched) {
        try {
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.inAppWebView,
            );
          }
        } catch (e) {
          print('In-app web view launch failed: $e');
        }
      }

      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Could not open browser',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('URL: $cleanUrl'),
                  const SizedBox(height: 8),
                  const Text(
                    'Please copy the link and open it manually in your browser.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        // Success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Browser opened successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('URL launch error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error opening link',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Error: $e'),
                const SizedBox(height: 4),
                Text('URL: $url'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Launcher Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test URL Launcher Functionality',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap any button below to test opening URLs in the browser:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: testUrls.length,
                itemBuilder: (context, index) {
                  final urlData = testUrls[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.link,
                        color: Colors.blue.shade600,
                      ),
                      title: Text(urlData['name']!),
                      subtitle: Text(
                        urlData['url']!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _launchUrl(urlData['url']!),
                        child: const Text('Open'),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Testing Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Tap "Open" buttons to test URL launching\n'
                    '2. Check if browser opens correctly\n'
                    '3. Verify error handling for invalid URLs\n'
                    '4. Test different launch modes',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
