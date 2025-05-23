import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medimatch/services/gemini_vision_service.dart';
import 'package:medimatch/screens/donation/add_donation_screen.dart';
import 'package:medimatch/utils/responsive_helper.dart';

class ExpiryVerificationScreen extends StatefulWidget {
  const ExpiryVerificationScreen({super.key});

  @override
  State<ExpiryVerificationScreen> createState() => _ExpiryVerificationScreenState();
}

class _ExpiryVerificationScreenState extends State<ExpiryVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiVisionService _geminiService = GeminiVisionService();

  File? _selectedImage;
  MedicineVerificationResult? _verificationResult;
  bool _isAnalyzing = false;
  bool _showResults = false;

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final responsiveSpacing = ResponsiveHelper.getResponsiveSpacing(context, 30);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Verify Medicine Expiry',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: ResponsiveHelper.getResponsiveAppBarHeight(context),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: ResponsiveHelper.getResponsiveWidth(context, maxWidth: 800),
            child: Padding(
              padding: responsivePadding,
              child: isTabletOrDesktop && ResponsiveHelper.isLandscape(context)
                ? _buildLandscapeLayout(responsiveSpacing)
                : _buildPortraitLayout(responsiveSpacing),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(double spacing) {
    return Column(
      children: [
        // Header Section
        _buildHeaderSection(),
        SizedBox(height: spacing),

        // Camera/Image Section
        Expanded(
          child: _showResults
            ? _buildResultsSection()
            : _buildCameraSection(),
        ),

        // Bottom Actions
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildLandscapeLayout(double spacing) {
    return Row(
      children: [
        // Left side - Header and Actions
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeaderSection(),
              const Spacer(),
              _buildBottomActions(),
            ],
          ),
        ),

        SizedBox(width: spacing),

        // Right side - Camera/Results
        Expanded(
          flex: 3,
          child: _showResults
            ? _buildResultsSection()
            : _buildCameraSection(),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final responsiveBorderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);
    final responsiveElevation = ResponsiveHelper.getResponsiveElevation(context);
    final responsiveIconSize = ResponsiveHelper.getResponsiveIconSize(context, 50);
    final responsiveSpacing = ResponsiveHelper.getResponsiveSpacing(context, 15);

    return Container(
      padding: responsivePadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsiveBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: responsiveElevation * 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user,
            size: responsiveIconSize,
            color: Colors.teal,
          ),
          SizedBox(height: responsiveSpacing),
          Text(
            'Medicine Safety Verification',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsiveSpacing * 0.7),
          Text(
            'Take a photo of your medicine package to verify expiry date before donation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSection() {
    if (_isAnalyzing) {
      return _buildAnalyzingSection();
    }

    final responsiveBorderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);
    final responsiveSpacing = ResponsiveHelper.getResponsiveSpacing(context, 20);
    final responsiveIconSize = ResponsiveHelper.getResponsiveIconSize(context, 80);
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final isTabletOrDesktop = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);

    return Column(
      children: [
        // Image Preview or Placeholder
        Expanded(
          child: Container(
            width: double.infinity,
            constraints: isTabletOrDesktop
              ? BoxConstraints(maxHeight: ResponsiveHelper.getResponsiveImageHeight(context))
              : null,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(responsiveBorderRadius),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(responsiveBorderRadius - 2),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: responsiveIconSize,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: responsiveSpacing),
                      Text(
                        'No image selected',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: responsiveSpacing * 0.5),
                      Text(
                        'Take a photo or select from gallery',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: responsiveSpacing),

        // Instructions
        Container(
          padding: responsivePadding,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(responsiveBorderRadius * 0.7),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                  ),
                  SizedBox(width: responsiveSpacing * 0.5),
                  Text(
                    'Tips for best results:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsiveSpacing * 0.5),
              _buildTip('📸', 'Ensure good lighting'),
              _buildTip('🔍', 'Focus on expiry date area'),
              _buildTip('📱', 'Hold phone steady'),
              _buildTip('📅', 'Make sure dates are clearly visible'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Selected Image
        if (_selectedImage != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),

        const SizedBox(height: 40),

        // Loading Animation
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          strokeWidth: 3,
        ),

        const SizedBox(height: 20),

        const Text(
          'Analyzing medicine image...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'AI is extracting expiry date and medicine details',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 30),

        // Progress Steps
        _buildProgressSteps(),
      ],
    );
  }

  Widget _buildProgressSteps() {
    return Column(
      children: [
        _buildProgressStep('📸', 'Image captured', true),
        _buildProgressStep('🤖', 'AI analyzing...', true),
        _buildProgressStep('📅', 'Extracting dates', false),
        _buildProgressStep('✅', 'Verification complete', false),
      ],
    );
  }

  Widget _buildProgressStep(String emoji, String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 20,
              color: isActive ? Colors.teal : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.black87 : Colors.grey.shade500,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_verificationResult == null) return const SizedBox();

    final result = _verificationResult!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor(result),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(result),
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  result.isSuccess ? 'Verification Complete' : 'Verification Failed',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  result.statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Results Details
          if (result.isSuccess) _buildResultDetails(result),

          const SizedBox(height: 20),

          // Selected Image
          if (_selectedImage != null)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultDetails(MedicineVerificationResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted Information:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          if (result.medicineName != null)
            _buildDetailRow('💊', 'Medicine', result.medicineName!),

          if (result.expiryDate != null)
            _buildDetailRow('📅', 'Expiry Date', result.expiryDate!),

          if (result.manufacturingDate != null)
            _buildDetailRow('🏭', 'Manufacturing Date', result.manufacturingDate!),

          if (result.batchNumber != null)
            _buildDetailRow('🏷️', 'Batch Number', result.batchNumber!),

          if (result.manufacturer != null)
            _buildDetailRow('🏢', 'Manufacturer', result.manufacturer!),

          _buildDetailRow('📊', 'Confidence', '${(result.confidence * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final responsiveSpacing = ResponsiveHelper.getResponsiveSpacing(context, 20);
    final responsiveButtonHeight = ResponsiveHelper.getResponsiveButtonHeight(context);
    final responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);
    final isTabletOrDesktop = ResponsiveHelper.isTablet(context) || ResponsiveHelper.isDesktop(context);

    if (_isAnalyzing) {
      return SizedBox(height: responsiveButtonHeight + responsiveSpacing);
    }

    if (_showResults) {
      return Column(
        children: [
          SizedBox(height: responsiveSpacing),
          isTabletOrDesktop
            ? _buildTabletResultActions(responsiveButtonHeight, responsiveFontSize, responsiveSpacing)
            : _buildMobileResultActions(responsiveButtonHeight, responsiveFontSize, responsiveSpacing),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(height: responsiveSpacing),
        isTabletOrDesktop
          ? _buildTabletCameraActions(responsiveButtonHeight, responsiveFontSize, responsiveSpacing)
          : _buildMobileCameraActions(responsiveButtonHeight, responsiveFontSize, responsiveSpacing),
      ],
    );
  }

  Widget _buildMobileResultActions(double buttonHeight, double fontSize, double spacing) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _retakePhoto,
            icon: const Icon(Icons.refresh),
            label: Text('Retake Photo', style: TextStyle(fontSize: fontSize)),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, buttonHeight),
              side: const BorderSide(color: Colors.teal),
              foregroundColor: Colors.teal,
            ),
          ),
        ),
        SizedBox(width: spacing * 0.75),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _verificationResult?.isSafeToDonate == true
              ? _proceedToDonation
              : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text('Continue', style: TextStyle(fontSize: fontSize)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: Size(0, buttonHeight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletResultActions(double buttonHeight, double fontSize, double spacing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: OutlinedButton.icon(
            onPressed: _retakePhoto,
            icon: const Icon(Icons.refresh),
            label: Text('Retake Photo', style: TextStyle(fontSize: fontSize)),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, buttonHeight),
              side: const BorderSide(color: Colors.teal),
              foregroundColor: Colors.teal,
            ),
          ),
        ),
        SizedBox(width: spacing),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: _verificationResult?.isSafeToDonate == true
              ? _proceedToDonation
              : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text('Continue', style: TextStyle(fontSize: fontSize)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: Size(0, buttonHeight),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCameraActions(double buttonHeight, double fontSize, double spacing) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text('Take Photo', style: TextStyle(fontSize: fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, buttonHeight),
                ),
              ),
            ),
            SizedBox(width: spacing * 0.75),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text('Gallery', style: TextStyle(fontSize: fontSize)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, buttonHeight),
                  side: const BorderSide(color: Colors.teal),
                  foregroundColor: Colors.teal,
                ),
              ),
            ),
          ],
        ),

        if (_selectedImage != null) ...[
          SizedBox(height: spacing * 0.75),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _analyzeImage,
              icon: const Icon(Icons.analytics),
              label: Text('Analyze Image', style: TextStyle(fontSize: fontSize)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(0, buttonHeight),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabletCameraActions(double buttonHeight, double fontSize, double spacing) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text('Take Photo', style: TextStyle(fontSize: fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: Size(0, buttonHeight),
                ),
              ),
            ),
            SizedBox(width: spacing),
            SizedBox(
              width: 180,
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text('Gallery', style: TextStyle(fontSize: fontSize)),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, buttonHeight),
                  side: const BorderSide(color: Colors.teal),
                  foregroundColor: Colors.teal,
                ),
              ),
            ),
          ],
        ),

        if (_selectedImage != null) ...[
          SizedBox(height: spacing),
          SizedBox(
            width: 300,
            child: ElevatedButton.icon(
              onPressed: _analyzeImage,
              icon: const Icon(Icons.analytics),
              label: Text('Analyze Image', style: TextStyle(fontSize: fontSize)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(0, buttonHeight),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(MedicineVerificationResult result) {
    if (!result.isSuccess || result.isExpired) return Colors.red;
    if (result.confidence < 0.5) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(MedicineVerificationResult result) {
    if (!result.isSuccess) return Icons.error;
    if (result.isExpired) return Icons.dangerous;
    if (result.confidence < 0.5) return Icons.warning;
    return Icons.check_circle;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _showResults = false;
          _verificationResult = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _geminiService.analyzeMedicineImage(_selectedImage!);

      setState(() {
        _verificationResult = result;
        _isAnalyzing = false;
        _showResults = true;
      });

      if (!result.isSuccess) {
        _showErrorSnackBar(result.error ?? 'Analysis failed');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorSnackBar('Analysis failed: $e');
    }
  }

  void _retakePhoto() {
    setState(() {
      _selectedImage = null;
      _verificationResult = null;
      _showResults = false;
    });
  }

  void _proceedToDonation() {
    if (_verificationResult?.isSafeToDonate == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddDonationScreen(
            prefilledData: {
              'medicine_name': _verificationResult!.medicineName,
              'expiry_date': _verificationResult!.expiryDate,
              'manufacturing_date': _verificationResult!.manufacturingDate,
              'batch_number': _verificationResult!.batchNumber,
              'manufacturer': _verificationResult!.manufacturer,
            },
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
