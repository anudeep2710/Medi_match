import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medimatch/services/firebase_donation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddDonationScreen extends StatefulWidget {
  final Map<String, dynamic>? prefilledData;

  const AddDonationScreen({
    Key? key,
    this.prefilledData,
  }) : super(key: key);

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _genericPriceController = TextEditingController();
  final _brandPriceController = TextEditingController();

  final FirebaseDonationService _donationService = FirebaseDonationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 180));
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default location
    _locationController.text = 'My Location, City';

    // Handle prefilled data from expiry verification
    if (widget.prefilledData != null) {
      _populatePrefilledData();
    }
  }

  void _populatePrefilledData() {
    final data = widget.prefilledData!;

    // Populate medicine name
    if (data['medicine_name'] != null) {
      _medicationNameController.text = data['medicine_name'];
    }

    // Populate expiry date
    if (data['expiry_date'] != null) {
      try {
        final parts = data['expiry_date'].toString().split('/');
        if (parts.length == 3) {
          _expiryDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        print('Error parsing expiry date: $e');
      }
    }

    // Populate manufacturer in notes
    if (data['manufacturer'] != null) {
      String notes = 'Manufacturer: ${data['manufacturer']}';
      if (data['batch_number'] != null) {
        notes += '\nBatch: ${data['batch_number']}';
      }
      if (data['manufacturing_date'] != null) {
        notes += '\nMfg Date: ${data['manufacturing_date']}';
      }
      _notesController.text = notes;
    }
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to create a donation'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Parse prices
        double? genericPrice;
        double? brandPrice;

        if (_genericPriceController.text.isNotEmpty) {
          genericPrice = double.tryParse(_genericPriceController.text);
        }

        if (_brandPriceController.text.isNotEmpty) {
          brandPrice = double.tryParse(_brandPriceController.text);
        }

        // Create donation in Firebase
        await _donationService.createDonation(
          medicineName: _medicationNameController.text.trim(),
          dosage: _dosageController.text.trim(),
          instructions: _instructionsController.text.trim(),
          expiryDate: _expiryDate,
          quantity: int.parse(_quantityController.text),
          unit: _unitController.text.isNotEmpty ? _unitController.text.trim() : null,
          location: _locationController.text.trim(),
          imageUrl: null, // Images disabled to avoid loading errors
          additionalNotes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
          genericName: _genericNameController.text.isNotEmpty ? _genericNameController.text.trim() : null,
          genericPrice: genericPrice,
          brandPrice: brandPrice,
        );

        setState(() {
          _isLoading = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Donation created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Return to previous screen
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error creating donation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate Medication'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medication image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8.0),
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imageFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Medication Photo',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Medication details
                    TextFormField(
                      controller: _medicationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Medication Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the medication name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosage *',
                        hintText: 'e.g., 500mg, 10ml',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the dosage';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions',
                        hintText: 'e.g., Take 1 tablet twice daily',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    // Quantity and unit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter a number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              hintText: 'e.g., tablets, capsules',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Expiry date
                    GestureDetector(
                      onTap: () => _selectExpiryDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date *',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an expiry date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Location *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a pickup location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Generic Name
                    TextFormField(
                      controller: _genericNameController,
                      decoration: const InputDecoration(
                        labelText: 'Generic Name (Optional)',
                        hintText: 'e.g., Acetaminophen',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Price Information
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _genericPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Generic Price (₹)',
                              hintText: '0.00',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _brandPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Brand Price (₹)',
                              hintText: '0.00',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Additional notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        hintText: 'Any other information about the medication',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitDonation,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Donate Medication'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Disclaimer
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.amber.shade800,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Important',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Only donate medications that are sealed, unexpired, and in their original packaging. Never donate controlled substances or medications that require refrigeration.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
