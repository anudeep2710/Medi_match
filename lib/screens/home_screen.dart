import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:medimatch/models/prescription.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/screens/scan_prescription_screen.dart';
import 'package:medimatch/screens/scan_handwritten_prescription_screen.dart';
import 'package:medimatch/screens/reminders_screen.dart';
import 'package:medimatch/screens/pharmacy_screen.dart';
import 'package:medimatch/screens/settings_screen.dart';

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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: 'Pharmacy',
          ),
        ],
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
                    'icon': Icons.medication,
                    'title': 'My Medicines',
                    'color': Colors.blue,
                    'onTap': () => setState(() => _selectedIndex = 2),
                  },
                  {
                    'icon': Icons.notifications_active,
                    'title': 'Reminders',
                    'color': Colors.orange,
                    'onTap': () => setState(() => _selectedIndex = 3),
                  },
                  {
                    'icon': Icons.local_pharmacy,
                    'title': 'Nearby Pharmacies',
                    'color': Colors.green,
                    'onTap': () => setState(() => _selectedIndex = 4),
                  },
                  {
                    'icon': Icons.draw,
                    'title': 'Scan Handwritten Prescription',
                    'color': Colors.red,
                    'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const ScanHandwrittenPrescriptionScreen(),
                        ),
                      );
                    },
                  },
                  {
                    'icon': Icons.settings,
                    'title': 'Settings',
                    'color': Colors.purple,
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
            const Text(
              'Health Tips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Health Tips Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Tip of the Day',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Remember to take your medications at the same time each day to maintain consistent levels in your bloodstream.',
                      style: TextStyle(fontSize: 16),
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color.withAlpha(25),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
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
