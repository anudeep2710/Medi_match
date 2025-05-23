import 'package:flutter/material.dart';
import 'package:medimatch/services/firebase_donation_service.dart' as firebase_donation;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medimatch/services/firebase_chat_service.dart' as firebase_chat;
import 'package:medimatch/screens/chat/chat_screen.dart';

class FirebaseDonationDetailScreen extends StatefulWidget {
  final firebase_donation.MedicationDonation donation;

  const FirebaseDonationDetailScreen({
    super.key,
    required this.donation,
  });

  @override
  State<FirebaseDonationDetailScreen> createState() => _FirebaseDonationDetailScreenState();
}

class _FirebaseDonationDetailScreenState extends State<FirebaseDonationDetailScreen> {
  final firebase_donation.FirebaseDonationService _donationService = firebase_donation.FirebaseDonationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firebase_chat.FirebaseChatService _chatService = firebase_chat.FirebaseChatService();

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _contactDonor() async {
    if (widget.donation.donorEmail != null) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: widget.donation.donorEmail!,
        query: 'subject=Interest in ${widget.donation.medicine.name} donation&body=Hi ${widget.donation.donorName},\n\nI am interested in your ${widget.donation.medicine.name} donation. Could we arrange a pickup?\n\nThank you!',
      );

      try {
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email: ${widget.donation.donorEmail}'),
                action: SnackBarAction(
                  label: 'Copy',
                  onPressed: () {
                    // Copy to clipboard functionality can be added here
                  },
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contact: ${widget.donation.donorEmail}'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      }
    }
  }

  Future<void> _startChat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to start a chat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentUser.uid == widget.donation.donorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot chat with yourself'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Create or get existing conversation
      final conversationId = await _chatService.createConversation(
        widget.donation.donorId,
        widget.donation.donorName,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to chat screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationID: conversationId,
              targetUserID: widget.donation.donorId,
              targetUserName: widget.donation.donorName,
              isGroupChat: false,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error starting chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsUnavailable() async {
    try {
      await _donationService.markDonationUnavailable(widget.donation.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Donation marked as unavailable'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _auth.currentUser?.uid == widget.donation.donorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.donation.medicine.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon!')),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 80,
                    color: Colors.teal.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.donation.medicine.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (widget.donation.isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Available',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'No Longer Available',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Donor Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text(
                            widget.donation.donorName.isNotEmpty
                              ? widget.donation.donorName[0].toUpperCase()
                              : 'U',
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Donated by ${widget.donation.donorName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.donation.donorEmail != null)
                                Text(
                                  widget.donation.donorEmail!,
                                  style: TextStyle(
                                    color: Colors.teal.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              if (widget.donation.postedDate != null)
                                Text(
                                  'Posted ${_formatTimeAgo(widget.donation.postedDate!)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!isOwner) ...[
                          // Chat Button
                          ElevatedButton.icon(
                            onPressed: _startChat,
                            icon: const Icon(Icons.chat, size: 16),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Email Button
                          if (widget.donation.donorEmail != null)
                            ElevatedButton.icon(
                              onPressed: _contactDonor,
                              icon: const Icon(Icons.email, size: 16),
                              label: const Text('Email'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Medicine Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Quantity', '${widget.donation.quantity}${widget.donation.unit != null ? ' ${widget.donation.unit}' : ''}'),
                    _buildDetailRow('Dosage', widget.donation.medicine.dosage),
                    _buildDetailRow('Expiry Date', _formatDate(widget.donation.expiryDate)),
                    if (widget.donation.medicine.instructions.isNotEmpty)
                      _buildDetailRow('Instructions', widget.donation.medicine.instructions),
                    if (widget.donation.medicine.genericName != null)
                      _buildDetailRow('Generic Name', widget.donation.medicine.genericName!),
                    if (widget.donation.medicine.genericPrice != null)
                      _buildDetailRow('Generic Price', '₹${widget.donation.medicine.genericPrice}'),
                    if (widget.donation.medicine.brandPrice != null)
                      _buildDetailRow('Brand Price', '₹${widget.donation.medicine.brandPrice}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.teal.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.donation.location,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (widget.donation.additionalNotes != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Notes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.donation.additionalNotes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            if (isOwner && widget.donation.isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _markAsUnavailable,
                  icon: const Icon(Icons.visibility_off),
                  label: const Text('Mark as Unavailable'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
