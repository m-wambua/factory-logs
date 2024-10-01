import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailSender {
  static Future<void> sendEmail(
      List<TextEditingController> mailingListController,
      Map<String, dynamic> pdfData) async {
    List<String> emailAddresses = mailingListController
        .map((controller) => controller.text.trim())
        .where((email) => email.isNotEmpty)
        .toList();

    if (emailAddresses.isEmpty) {
      print('No valid email addresses provided.');
      return;
    }

    var url = Uri.parse(
        'http://0.0.0.0:8000/send-email'); // Use your server's actual URL

    var payload = {
      'to_emails': emailAddresses,
      'subject': 'Production Summary',
      'pdf_data': pdfData,
    };

    try {
      print('Sending payload: ${json.encode(payload)}');

      var response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(Duration(seconds: 60)); // Increased timeout to 60 seconds

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      throw e; // Re-throw the exception so it can be handled by the caller
    }
  }
}


/*
import 'dart:io';



import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class EmailSender {
  static Future<void> sendEmail(List<TextEditingController> mailListControllers,
      String emailBody, List<File> attachments) async {
    final emailAddresses = mailListControllers
        .map((controller) => controller.text.trim())
        .where((email) => email.isNotEmpty)
        .join(',');

    if (emailAddresses.isEmpty) {
      print('No Email addresses provided.');

      return;
    }

    // Encode the email body

    final encodedBody = Uri.encodeComponent(emailBody);

    // Create the mailto URI

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddresses,
      query: 'subject=Dext Logger&body=$encodedBody',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);

        print('Email client opened successfully');
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      print('Could not launch $emailUri: $e');
    }
  }

}

*/
