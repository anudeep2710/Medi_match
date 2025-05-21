import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/providers/translation_provider.dart';
import 'package:medimatch/providers/settings_provider.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailsScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  bool _isLoadingAlternatives = false;
  bool _isLoadingExplanation = false;
  List<Map<String, dynamic>> _alternatives = [];
  String? _explanation;

  @override
  void initState() {
    super.initState();
    _loadAlternatives();
    _explainInstructions();
  }

  Future<void> _loadAlternatives() async {
    setState(() {
      _isLoadingAlternatives = true;
    });

    try {
      final prescriptionProvider = Provider.of<PrescriptionProvider>(
        context,
        listen: false,
      );
      final alternatives = await prescriptionProvider.getAlternatives([
        widget.medicine.name,
      ]);

      setState(() {
        _alternatives = alternatives;
        _isLoadingAlternatives = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAlternatives = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load alternatives: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _explainInstructions() async {
    setState(() {
      _isLoadingExplanation = true;
    });

    try {
      final translationProvider = Provider.of<TranslationProvider>(
        context,
        listen: false,
      );
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );

      final explanation = await translationProvider.explainAndTranslate(
        widget.medicine.instructions,
        settingsProvider.currentLanguage,
      );

      setState(() {
        _explanation = explanation;
        _isLoadingExplanation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingExplanation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to explain instructions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.medicine.name)),
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
                      '${widget.medicine.name} ${widget.medicine.dosage}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.medicine.instructions,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Simplified Explanation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoadingExplanation
                ? const Center(child: CircularProgressIndicator())
                : _explanation != null
                ? Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _explanation!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
                : const Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No explanation available',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            const Text(
              'Generic Alternatives',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoadingAlternatives
                ? const Center(child: CircularProgressIndicator())
                : _alternatives.isNotEmpty
                ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _alternatives.length,
                  itemBuilder: (context, index) {
                    final alternative = _alternatives[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Brand: ${alternative['brand']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Generic: ${alternative['generic']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Savings: ${alternative['savings']}'),
                                Text(
                                  'Effectiveness: ${alternative['effectiveness']}',
                                  style: TextStyle(
                                    color:
                                        alternative['effectiveness'] == 'Same'
                                            ? Colors.green
                                            : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
                : const Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No generic alternatives found',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add to reminders
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Add to Reminders'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
