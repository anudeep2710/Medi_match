import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase-powered real-time donation service for MediMatch
class FirebaseDonationService {
  static final FirebaseDonationService _instance = FirebaseDonationService._internal();
  factory FirebaseDonationService() => _instance;
  FirebaseDonationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user display name
  String? get currentUserName => _auth.currentUser?.displayName ?? 'Anonymous';

  /// Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;

  /// Create a new donation
  Future<String> createDonation({
    required String medicineName,
    required String dosage,
    required String instructions,
    required DateTime expiryDate,
    required int quantity,
    String? unit,
    required String location,
    String? imageUrl,
    String? additionalNotes,
    String? genericName,
    double? genericPrice,
    double? brandPrice,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final donationData = {
      'id': _firestore.collection('donations').doc().id,
      'medicine': {
        'name': medicineName,
        'dosage': dosage,
        'instructions': instructions,
        'genericName': genericName,
        'genericPrice': genericPrice,
        'brandPrice': brandPrice,
      },
      'donorId': currentUser.uid,
      'donorName': currentUserName,
      'donorEmail': currentUserEmail,
      'postedDate': FieldValue.serverTimestamp(),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'imageUrl': imageUrl,
      'additionalNotes': additionalNotes,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('donations').add(donationData);
    return docRef.id;
  }

  /// Get real-time stream of all donations
  Stream<List<MedicationDonation>> getDonationsStream() {
    return _firestore
        .collection('donations')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final donations = snapshot.docs.map((doc) {
        final data = doc.data();
        return MedicationDonation.fromFirestore(data, doc.id);
      }).toList();

      // Sort by posted date (newest first)
      donations.sort((a, b) {
        if (a.postedDate == null && b.postedDate == null) return 0;
        if (a.postedDate == null) return 1;
        if (b.postedDate == null) return -1;
        return b.postedDate!.compareTo(a.postedDate!);
      });

      return donations;
    });
  }

  /// Get donations by current user
  Stream<List<MedicationDonation>> getUserDonationsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('donations')
        .where('donorId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final donations = snapshot.docs.map((doc) {
        final data = doc.data();
        return MedicationDonation.fromFirestore(data, doc.id);
      }).toList();

      // Sort by posted date (newest first)
      donations.sort((a, b) {
        if (a.postedDate == null && b.postedDate == null) return 0;
        if (a.postedDate == null) return 1;
        if (b.postedDate == null) return -1;
        return b.postedDate!.compareTo(a.postedDate!);
      });

      return donations;
    });
  }

  /// Search donations by medicine name
  Future<List<MedicationDonation>> searchDonations(String query) async {
    if (query.isEmpty) return [];

    final querySnapshot = await _firestore
        .collection('donations')
        .where('isAvailable', isEqualTo: true)
        .where('medicine.name', isGreaterThanOrEqualTo: query)
        .where('medicine.name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return MedicationDonation.fromFirestore(data, doc.id);
    }).toList();
  }

  /// Mark donation as unavailable
  Future<void> markDonationUnavailable(String donationId) async {
    await _firestore.collection('donations').doc(donationId).update({
      'isAvailable': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete donation
  Future<void> deleteDonation(String donationId) async {
    await _firestore.collection('donations').doc(donationId).delete();
  }

  /// Update donation
  Future<void> updateDonation(String donationId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('donations').doc(donationId).update(updates);
  }
}

/// Enhanced MedicationDonation model for Firebase
class MedicationDonation {
  final String id;
  final Medicine medicine;
  final String donorId;
  final String donorName;
  final String? donorEmail;
  final DateTime? postedDate;
  final DateTime expiryDate;
  final int quantity;
  final String? unit;
  final String location;
  final String? distance;
  final String? imageUrl;
  final String? additionalNotes;
  final bool isAvailable;

  MedicationDonation({
    required this.id,
    required this.medicine,
    required this.donorId,
    required this.donorName,
    this.donorEmail,
    this.postedDate,
    required this.expiryDate,
    required this.quantity,
    this.unit,
    required this.location,
    this.distance,
    this.imageUrl,
    this.additionalNotes,
    this.isAvailable = true,
  });

  factory MedicationDonation.fromFirestore(Map<String, dynamic> data, String id) {
    final medicineData = data['medicine'] as Map<String, dynamic>? ?? {};

    return MedicationDonation(
      id: id,
      medicine: Medicine(
        name: medicineData['name']?.toString() ?? 'Unknown Medicine',
        dosage: medicineData['dosage']?.toString() ?? '',
        instructions: medicineData['instructions']?.toString() ?? '',
        genericName: medicineData['genericName']?.toString(),
        genericPrice: medicineData['genericPrice']?.toDouble(),
        brandPrice: medicineData['brandPrice']?.toDouble(),
      ),
      donorId: data['donorId']?.toString() ?? '',
      donorName: data['donorName']?.toString() ?? 'Anonymous',
      donorEmail: data['donorEmail']?.toString(),
      postedDate: data['postedDate'] != null
          ? (data['postedDate'] as Timestamp).toDate()
          : null,
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : DateTime.now(),
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unit: data['unit']?.toString(),
      location: data['location']?.toString() ?? 'Unknown Location',
      distance: data['distance']?.toString(),
      imageUrl: data['imageUrl']?.toString(),
      additionalNotes: data['additionalNotes']?.toString(),
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicine': {
        'name': medicine.name,
        'dosage': medicine.dosage,
        'instructions': medicine.instructions,
        'genericName': medicine.genericName,
        'genericPrice': medicine.genericPrice,
        'brandPrice': medicine.brandPrice,
      },
      'donorId': donorId,
      'donorName': donorName,
      'donorEmail': donorEmail,
      'postedDate': postedDate != null ? Timestamp.fromDate(postedDate!) : null,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'distance': distance,
      'imageUrl': imageUrl,
      'additionalNotes': additionalNotes,
      'isAvailable': isAvailable,
    };
  }
}

/// Medicine model (reusing existing structure)
class Medicine {
  final String name;
  final String dosage;
  final String instructions;
  final String? genericName;
  final double? genericPrice;
  final double? brandPrice;

  Medicine({
    required this.name,
    required this.dosage,
    required this.instructions,
    this.genericName,
    this.genericPrice,
    this.brandPrice,
  });
}
