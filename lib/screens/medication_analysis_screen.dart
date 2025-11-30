import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/providers/medical_assistant_provider.dart';
import 'package:medimatch/services/medical_assistant_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicationAnalysisScreen extends StatefulWidget {
  const MedicationAnalysisScreen({
    super.key,
  });

  @override
  State<MedicationAnalysisScreen> createState() => _MedicationAnalysisScreenState();
}

class _MedicationAnalysisScreenState extends State<MedicationAnalysisScreen> {
  final MedicalAssistantApiService _apiService = MedicalAssistantApiService();

  @override
  void initState() {
    super.initState();
    _populateMedicationData();
  }

  Future<void> _populateMedicationData() async {
    final medicalAssistantProvider = Provider.of<MedicalAssistantProvider>(context, listen: false);
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);

    // If MedicalAssistantProvider is empty but we have prescriptions, log for debugging
    if (medicalAssistantProvider.medications.isEmpty && prescriptionProvider.prescriptions.isNotEmpty) {
      final latestPrescription = prescriptionProvider.prescriptions.first;

      // Log prescription data for debugging
      debugPrint('Found prescription with ${latestPrescription.medicines.length} medicines');
      debugPrint('Prescription medicines: ${latestPrescription.medicines.map((m) => m.name).join(', ')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Medication Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      body: _buildMedicationInfoTab(),
    );
  }


  Widget _buildMedicationInfoTab() {
    // Try to get medications from MedicalAssistantProvider first
    final medicalAssistantProvider = Provider.of<MedicalAssistantProvider>(context);
    List<MedicationAnalysis> medications = medicalAssistantProvider.medications;

    // If no medications from MedicalAssistantProvider, try to create from PrescriptionProvider
    if (medications.isEmpty) {
      final prescriptionProvider = Provider.of<PrescriptionProvider>(context);
      final prescriptions = prescriptionProvider.prescriptions;

      if (prescriptions.isNotEmpty) {
        // Convert prescription medicines to MedicationAnalysis for display
        final latestPrescription = prescriptions.first;
        medications = latestPrescription.medicines.map((medicine) {
          return MedicationAnalysis(
            name: medicine.name,
            purpose: medicine.instructions.isNotEmpty ? medicine.instructions : 'Medication for treatment',
            pros: 'Effective treatment for prescribed condition',
            cons: 'May have side effects - consult your doctor',
            alternatives: [
              if (medicine.genericName != null && medicine.genericName!.isNotEmpty)
                MedicationAlternative(
                  name: medicine.genericName!,
                  price: medicine.genericPrice?.toInt() ?? 50,
                  buyLink: 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(medicine.genericName!)}',
                  type: 'low-cost',
                ),
              MedicationAlternative(
                name: '${medicine.name} Premium',
                price: (medicine.brandPrice?.toInt() ?? medicine.genericPrice?.toInt() ?? 100) + 50,
                buyLink: 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(medicine.name)}',
                type: 'high-cost',
              ),
            ],
            buyLink: 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(medicine.name)}',
          );
        }).toList();
      }
    }

    if (medications.isEmpty) {
      return _buildNoMedicationDataState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.green.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Medication Purchase Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${medications.length} medication${medications.length > 1 ? 's' : ''} available for purchase',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Medications List
          ...medications.map((medication) => _buildMedicationCard(medication)),
        ],
      ),
    );
  }


  Widget _buildNoMedicationDataState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.medication_rounded,
                size: 64,
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Medication Data Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please scan a prescription first to see medication purchase options and price comparisons.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Scan Prescription'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(MedicationAnalysis medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        medication.purpose,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Original Medicine Buy Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.store_rounded,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Original Medicine',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(medication.buyLink),
                      icon: const Icon(Icons.shopping_cart, size: 16),
                      label: Text('Buy ${medication.name}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (medication.alternatives.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Alternatives & Price Comparison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...medication.alternatives.map((alternative) => _buildAlternativeCard(alternative)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeCard(MedicationAlternative alternative) {
    final isLowCost = alternative.type == 'low-cost';
    final color = isLowCost ? Colors.orange : Colors.purple;
    final icon = isLowCost ? Icons.savings_rounded : Icons.star_rounded;
    final label = isLowCost ? 'Budget Option' : 'Premium Option';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${alternative.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alternative.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchUrl(alternative.buyLink),
              icon: const Icon(Icons.shopping_cart, size: 14),
              label: Text('Buy for ₹${alternative.price}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              action: SnackBarAction(
                label: 'Copy URL',
                textColor: Colors.white,
                onPressed: () {
                  // Copy URL to clipboard (you might want to add clipboard functionality)
                  print('Copy URL: $cleanUrl');
                },
              ),
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
}
