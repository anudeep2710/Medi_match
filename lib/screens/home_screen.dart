import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:medimatch/models/prescription.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/providers/auth_provider.dart';
import 'package:medimatch/screens/scan_prescription_screen.dart';

import 'package:medimatch/screens/reminders_screen.dart';
import 'package:medimatch/screens/pharmacy_screen.dart';
import 'package:medimatch/screens/settings_screen.dart';
import 'package:medimatch/screens/donation/medication_donation_list_screen.dart';
import 'package:medimatch/screens/chat/chat_list_screen.dart';
import 'package:medimatch/screens/medication_analysis_screen.dart';
import 'package:medimatch/screens/login_screen.dart';
import 'package:medimatch/screens/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will be called after the first frame is rendered
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediMatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
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
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.document_scanner_rounded),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medication_rounded),
                label: 'Medicines',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_rounded),
                label: 'Reminders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_pharmacy_rounded),
                label: 'Pharmacy',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildScanTab();
      case 2:
        return _buildMedicinesTab();
      case 3:
        return _buildRemindersTab();
      case 4:
        return _buildPharmacyTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24,
                          child: Icon(
                            Icons.medical_services,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to MediMatch',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your AI-powered medicine assistant',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.document_scanner),
                      label: const Text('Scan Prescription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1; // Switch to scan tab
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Quick Actions Grid - Using GridView.builder for better responsiveness
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate the best number of columns based on screen width
                final double screenWidth = constraints.maxWidth;
                final int crossAxisCount = screenWidth > 600 ? 3 : 2;

                // Adjust aspect ratio based on available width
                final double itemWidth =
                    (screenWidth - (16 * (crossAxisCount - 1))) /
                    crossAxisCount;
                final double aspectRatio =
                    itemWidth / 110; // Height of approximately 110

                final List<Map<String, dynamic>> quickActions = [
                  {
                    'icon': Icons.volunteer_activism_rounded,
                    'title': 'Donate Medicines',
                    'color': Colors.pink,
                    'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicationDonationListScreen(),
                        ),
                      );
                    },
                  },
                  {
                    'icon': Icons.chat_rounded,
                    'title': 'Chat',
                    'color': Colors.teal,
                    'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatListScreen(),
                        ),
                      );
                    },
                  },
                  {
                    'icon': Icons.analytics_rounded,
                    'title': 'Medicine Analysis',
                    'color': Colors.deepPurple,
                    'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicationAnalysisScreen(),
                        ),
                      );
                    },
                  },
                  {
                    'icon': Icons.health_and_safety_rounded,
                    'title': 'AI Health Tips',
                    'color': Colors.green,
                    'onTap': () {
                      _generateHealthTips();
                    },
                  },
                  {
                    'icon': Icons.settings_rounded,
                    'title': 'Settings',
                    'color': Colors.grey,
                    'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  },
                ];

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: quickActions.length,
                  itemBuilder: (context, index) {
                    final action = quickActions[index];
                    return _buildQuickActionCard(
                      icon: action['icon'],
                      title: action['title'],
                      color: action['color'],
                      onTap: action['onTap'],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // AI Health Assistant Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Health Assistant',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Get personalized health tips',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan your prescription to receive AI-powered health tips and medication guidance tailored specifically for you.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 1; // Switch to scan tab
                        });
                      },
                      icon: const Icon(Icons.document_scanner_rounded),
                      label: const Text('Scan Prescription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateHealthTips() async {
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
    final prescriptions = prescriptionProvider.prescriptions;

    if (prescriptions.isEmpty) {
      _showNoMedicationsDialog();
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Generating AI Health Tips...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we analyze your medications',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // Get the latest prescription
      final latestPrescription = prescriptions.first;
      final medicines = latestPrescription.medicines;
      final medicineNames = medicines.map((m) => m.name).join(', ');

      // Create a comprehensive prompt for health tips
      final prompt = '''
Generate comprehensive health tips for a patient taking these medications: $medicineNames

Please provide detailed advice in the following categories:
1. General Health Advice - Overall wellness tips while on these medications
2. Dietary Considerations - Foods to eat, avoid, and timing with medications
3. Lifestyle Recommendations - Exercise, sleep, and daily routine adjustments
4. Side Effects Monitoring - What to watch for and when to be concerned
5. Doctor Consultation Guidance - When to contact healthcare providers
6. Medication Adherence Tips - How to stay consistent with the medication routine

Format the response in a clear, organized manner with practical, actionable advice.
Use emojis to make it more engaging and easy to read.
''';

      // Call the Gemini API
      final response = await http.post(
        Uri.parse('https://us-central1-said-eb2f5.cloudfunctions.net/gemini_medical_assistant'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final healthTips = data['response'] ?? 'No health tips available';
        _showHealthTipsResult(healthTips, medicineNames);
      } else {
        _showHealthTipsError('Failed to generate health tips. Please try again.');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showHealthTipsError('Error generating health tips: $e');
    }
  }

  void _showNoMedicationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.health_and_safety_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('No Medications Found'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To get personalized AI health tips, you need to scan a prescription first.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.document_scanner_rounded, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Scan a prescription to receive AI-powered health tips tailored to your medications',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 1; // Switch to scan tab
              });
            },
            child: const Text('Scan Now'),
          ),
        ],
      ),
    );
  }

  void _showHealthTipsResult(String healthTips, String medications) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.health_and_safety_rounded, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('AI Health Tips'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medication_rounded,
                           color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For: $medications',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  healthTips,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to medication analysis for more details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicationAnalysisScreen(),
                ),
              );
            },
            child: const Text('View Analysis'),
          ),
        ],
      ),
    );
  }

  void _showHealthTipsError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return const ScanPrescriptionScreen();
  }

  Widget _buildMedicinesTab() {
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context);
    final prescriptions = prescriptionProvider.prescriptions;

    if (prescriptionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medication, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No medicines yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Scan a prescription to add medicines',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1; // Switch to scan tab
                });
              },
              icon: const Icon(Icons.document_scanner),
              label: const Text('Scan Prescription'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        final theme = Theme.of(context);
        final formattedDate = _formatDate(prescription.date);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with patient name and delete button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prescription for ${prescription.patientName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _showDeletePrescriptionDialog(prescription);
                      },
                    ),
                  ],
                ),
              ),

              // Medicine count badge
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${prescription.medicines.length} ${prescription.medicines.length == 1 ? 'Medicine' : 'Medicines'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Medicines list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prescription.medicines.length,
                itemBuilder: (context, medicineIndex) {
                  final medicine = prescription.medicines[medicineIndex];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withAlpha(30),
                      child: Text(
                        medicine.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${medicine.name} ${medicine.dosage}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(medicine.instructions),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to medicine details
                    },
                  );
                },
              ),

              // Add reminder button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        Icons.notifications_active,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Set Reminders',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedIndex = 3; // Switch to reminders tab
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRemindersTab() {
    return const RemindersScreen();
  }

  Widget _buildPharmacyTab() {
    return const PharmacyScreen();
  }





  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }

  void _showDeletePrescriptionDialog(Prescription prescription) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Prescription'),
            content: Text(
              'Are you sure you want to delete the prescription for ${prescription.patientName}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final prescriptionProvider =
                      Provider.of<PrescriptionProvider>(context, listen: false);
                  prescriptionProvider.deletePrescription(prescription.id);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Prescription for ${prescription.patientName} deleted',
                      ),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'Dismiss',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
