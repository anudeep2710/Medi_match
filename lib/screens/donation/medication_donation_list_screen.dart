import 'package:flutter/material.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/screens/donation/medication_donation_detail_screen.dart';
import 'package:medimatch/screens/donation/add_donation_screen.dart';
import 'package:uuid/uuid.dart';

class MedicationDonationListScreen extends StatefulWidget {
  const MedicationDonationListScreen({Key? key}) : super(key: key);

  @override
  State<MedicationDonationListScreen> createState() =>
      _MedicationDonationListScreenState();
}

class _MedicationDonationListScreenState
    extends State<MedicationDonationListScreen> {
  final List<MedicationDonation> _donations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    // Simulate loading from a database
    await Future.delayed(const Duration(seconds: 1));
    
    // Create sample donations
    final sampleDonations = [
      MedicationDonation(
        id: const Uuid().v4(),
        medicine: Medicine(
          name: 'Paracetamol',
          dosage: '500mg',
          instructions: 'Take 1-2 tablets every 4-6 hours as needed for pain or fever.',
          genericName: 'Acetaminophen',
          genericPrice: 30,
          brandPrice: 50,
        ),
        donorId: 'user1',
        donorName: 'John Doe',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        quantity: 20,
        unit: 'tablets',
        location: 'Downtown, City',
        distance: '2.5 km away',
        imageUrl: 'https://www.netmeds.com/images/product-v1/600x600/313925/paracetamol_500mg_tablet_10s_0.jpg',
      ),
      MedicationDonation(
        id: const Uuid().v4(),
        medicine: Medicine(
          name: 'Amoxicillin',
          dosage: '250mg',
          instructions: 'Take 1 capsule 3 times daily with food.',
          genericName: 'Amoxicillin',
          genericPrice: 120,
          brandPrice: 180,
        ),
        donorId: 'user2',
        donorName: 'Jane Smith',
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        quantity: 15,
        unit: 'capsules',
        location: 'North Side, City',
        distance: '4.8 km away',
        imageUrl: 'https://5.imimg.com/data5/SELLER/Default/2021/1/KO/QG/XG/3823480/amoxicillin-capsules-ip-500x500.jpg',
        additionalNotes: 'Unopened package. Prescribed but not needed.',
      ),
      MedicationDonation(
        id: const Uuid().v4(),
        medicine: Medicine(
          name: 'Cetirizine',
          dosage: '10mg',
          instructions: 'Take 1 tablet daily for allergies.',
          genericName: 'Cetirizine',
          genericPrice: 40,
          brandPrice: 85,
        ),
        donorId: 'user3',
        donorName: 'Robert Johnson',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        expiryDate: DateTime.now().add(const Duration(days: 730)),
        quantity: 25,
        unit: 'tablets',
        location: 'East End, City',
        distance: '1.2 km away',
        additionalNotes: 'Allergy medication, only used 5 tablets from a pack of 30.',
      ),
    ];
    
    setState(() {
      _donations.addAll(sampleDonations);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
              ? _buildEmptyState()
              : _buildDonationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add donation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDonationScreen(),
            ),
          ).then((newDonation) {
            if (newDonation != null) {
              setState(() {
                _donations.add(newDonation);
              });
            }
          });
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
          const Text(
            'No medication donations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to donate unused medications',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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
                    _donations.add(newDonation);
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

  Widget _buildDonationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _donations.length,
      itemBuilder: (context, index) {
        final donation = _donations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicationDonationDetailScreen(
                    donation: donation,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medication image
                if (donation.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4.0),
                    ),
                    child: Image.network(
                      donation.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
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
                            donation.distance,
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
                              donation.donorName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            donation.donorName,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          Text(
                            'Expires: ${_formatDate(donation.expiryDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

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
                  setState(() {
                    _donations.sort((a, b) {
                      final distanceA = double.parse(
                          a.distance.replaceAll(' km away', ''));
                      final distanceB = double.parse(
                          b.distance.replaceAll(' km away', ''));
                      return distanceA.compareTo(distanceB);
                    });
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Most recent'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by posted date
                  setState(() {
                    _donations.sort((a, b) =>
                        b.postedDate.compareTo(a.postedDate));
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Expiring soon'),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by expiry date
                  setState(() {
                    _donations.sort((a, b) =>
                        a.expiryDate.compareTo(b.expiryDate));
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
