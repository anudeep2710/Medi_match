import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:medimatch/models/prescription.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/providers/medical_assistant_provider.dart';
import 'package:medimatch/screens/medication_analysis_screen.dart';
import 'package:medimatch/screens/prescription_result_screen.dart';
import 'package:medimatch/services/medical_assistant_api_service.dart';

class PrescriptionAnalysisScreen extends StatefulWidget {
  final File imageFile;
  final String patientName;

  const PrescriptionAnalysisScreen({
    super.key,
    required this.imageFile,
    required this.patientName,
  });

  @override
  State<PrescriptionAnalysisScreen> createState() => _PrescriptionAnalysisScreenState();
}

class _PrescriptionAnalysisScreenState extends State<PrescriptionAnalysisScreen> {
  bool _isAnalyzing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _analyzePrescription();
  }

  Future<void> _analyzePrescription() async {
    try {
      // Get the provider
      final medicalAssistantProvider = Provider.of<MedicalAssistantProvider>(
        context,
        listen: false
      );

      // Analyze the prescription using the provider
      final success = await medicalAssistantProvider.analyzePrescription(widget.imageFile);

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          if (!success) {
            _errorMessage = medicalAssistantProvider.error;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to analyze prescription: $e';
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicalAssistantProvider = Provider.of<MedicalAssistantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Analysis'),
      ),
      body: _isAnalyzing || medicalAssistantProvider.isLoading
          ? _buildLoadingView()
          : _errorMessage != null || medicalAssistantProvider.error != null
              ? _buildErrorView()
              : _buildResultsView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Analyzing prescription...'),
          SizedBox(height: 10),
          Text(
            'This may take a moment as we identify medications and alternatives.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    final medicalAssistantProvider = Provider.of<MedicalAssistantProvider>(context, listen: false);
    final errorMsg = _errorMessage ?? medicalAssistantProvider.error ?? 'An unknown error occurred';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    final medicalAssistantProvider = Provider.of<MedicalAssistantProvider>(context);
    final medications = medicalAssistantProvider.medications;
    final possibleIllness = medicalAssistantProvider.possibleIllness;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prescription image
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(
                  widget.imageFile,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient: ${widget.patientName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${DateTime.now().toString().substring(0, 10)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Analysis results summary
          Text(
            'Analysis Results',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'We found ${medications.length} medications in your prescription.',
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicationAnalysisScreen(
                          medications: medications,
                          possibleIllness: possibleIllness,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.medication),
                  label: const Text('View Detailed Analysis'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _proceedToStandardProcessing();
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue to Standard Processing'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Medications preview
          Text(
            'Medications Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          ...medications.map((medication) => _buildMedicationPreviewCard(medication)),

          // Always show the possible illness section, even if empty
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Possible Illness',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    possibleIllness.isNotEmpty
                        ? possibleIllness
                        : 'Based on the medications in your prescription, a possible condition is being treated. Please consult your doctor for accurate diagnosis.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: This is not a diagnosis. Please consult a healthcare professional.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationPreviewCard(MedicationAnalysis medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          medication.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(medication.purpose),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationAnalysisScreen(
                medications: [medication],
                possibleIllness: '',
              ),
            ),
          );
        },
      ),
    );
  }

  void _proceedToStandardProcessing() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final prescriptionProvider = Provider.of<PrescriptionProvider>(
        context,
        listen: false,
      );

      // Get the medications from the medical assistant provider
      final medicalAssistantProvider = Provider.of<MedicalAssistantProvider>(
        context,
        listen: false
      );

      // First try to use the standard prescription scanning
      final prescription = await prescriptionProvider.scanPrescription(
        widget.imageFile,
        widget.patientName,
      );

      if (prescription != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionResultScreen(
              prescription: prescription,
            ),
          ),
        );
      } else {
        // If standard processing fails, create a basic prescription from the AI-detected medications
        if (medicalAssistantProvider.medications.isNotEmpty && mounted) {
          // Convert MedicationAnalysis to Medicine objects
          final medicines = medicalAssistantProvider.medications.map((med) {
            return Medicine(
              name: med.name,
              dosage: '',  // We don't have dosage information from the AI
              instructions: med.purpose,
              genericName: med.alternatives.isNotEmpty ? med.alternatives.first.name : '',
              genericPrice: med.alternatives.isNotEmpty ? med.alternatives.first.price.toDouble() : null,
              brandPrice: null,
            );
          }).toList();

          // Create a new prescription
          final newPrescription = Prescription(
            id: const Uuid().v4(),
            patientName: widget.patientName,
            date: DateTime.now(),
            medicines: medicines,
            rawOcrText: medicalAssistantProvider.lastResponse?.response ?? '',
          );

          // Save the prescription
          await prescriptionProvider.savePrescription(newPrescription);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PrescriptionResultScreen(
                  prescription: newPrescription,
                ),
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                prescriptionProvider.error ?? 'Failed to process prescription',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isAnalyzing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }
}
