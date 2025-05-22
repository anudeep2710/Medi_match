import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medimatch/services/medical_assistant_api_service.dart';

class MedicationAnalysisScreen extends StatefulWidget {
  final List<MedicationAnalysis> medications;
  final String possibleIllness;

  const MedicationAnalysisScreen({
    super.key,
    required this.medications,
    required this.possibleIllness,
  });

  @override
  State<MedicationAnalysisScreen> createState() => _MedicationAnalysisScreenState();
}

class _MedicationAnalysisScreenState extends State<MedicationAnalysisScreen> {
  // Key for the scaffold to show snackbars
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Show a snackbar without using context
  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medication Analysis'),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medications
            ...widget.medications.map((medication) => _buildMedicationCard(context, medication)),

            // Possible illness section
            if (widget.possibleIllness.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildPossibleIllnessCard(context),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context, MedicationAnalysis medication) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication name
            Text(
              medication.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(),

            // Purpose
            if (medication.purpose.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purpose',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(medication.purpose),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Pros
            if (medication.pros.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.add_circle, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pros',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(medication.pros),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Cons
            if (medication.cons.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cons',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(medication.cons),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Buy original medicine
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Buy Original Medicine'),
              onPressed: () async {
                final url = medication.buyLink.isNotEmpty
                    ? medication.buyLink
                    : 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(medication.name)}';

                final success = await _launchUrl(url);

                if (!success && mounted) {
                  _showSnackBar('Could not open link. Please try again later.');
                }
              },
            ),

            // Alternatives
            const SizedBox(height: 16),
            Text(
              'Alternatives',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (medication.alternatives.isNotEmpty)
              ...medication.alternatives.map((alt) => _buildAlternativeItem(context, alt))
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generic alternative',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Ask your pharmacist for generic alternatives to save money',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final success = await _launchUrl('https://www.1mg.com/search/all?name=${Uri.encodeComponent("generic ${medication.name}")}');

                        if (!success && mounted) {
                          _showSnackBar('Could not open link. Please try again later.');
                        }
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeItem(BuildContext context, MedicationAlternative alternative) {
    final theme = Theme.of(context);
    final isLowCost = alternative.type == 'low-cost';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isLowCost ? Icons.trending_down : Icons.trending_up,
            color: isLowCost ? Colors.green : Colors.purple,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isLowCost ? "Low-cost" : "High-cost"}: ${alternative.name}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${alternative.price}',
                  style: TextStyle(
                    color: isLowCost ? Colors.green.shade700 : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final url = alternative.buyLink.isNotEmpty
                  ? alternative.buyLink
                  : 'https://www.1mg.com/search/all?name=${Uri.encodeComponent(alternative.name)}';

              final success = await _launchUrl(url);

              if (!success && mounted) {
                _showSnackBar('Could not open link. Please try again later.');
              }
            },
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }

  Widget _buildPossibleIllnessCard(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = widget.possibleIllness.isNotEmpty
        ? widget.possibleIllness
        : 'Based on the medications in your prescription, a possible condition is being treated. Please consult your doctor for accurate diagnosis.';

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Possible Illness',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayText,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
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
    );
  }

  Future<bool> _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback to a generic search if the specific URL can't be launched
        final fallbackUrl = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(urlString)}');
        return await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }
}
