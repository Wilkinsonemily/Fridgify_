import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.privacy_tip, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Welcome to Fridgi-Fi',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your privacy is important to us. This page outlines how we collect, use, and protect your information.\n',
              style: TextStyle(fontSize: 16),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What We Collect:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              '• Personal details (name, email, etc.) when you sign up\n'
              '• Usage data to improve your experience\n'
              '• Any data you provide while using our services\n',
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'How We Use Your Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              '• To personalize and enhance your experience\n'
              '• To improve our services and features\n'
              '• To send important updates and notifications\n',
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Privacy Choices:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              '• You can review, update, or delete your data anytime\n'
              '• Manage your notification preferences in settings\n'
              '• Opt-out of promotions and marketing emails\n',
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Keeping Your Data Safe:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              'We use industry-standard security measures to protect your data from unauthorized access.\n',
            ),
            const SizedBox(height: 12),
            const Text(
              'Got Questions? Contact us at fridgifi@gmail.com for any privacy-related concerns.',
            ),
            const SizedBox(height: 10),
            const Text(
              'By using Fridgi-Fi, you agree to our Privacy Policy.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
