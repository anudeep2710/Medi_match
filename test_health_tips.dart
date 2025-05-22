import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  await testHealthTipsWithImage();
}

Future<void> testHealthTipsWithImage() async {
  const String apiUrl = 'https://us-central1-said-eb2f5.cloudfunctions.net/gemini_medical_assistant';
  const String imagePath = r'C:\Users\anude\Downloads\WhatsApp Image 2025-05-19 at 16.49.07_14e9e8f1.jpg';

  print('🧪 Testing Health Tips with Real Image...');
  print('📡 API URL: $apiUrl');
  print('🖼️ Image Path: $imagePath');

  try {
    // Check if image file exists
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      print('❌ Image file not found at: $imagePath');
      return;
    }

    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    print('✅ Image converted to base64 (${base64Image.length} characters)');

    // Test 1: Analyze prescription first
    print('\n📋 Test 1: Analyzing Prescription');
    final analysisResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image_base64': base64Image,
      }),
    ).timeout(Duration(seconds: 60));

    print('✅ Analysis Status Code: ${analysisResponse.statusCode}');

    if (analysisResponse.statusCode == 200) {
      final analysisData = jsonDecode(analysisResponse.body);
      print('✅ Analysis Response received');

      if (analysisData.containsKey('response')) {
        final analysisResult = analysisData['response'];
        print('📋 Analysis Preview: ${analysisResult.toString().substring(0, 300)}...');

        // Extract medication names from the analysis
        final medicationNames = _extractMedicationNames(analysisResult);
        print('💊 Extracted Medications: $medicationNames');

        // Based on the sample, we know it should be: Cipran-500, Supradyn
        final testMedications = 'Cipran-500, Supradyn';

        // Test 2: Get Health Tips based on extracted medications
        print('\n📋 Test 2: Getting Health Tips');
        final healthTipsResponse = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'image_base64': base64Image,
            'prompt': '''
Based on the following medications: $testMedications

Please provide comprehensive personalized health tips and guidance including:

**1. General Health Advice:**
• Essential health recommendations for someone taking these medications
• Daily health practices and habits
• Overall wellness guidelines

**2. Dietary Considerations and Restrictions:**
• Foods to include in the diet
• Foods and drinks to avoid
• Timing of meals with medications
• Nutritional recommendations
• Food-drug interactions to be aware of

**3. Lifestyle Recommendations:**
• Exercise and physical activity guidelines
• Sleep recommendations
• Stress management techniques
• Daily routine suggestions
• Habits to develop or avoid

**4. Potential Side Effects to Watch For:**
• Common side effects that may occur
• Serious side effects requiring immediate attention
• How to monitor and track side effects
• When side effects are normal vs concerning

**5. When to Consult a Doctor:**
• Specific symptoms that require medical attention
• Emergency warning signs
• Regular follow-up recommendations
• Questions to ask your healthcare provider

**6. Tips for Medication Adherence:**
• Strategies to remember taking medications
• Organization and storage tips
• Dealing with missed doses
• Motivation and compliance strategies

Please format each section clearly with bullet points and provide specific, actionable advice.
Keep the advice evidence-based but general, and remind the user to always consult their healthcare provider for personalized medical advice.
''',
          }),
        ).timeout(Duration(seconds: 60));

        print('✅ Health Tips Status Code: ${healthTipsResponse.statusCode}');

        if (healthTipsResponse.statusCode == 200) {
          final healthData = jsonDecode(healthTipsResponse.body);
          print('✅ Health Tips Response received');

          if (healthData.containsKey('response')) {
            final healthTips = healthData['response'];
            print('\n🎯 COMPLETE HEALTH TIPS RESPONSE:');
            print('=' * 80);
            print(healthTips);
            print('=' * 80);
          } else {
            print('⚠️  Response field not found in health tips response');
          }
        } else {
          print('❌ Health Tips API Error: ${healthTipsResponse.statusCode}');
          print('📄 Error Body: ${healthTipsResponse.body}');
        }
      } else {
        print('⚠️  Response field not found in analysis response');
      }
    } else {
      print('❌ Analysis API Error: ${analysisResponse.statusCode}');
      print('📄 Error Body: ${analysisResponse.body}');
    }

  } catch (e) {
    print('❌ API Test Failed: $e');

    if (e.toString().contains('TimeoutException')) {
      print('⏰ API request timed out - the service might be slow or unavailable');
    } else if (e.toString().contains('SocketException')) {
      print('🌐 Network connection error - check internet connectivity');
    } else {
      print('🔍 Unexpected error occurred');
    }
  }

  print('\n🏁 Health Tips Test Complete');
}

String _extractMedicationNames(String analysisResult) {
  // Simple extraction - look for medication names in the analysis
  final lines = analysisResult.split('\n');
  final medications = <String>[];

  for (final line in lines) {
    // Look for lines that might contain medication names
    if (line.contains('**') && !line.contains('Possible illness') && !line.contains('illness')) {
      final cleaned = line.replaceAll('**', '').trim();
      if (cleaned.isNotEmpty && cleaned.length < 50) {
        medications.add(cleaned);
      }
    }
  }

  return medications.isNotEmpty ? medications.join(', ') : 'Paracetamol, Ibuprofen';
}
