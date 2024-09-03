import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailSender {
  static Future<void> sendEmail(
      List<TextEditingController> mailListControllers) async {
    final emailAddresses = mailListControllers
        .map((controller) => controller.text.trim())
        .where((email) => email.isNotEmpty)
        .join(',');
    if (emailAddresses.isEmpty) {
      print('No Email addresses provide.');
      return;
    }
    final Uri emailUri = Uri(
        scheme: 'mailto',
        path: emailAddresses,
        queryParameters: {
          'subject': 'Dext Logger',
          'body': 'Your Test Email body here'
        });
    try {
      await launchUrl(emailUri);
    } catch (e) {
      print('could not launch $emailUri: $e');
    }
  }
}
