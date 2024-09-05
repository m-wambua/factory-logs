import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailSender {
  static Future<void> sendEmail(List<TextEditingController> mailingListController, String body, String attachmentPath) async {
    // Extract email addresses from controllers
    List<String> emailAddresses = mailingListController.map((controller) => controller.text).toList();

    var url = Uri.parse('http://your-backend-url/send-email');
    
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'to_emails': emailAddresses, // List of email addresses
        'subject': 'Production Summary',
        'body': body,
        'attachment_path': attachmentPath, // Send the attachment path to the backend
      }),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully!');
    } else {
      print('Failed to send email: ${response.body}');
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
