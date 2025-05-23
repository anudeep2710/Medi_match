import 'package:flutter/material.dart';
import 'package:medimatch/services/firebase_donation_service.dart' as firebase_donation;
import 'package:medimatch/screens/donation/firebase_donation_detail_screen.dart';
import 'package:medimatch/screens/donation/expiry_verification_screen.dart';
import 'package:medimatch/utils/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medimatch/services/firebase_chat_service.dart' as firebase_chat;
import 'package:medimatch/screens/chat/chat_screen.dart';

class MedicationDonationListScreen extends StatefulWidget {
  const MedicationDonationListScreen({super.key});

  @override
  State<MedicationDonationListScreen> createState() => _MedicationDonationListScreenState();
}

class _MedicationDonationListScreenState extends State<MedicationDonationListScreen> {
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

  Future<void> _quickChat(firebase_donation.MedicationDonation donation) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a chat'), backgroundColor: Colors.red),
      );
      return;
    }

    if (currentUser.uid == donation.donorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final conversationId = await _chatService.createConversation(donation.donorId, donation.donorName);
      if (mounted) Navigator.pop(context);

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
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error starting chat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showMyDonations ? 'My Donations' : 'Medicine Donations',
          style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20)),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        toolbarHeight: ResponsiveHelper.getResponsiveAppBarHeight(context),
        actions: [
          IconButton(
            icon: Icon(_showMyDonations ? Icons.public : Icons.person),
            onPressed: _toggleDonationView,
            tooltip: _showMyDonations ? 'View All Donations' : 'View My Donations',
            iconSize: ResponsiveHelper.getResponsiveIconSize(context, 24),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: responsivePadding,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                hintStyle: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14)),
                prefixIcon: Icon(Icons.search, size: ResponsiveHelper.getResponsiveIconSize(context, 20)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _onSearchChanged,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpiryVerificationScreen()),
          );
        },
        icon: Icon(Icons.verified_user, size: ResponsiveHelper.getResponsiveIconSize(context, 20)),
        label: Text('Add Donation', style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14))),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    final responsiveSpacing = ResponsiveHelper.getResponsiveSpacing(context, 24);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: ResponsiveHelper.getResponsiveIconSize(context, 64),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: responsiveSpacing),
          Text(
            _showMyDonations ? 'No donations yet' : 'No donations available',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: responsiveSpacing),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpiryVerificationScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Donate Medication'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: Size(0, ResponsiveHelper.getResponsiveButtonHeight(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsList(List<firebase_donation.MedicationDonation> donations) {
    final isTabletOrDesktop = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);

    if (isTabletOrDesktop) {
      final crossAxisCount = ResponsiveHelper.getResponsiveCrossAxisCount(context, mobile: 1, tablet: 2, desktop: 3);
      return Padding(
        padding: responsivePadding,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
            mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 16),
          ),
          itemCount: donations.length,
          itemBuilder: (context, index) => _buildDonationCard(donations[index]),
        ),
      );
    } else {
      return ListView.builder(
        padding: responsivePadding,
        itemCount: donations.length,
        itemBuilder: (context, index) => _buildDonationCard(donations[index]),
      );
    }
  }

  Widget _buildDonationCard(firebase_donation.MedicationDonation donation) {
    final responsiveMargin = ResponsiveHelper.getResponsiveMargin(context);
    final responsiveBorderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);
    final responsiveElevation = ResponsiveHelper.getResponsiveElevation(context);
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final responsiveSpacing = ResponsiveHelper.getResponsiveSpacing(context, 12);
    final isTabletOrDesktop = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);
    
    return Container(
      margin: isTabletOrDesktop ? EdgeInsets.zero : EdgeInsets.only(bottom: responsiveMargin.bottom),
      child: Card(
        elevation: responsiveElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsiveBorderRadius)),
        child: InkWell(
          borderRadius: BorderRadius.circular(responsiveBorderRadius),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FirebaseDonationDetailScreen(donation: donation)),
            );
          },
          child: Padding(
            padding: responsivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.medicine.name,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: responsiveSpacing),
                Text(
                  donation.medicine.dosage,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: responsiveSpacing),
                Row(
                  children: [
                    Icon(Icons.location_on, size: ResponsiveHelper.getResponsiveIconSize(context, 16), color: Colors.grey),
                    SizedBox(width: responsiveSpacing * 0.5),
                    Expanded(
                      child: Text(
                        donation.location,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_auth.currentUser?.uid != donation.donorId && donation.isAvailable) ...[
                      IconButton(
                        onPressed: () => _quickChat(donation),
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                        ),
                        color: Colors.teal,
                        tooltip: 'Chat',
                      ),
                    ],
                  ],
                ),
                SizedBox(height: responsiveSpacing),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Expires: ${_formatDate(donation.expiryDate)}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveSpacing,
                        vertical: responsiveSpacing * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: donation.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(responsiveBorderRadius),
                      ),
                      child: Text(
                        donation.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          color: donation.isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
