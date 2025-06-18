import 'package:flutter/material.dart';

class AppUtils {
  // Prevent instantiation
  AppUtils._();
  
  /// Show a snackbar with message
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  /// Format date to string
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
