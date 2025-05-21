import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:medimatch/models/medicine.dart';
import 'package:medimatch/models/prescription.dart';
import 'package:medimatch/providers/prescription_provider.dart';
import 'package:medimatch/services/handwriting_recognition_service.dart';
import 'package:uuid/uuid.dart';

class ScanHandwrittenPrescriptionScreen extends StatefulWidget {
  const ScanHandwrittenPrescriptionScreen({super.key});

  @override
  State<ScanHandwrittenPrescriptionScreen> createState() =>
      _ScanHandwrittenPrescriptionScreenState();
}

class _ScanHandwrittenPrescriptionScreenState
    extends State<ScanHandwrittenPrescriptionScreen> {
  final ImagePicker _picker = ImagePicker();
  final HandwritingRecognitionService _recognitionService =
      HandwritingRecognitionService();

  File? _imageFile;
  bool _isProcessing = false;
  List<String> _recognizedMedicines = [];
  String _patientName = '';

  @override
  void initState() {
    super.initState();
    // Load the handwriting recognition model
    _recognitionService.loadModel();
  }

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 100,
    );

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
        _recognizedMedicines = [];
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 100,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _recognizedMedicines = [];
      });
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final recognizedMedicines = await _recognitionService
          .recognizeHandwriting(_imageFile!);

      if (mounted) {
        setState(() {
          _recognizedMedicines = recognizedMedicines;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePrescription() async {
    if (_recognizedMedicines.isEmpty || _patientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter patient name and process the image first',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prescriptionProvider = Provider.of<PrescriptionProvider>(
      context,
      listen: false,
    );

    // Create medicine objects
    List<Medicine> medicines =
        _recognizedMedicines.map((medicineName) {
          return Medicine(
            name: medicineName,
            dosage: '', // These would need to be filled in by the user or AI
            instructions: '',
            genericName: '',
            genericPrice: null,
            brandPrice: null,
          );
        }).toList();

    // Create prescription
    final prescription = Prescription(
      id: const Uuid().v4(),
      patientName: _patientName,
      date: DateTime.now(),
      medicines: medicines,
      rawOcrText: _recognizedMedicines.join(', '),
    );

    // Save prescription
    await prescriptionProvider.savePrescription(prescription);

    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Handwritten Prescription')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient name input
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _patientName = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Image preview
              if (_imageFile != null)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFile!, fit: BoxFit.contain),
                  ),
                )
              else
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('No image selected')),
                ),
              const SizedBox(height: 16),

              // Image capture buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Picture'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Process button
              ElevatedButton.icon(
                onPressed:
                    _imageFile != null && !_isProcessing ? _processImage : null,
                icon: const Icon(Icons.document_scanner),
                label: Text(_isProcessing ? 'Processing...' : 'Process Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Recognized medicines
              if (_recognizedMedicines.isNotEmpty) ...[
                const Text(
                  'Recognized Medicines:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        _recognizedMedicines.map((medicine) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.medication, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  medicine,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton.icon(
                  onPressed: _patientName.isNotEmpty ? _savePrescription : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Prescription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
