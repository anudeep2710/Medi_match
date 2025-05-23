import 'package:flutter/material.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/screens/chat/chat_screen.dart';

class MedicationDonationDetailScreen extends StatelessWidget {
  final MedicationDonation donation;

  const MedicationDonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication image
            if (donation.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  donation.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.medication,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.medication,
                  size: 64,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(height: 16),

            // Medication name and details
            Text(
              donation.medicine.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Donor information
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    donation.donorName.isNotEmpty
                      ? donation.donorName[0].toUpperCase()
                      : 'U',
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Donated by ${donation.donorName}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Posted on ${_formatDate(donation.postedDate)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Medication details
            _buildInfoRow(
              context,
              'Quantity',
              donation.quantity.toString() +
                  (donation.unit != null ? ' ${donation.unit}' : ''),
            ),

            _buildInfoRow(
              context,
              'Expiry Date',
              _formatDate(donation.expiryDate),
            ),

            if (donation.medicine.dosage.isNotEmpty)
              _buildInfoRow(context, 'Dosage', donation.medicine.dosage),

            if (donation.medicine.instructions.isNotEmpty)
              _buildInfoRow(
                context,
                'Instructions',
                donation.medicine.instructions,
              ),

            if (donation.additionalNotes != null)
              _buildInfoRow(
                context,
                'Additional Notes',
                donation.additionalNotes!,
              ),

            const SizedBox(height: 24),

            // Location information
            Text(
              'Location',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(donation.location),
                subtitle: Text(donation.distance),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _contactDonor(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('Contact Donor'),
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
                    onPressed: () => _requestMedication(context),
                    icon: const Icon(Icons.medication),
                    label: const Text('Request Medication'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _contactDonor(BuildContext context) {
    // Create a chat conversation with the donor
    final conversationID = 'donation_${donation.id}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              conversationID: conversationID,
              targetUserID: donation.donorId,
              targetUserName: donation.donorName,
              isGroupChat: false,
            ),
      ),
    );
  }

  void _requestMedication(BuildContext context) {
    // Show a dialog to confirm the request
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Request Medication'),
            content: const Text(
              'Would you like to request this medication? '
              'The donor will be notified of your interest.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Create a chat conversation with the donor
                  final conversationID = 'donation_${donation.id}';

                  // Navigate to the chat screen with a pre-filled message
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            conversationID: conversationID,
                            targetUserID: donation.donorId,
                            targetUserName: donation.donorName,
                            isGroupChat: false,
                          ),
                    ),
                  );

                  // Show a confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Request sent! You can now chat with the donor.',
                      ),
                    ),
                  );
                },
                child: const Text('Request'),
              ),
            ],
          ),
    );
  }
}

class MedicationDonation {
  final String id;
  final Medicine medicine;
  final String donorId;
  final String donorName;
  final DateTime postedDate;
  final DateTime expiryDate;
  final int quantity;
  final String? unit;
  final String location;
  final String distance;
  final String? imageUrl;
  final String? additionalNotes;

  MedicationDonation({
    required this.id,
    required this.medicine,
    required this.donorId,
    required this.donorName,
    required this.postedDate,
    required this.expiryDate,
    required this.quantity,
    this.unit,
    required this.location,
    required this.distance,
    this.imageUrl,
    this.additionalNotes,
  });
}
