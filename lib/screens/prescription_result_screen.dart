import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:medimatch/models/prescription.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/providers/reminder_provider.dart';
import 'package:medimatch/providers/translation_provider.dart';
import 'package:medimatch/providers/settings_provider.dart';
import 'package:medimatch/screens/medicine_details_screen.dart';

class PrescriptionResultScreen extends StatefulWidget {
  final Prescription prescription;

  const PrescriptionResultScreen({
    super.key,
    required this.prescription,
  });

  @override
  State<PrescriptionResultScreen> createState() => _PrescriptionResultScreenState();
}

class _PrescriptionResultScreenState extends State<PrescriptionResultScreen> {
  bool _isCheckingInteractions = false;
  String? _interactionsResult;
  bool _isGeneratingReminders = false;
  bool _isTranslating = false;
  String? _translatedSummary;

  @override
  void initState() {
    super.initState();
    _checkInteractions();
  }

  Future<void> _checkInteractions() async {
    if (widget.prescription.medicines.length > 1) {
      setState(() {
        _isCheckingInteractions = true;
      });

      try {
        final prescriptionProvider = Provider.of<PrescriptionProvider>(context, listen: false);
        final medicineNames = widget.prescription.medicines.map((m) => m.name).toList();
        final interactions = await prescriptionProvider.checkInteractions(medicineNames);

        setState(() {
          _interactionsResult = interactions;
          _isCheckingInteractions = false;
        });
      } catch (e) {
        setState(() {
          _interactionsResult = 'Failed to check interactions: $e';
          _isCheckingInteractions = false;
        });
      }
    }
  }

  Future<void> _generateReminders() async {
    setState(() {
      _isGeneratingReminders = true;
    });

    try {
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      await reminderProvider.generateReminders(widget.prescription.medicines);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminders generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate reminders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGeneratingReminders = false;
      });
    }
  }

  Future<void> _translateSummary() async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final translationProvider = Provider.of<TranslationProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      final summary = _generateSummary();
      final translated = await translationProvider.translateText(
        summary,
        settingsProvider.currentLanguage,
      );

      setState(() {
        _translatedSummary = translated;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translatedSummary = 'Failed to translate: $e';
        _isTranslating = false;
      });
    }
  }

  String _generateSummary() {
    final medicines = widget.prescription.medicines;
    final buffer = StringBuffer();
    
    buffer.writeln('Prescription for ${widget.prescription.patientName}');
    buffer.writeln('Date: ${DateFormat('MMM d, yyyy').format(widget.prescription.date)}');
    buffer.writeln('');
    buffer.writeln('Medicines:');
    
    for (int i = 0; i < medicines.length; i++) {
      final medicine = medicines[i];
      buffer.writeln('${i + 1}. ${medicine.name} ${medicine.dosage} - ${medicine.instructions}');
    }
    
    if (_interactionsResult != null) {
      buffer.writeln('');
      buffer.writeln('Interactions:');
      buffer.writeln(_interactionsResult);
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _isTranslating ? null : _translateSummary,
            tooltip: 'Translate',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _isGeneratingReminders ? null : _generateReminders,
            tooltip: 'Generate Reminders',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient: ${widget.prescription.patientName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateFormat('MMM d, yyyy').format(widget.prescription.date)}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    if (widget.prescription.doctorName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Doctor: ${widget.prescription.doctorName}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Medicines',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.prescription.medicines.length,
              itemBuilder: (context, index) {
                final medicine = widget.prescription.medicines[index];
                return _buildMedicineCard(medicine);
              },
            ),
            const SizedBox(height: 20),
            if (_isCheckingInteractions)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Checking for interactions...'),
                  ],
                ),
              )
            else if (_interactionsResult != null) ...[
              const Text(
                'Potential Interactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_interactionsResult!),
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (_isTranslating)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Translating...'),
                  ],
                ),
              )
            else if (_translatedSummary != null) ...[
              Text(
                'Summary in ${settingsProvider.language}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_translatedSummary!),
                ),
              ),
            ],
            const SizedBox(height: 30),
            if (_isGeneratingReminders)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Generating reminders...'),
                  ],
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  onPressed: _generateReminders,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Generate Reminders'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          '${medicine.name} ${medicine.dosage}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(medicine.instructions),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicineDetailsScreen(medicine: medicine),
            ),
          );
        },
      ),
    );
  }
}
