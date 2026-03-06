import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'models.dart';

class ApiService {
  // REMOVE the kIsWeb check for now so the tablet can find your PC
  static const String _baseUrl = "https://172.16.40.215:8083/api/"; 
    
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  Future<bool> saveVisitor(PersonRecord record) async {
  try {
    // This Map must match the property names in your C# VisitorModel class
    final Map<String, dynamic> data = {
      "FullName": record.fullName,
      "Company": record.company,
      "Contact": record.contact,
      "Email": record.email,
      "Purpose": 1, // Sending as an integer to match C# 'int Purpose'
      "WhoVisited": record.department,
      "Reason": record.purpose,
      "Completed": 0, // Sending as an integer to match C# 'int Completed'
      "ContactPerson": record.contactPerson,
      "ImageBaseString": record.imageBase64,
      "Date_SignIn": DateTime.now().toIso8601String(), // Ensures C# can parse it as DateTime
    };

    final response = await _dio.post(
      'Visitor', 
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Returns true if the backend returns 'Ok' (Status 200)
    return response.statusCode == 200 || response.statusCode == 201;
    
  } on DioException catch (e) {
    // This logs the specific reason for the 404 or 400 error in your console
    debugPrint("❌ API Error: ${e.response?.statusCode}");
    debugPrint("❌ Error Details: ${e.response?.data}");
    return false;
  } catch (e) {
    debugPrint("❌ Unexpected Error: $e");
    return false;
  }
}   }
