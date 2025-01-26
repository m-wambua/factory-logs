import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum EmailType {
  productionSummary,
  sparePartsDetails,
  sparePartsStorage,
  // more can be added here
}

class EmailSender {
  static Future<void> sendEmail(
      List<TextEditingController> mailingListController,
      Map<String, dynamic> pdfData,
      EmailType emailType) async {
    if (mailingListController.isEmpty) {
      print('No mailing list controllers provided.');
      return;
    }

    if (pdfData.isEmpty) {
      print('No PDF data provided.');
      return;
    }

    List<String> emailAddresses = mailingListController
        .map((controller) => controller.text.trim())
        .where((email) => email.isNotEmpty)
        .toList();

    if (emailAddresses.isEmpty) {
      print('No valid email addresses provided.');
      return;
    }

    var payload = {
      'to_emails': emailAddresses,
      'subject': _getSubject(emailType),
      'email_type': _getEmailType(emailType),
      'pdf_data': pdfData
    };

    var url = Uri.parse('http://0.0.0.0:8000/send-email');

    try {
      print('Sending payload: ${json.encode(payload)}');
      print('Email Type ${_getEmailType(emailType)}');

      var response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 60));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Email Type');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Email sent successfully: $jsonResponse');
      } else {
        print(
            'Failed to send email: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception(
            'Failed to send email: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        print(
            'Connection timed out. Please check your internet connection and server status.');
      } else {
        print('Error sending email: $e');
      }
      rethrow;
    }
  }

  static String _getSubject(EmailType emailType) {
    switch (emailType) {
      case EmailType.productionSummary:
        return 'Production Summary';

      case EmailType.sparePartsDetails:
        return 'Spare Parts Details';

      // add more cases as needed
      default:
        throw Exception('Unsupported email type: $emailType');
    }
  }

  static String _getEmailType(EmailType emailType) {
    switch (emailType) {
      case EmailType.productionSummary:
        return 'production_summary';

      case EmailType.sparePartsDetails:
        return 'spare_parts_details';

      // add more cases as needed
      default:
        throw Exception('Unsupported email type: $emailType');
    }
  }
}
