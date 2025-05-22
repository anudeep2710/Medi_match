import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/providers/medical_assistant_provider.dart';
import 'package:medimatch/services/medical_assistant_api_service.dart';
import 'package:medimatch/models/health_tips.dart';
import 'package:medimatch/widgets/health_tips/health_tips_card.dart';
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
  HealthTips? _healthTips;
  bool _isLoading = false;
  String? _error;
  final Map<String, bool> _expandedSections = {
    'general': false,
    'dietary': false,
    'lifestyle': false,
    'sideEffects': false,
    'doctor': false,
    'adherence': false,
  };

  @override
  void initState() {
    super.initState();
    _generateHealthTips();
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

  Future<void> _generateHealthTips() async {
    final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
    final prescriptions = prescriptionProvider.prescriptions;

    if (prescriptions.isEmpty) {
      setState(() {
        _error = 'No prescriptions found. Please scan a prescription first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the latest prescription
      final latestPrescription = prescriptions.first;
      final medicines = latestPrescription.medicines;

      // Create medicine names for health tips
      final medicineNames = medicines.map((m) => m.name).join(', ');

      final response = await _apiService.getHealthTips(medicineNames);

      setState(() {
        _healthTips = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate health tips: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('AI Health Analysis'),
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
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _isLoading ? null : _generateHealthTips,
                tooltip: 'Regenerate Tips',
                color: Colors.white,
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.psychology_rounded),
                text: 'Health Tips',
              ),
              Tab(
                icon: Icon(Icons.shopping_cart_rounded),
                text: 'Buy Medicines',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHealthTipsTab(),
            _buildMedicationInfoTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipsTab() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_healthTips != null) {
      return _buildHealthTipsContent();
    }

    return _buildEmptyState();
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

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'AI is analyzing your medications...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generating personalized health tips',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to Generate Tips',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _generateHealthTips,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medical_information_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Analysis Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan a prescription to get personalized health tips',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.document_scanner_rounded),
                label: const Text('Scan Prescription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTipsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
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
                        'AI Health Analysis',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Personalized tips based on your medications',
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This is AI-generated advice. Always consult your healthcare provider for personalized medical guidance.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Health Tips Cards will be added here
            if (_healthTips != null) ...[
              // General Health Advice
              GeneralHealthAdviceCard(
                advice: _healthTips!.generalAdvice,
                isExpanded: _expandedSections['general']!,
                onTap: () => _toggleSection('general'),
              ),

              // Dietary Considerations
              DietaryConsiderationsCard(
                dietary: _healthTips!.dietary,
                isExpanded: _expandedSections['dietary']!,
                onTap: () => _toggleSection('dietary'),
              ),

              // Lifestyle Recommendations
              LifestyleRecommendationsCard(
                lifestyle: _healthTips!.lifestyle,
                isExpanded: _expandedSections['lifestyle']!,
                onTap: () => _toggleSection('lifestyle'),
              ),

              // Side Effects Monitoring
              SideEffectsMonitoringCard(
                sideEffects: _healthTips!.sideEffects,
                isExpanded: _expandedSections['sideEffects']!,
                onTap: () => _toggleSection('sideEffects'),
              ),

              // Doctor Consultation
              DoctorConsultationCard(
                guidance: _healthTips!.doctorGuidance,
                isExpanded: _expandedSections['doctor']!,
                onTap: () => _toggleSection('doctor'),
              ),

              // Medication Adherence
              MedicationAdherenceCard(
                adherence: _healthTips!.adherence,
                isExpanded: _expandedSections['adherence']!,
                onTap: () => _toggleSection('adherence'),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _expandAllSections(),
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Expand All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _collapseAllSections(),
                      icon: const Icon(Icons.expand_less),
                      label: const Text('Collapse All'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'No health tips available. Please try again.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  void _expandAllSections() {
    setState(() {
      _expandedSections.updateAll((key, value) => true);
    });
  }

  void _collapseAllSections() {
    setState(() {
      _expandedSections.updateAll((key, value) => false);
    });
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
