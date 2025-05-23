import 'package:flutter/material.dart';
import 'package:medimatch/services/firebase_donation_service.dart' as firebase_donation;
import 'package:medimatch/screens/donation/firebase_donation_detail_screen.dart';
import 'package:medimatch/screens/donation/add_donation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medimatch/services/firebase_chat_service.dart' as firebase_chat;
import 'package:medimatch/screens/chat/chat_screen.dart';

class MedicationDonationListScreen extends StatefulWidget {
  const MedicationDonationListScreen({Key? key}) : super(key: key);

  @override
  State<MedicationDonationListScreen> createState() =>
      _MedicationDonationListScreenState();
}

class _MedicationDonationListScreenState
    extends State<MedicationDonationListScreen> {
  final firebase_donation.FirebaseDonationService _donationService = firebase_donation.FirebaseDonationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firebase_chat.FirebaseChatService _chatService = firebase_chat.FirebaseChatService();
  final TextEditingController _searchController = TextEditingController();

  Stream<List<firebase_donation.MedicationDonation>>? _donationsStream;
  String _searchQuery = '';
  bool _showMyDonations = false;

  @override
  void initState() {
    super.initState();
    _initializeDonationsStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDonationsStream() {
    setState(() {
      if (_showMyDonations) {
        _donationsStream = _donationService.getUserDonationsStream();
      } else {
        _donationsStream = _donationService.getDonationsStream();
      }
    });
  }

  void _toggleDonationView() {
    setState(() {
      _showMyDonations = !_showMyDonations;
      _initializeDonationsStream();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Sample donation creation removed - only real-time donations from users

  Future<void> _quickChat(firebase_donation.MedicationDonation donation) async {
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

    if (currentUser.uid == donation.donorId) {
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
        donation.donorId,
        donation.donorName,
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
              targetUserID: donation.donorId,
              targetUserName: donation.donorName,
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

  // Old sample data removed - now using Firebase real-time data

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showMyDonations ? 'My Donations' : 'Medicine Donations'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showMyDonations ? Icons.public : Icons.person),
            onPressed: _toggleDonationView,
            tooltip: _showMyDonations ? 'View All Donations' : 'View My Donations',
          ),
          // Sample donations button removed - only real-time donations
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Donations'),
                  selected: !_showMyDonations,
                  onSelected: (selected) {
                    if (selected && _showMyDonations) {
                      _toggleDonationView();
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('My Donations'),
                  selected: _showMyDonations,
                  onSelected: (selected) {
                    if (selected && !_showMyDonations) {
                      _toggleDonationView();
                    }
                  },
                ),
              ],
            ),
          ),
          // Donations list
          Expanded(
            child: _donationsStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<firebase_donation.MedicationDonation>>(
                    stream: _donationsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 64, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Text('Error: ${snapshot.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _initializeDonationsStream,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final donations = snapshot.data ?? [];

                      // Filter donations based on search query
                      final filteredDonations = _searchQuery.isEmpty
                          ? donations
                          : donations.where((donation) =>
                              donation.medicine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              donation.donorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              donation.location.toLowerCase().contains(_searchQuery.toLowerCase())
                            ).toList();

                      if (filteredDonations.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildDonationsList(filteredDonations);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add donation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDonationScreen(),
            ),
          );
          // No need to manually add - Firebase real-time updates will handle this
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _showMyDonations ? 'No donations yet' : 'No donations available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showMyDonations
              ? 'Create your first donation to help others'
              : 'Check back later for new donations from the community',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddDonationScreen(),
                ),
              ).then((newDonation) {
                if (newDonation != null) {
                  setState(() {
                    // Firebase real-time updates handle this automatically
                  });
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Donate Medication'),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsList(List<firebase_donation.MedicationDonation> donations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final donation = donations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FirebaseDonationDetailScreen(
                    donation: donation,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medication image
                // Medication image placeholder (no external images)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 40,
                        color: Colors.teal.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        donation.medicine.name.isNotEmpty
                          ? donation.medicine.name
                          : 'Unknown Medicine',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.medicine.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        donation.medicine.dosage,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            donation.distance ?? 'Unknown distance',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Qty: ${donation.quantity}${donation.unit != null ? ' ${donation.unit}' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            child: Text(
                              donation.donorName.isNotEmpty
                                ? donation.donorName[0].toUpperCase()
                                : 'U',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.donorName,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                if (donation.donorEmail != null)
                                  Text(
                                    donation.donorEmail!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.teal.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Quick Chat Button (only for other users' donations)
                          if (_auth.currentUser?.uid != donation.donorId && donation.isAvailable) ...[
                            IconButton(
                              onPressed: () => _quickChat(donation),
                              icon: const Icon(Icons.chat_bubble_outline),
                              iconSize: 18,
                              color: Colors.teal,
                              tooltip: 'Quick Chat',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                          Text(
                            'Expires: ${_formatDate(donation.expiryDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Availability status
                      Row(
                        children: [
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: donation.isAvailable
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              donation.isAvailable ? 'Available' : 'Unavailable',
                              style: TextStyle(
                                color: donation.isAvailable
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Duplicate _formatDate method removed

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Filter Donations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Nearest to me'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by distance
                  // TODO: Implement distance sorting with Firebase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Distance sorting coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Most recent'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by posted date
                  // Firebase already sorts by posted date
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Already sorted by most recent!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Expiring soon'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by expiry date
                  // TODO: Implement expiry date sorting with Firebase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expiry sorting coming soon!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
