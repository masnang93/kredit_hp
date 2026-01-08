import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class LoanService {
  // Mock Limit for now (Real limit logic usually complex)
  static Future<Map<String, dynamic>> getCreditLimit() async {
    try {
      final deviceId = ApiService.deviceId;
      final url = '${ApiService.baseUrl}/loans/summary/$deviceId';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching limit: $e');
    }
    // Fallback if error or waiting for migration
    return {
      'totalLimit': 0,
      'availableLimit': 0,
      'currency': 'IDR',
    };
  }

  // Fetch active loans from Backend logic
  static Future<List<Map<String, dynamic>>> getActiveLoans() async {
    try {
      final deviceId = ApiService.deviceId;
      final url = '${ApiService.baseUrl}/loans/device/$deviceId';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => {
                  'id': item['id'],
                  'title': 'Tagihan #${item['id'].substring(0, 8)}',
                  'amount':
                      double.tryParse(item['totalAmount'].toString()) ?? 0,
                  'dueDate': item['dueDate'],
                  'status': item['status'],
                })
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching loans: $e');
    }
    return [];
  }

  static Future<bool> createLoan(
      {required double amount, required String merchantName}) async {
    try {
      final deviceId = ApiService.deviceId;
      final url = '${ApiService.baseUrl}/loans';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'imei': deviceId,
          'loan': {
            'amount': amount,
            'merchantName': merchantName,
            // Backend might calculate interest and due date
          }
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('Create Loan error: $e');
    }
    return false;
  }

  static Future<String?> payLoan(String loanId, int amount) async {
    try {
      final url = '${ApiService.baseUrl}/payments/invoice';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'loanId': loanId,
          'amount': amount,
          'userId': 'USER-123' // Dummy
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final paymentUrl = data['paymentUrl'];
        debugPrint('Open Payment URL: $paymentUrl');

        try {
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('Could not launch $paymentUrl');
          }
        } catch (e) {
          debugPrint('Error launching URL: $e');
        }

        // We will return this URL to UI
        return paymentUrl;
      }
    } catch (e) {
      debugPrint('Payment error: $e');
    }
    return null;
  }
}
