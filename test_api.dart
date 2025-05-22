import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testMedicalAssistantAPI();
}

Future<void> testMedicalAssistantAPI() async {
  const String apiUrl = 'https://us-central1-said-eb2f5.cloudfunctions.net/gemini_medical_assistant';

  print('🧪 Testing Medical Assistant API...');
  print('📡 API URL: $apiUrl');

  try {
    // Test 1: Basic API connectivity with dummy image
    print('\n📋 Test 1: Basic API Connectivity');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image_base64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==', // 1x1 transparent PNG
        'prompt': 'Hello, can you help me with medication information?',
      }),
    ).timeout(Duration(seconds: 30));

    print('✅ Status Code: ${response.statusCode}');
    print('📄 Response Headers: ${response.headers}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ API Response: ${data.toString()}');

      if (data.containsKey('response')) {
        print('✅ Response field found: ${data['response']}');
      } else {
        print('⚠️  Response field not found in API response');
        print('📋 Available fields: ${data.keys.toList()}');
      }
    } else {
      print('❌ API Error: ${response.statusCode}');
      print('📄 Error Body: ${response.body}');
    }

    // Test 2: Health Tips Request
    print('\n📋 Test 2: Health Tips Request');
    final healthTipsResponse = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image_base64': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==', // 1x1 transparent PNG
        'prompt': '''
Based on the following medications: Paracetamol, Ibuprofen

Please provide personalized health tips and guidance including:
1. General health advice for someone taking these medications
2. Important dietary considerations and restrictions
3. Lifestyle recommendations
4. Potential side effects to watch for
5. When to consult a doctor
6. Tips for medication adherence

Please format the response in a clear, easy-to-read manner with bullet points and sections.
Keep the advice general and remind the user to always consult their healthcare provider for personalized medical advice.
''',
      }),
    ).timeout(Duration(seconds: 30));

    print('✅ Health Tips Status Code: ${healthTipsResponse.statusCode}');

    if (healthTipsResponse.statusCode == 200) {
      final healthData = jsonDecode(healthTipsResponse.body);
      print('✅ Health Tips Response received');

      if (healthData.containsKey('response')) {
        final healthTips = healthData['response'];
        print('📋 Health Tips Preview: ${healthTips.toString().substring(0, 200)}...');
      } else {
        print('⚠️  Response field not found in health tips response');
      }
    } else {
      print('❌ Health Tips API Error: ${healthTipsResponse.statusCode}');
      print('📄 Error Body: ${healthTipsResponse.body}');
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

  print('\n🏁 API Test Complete');
}
