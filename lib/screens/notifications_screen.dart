import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: Colors.green.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.green),
              title: const Text('Reminder!'),
              subtitle: const Text(
                'Your fridge is running low on Milk! Make sure to restock it soon before you run out. 🥛',
              ),
              trailing: const Text('2hr', style: TextStyle(fontSize: 12)),
            ),
          ),
          Card(
            color: Colors.green.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.green),
              title: const Text('Promotion deals'),
              subtitle: const Text(
                'Flash Sale! Get 10% OFF on fresh fish at Random Mart! 🐟 Hurry, this deal won\'t last long! 🎉',
              ),
              trailing: const Text('2hr', style: TextStyle(fontSize: 12)),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.kitchen, color: Colors.blue),
              title: const Text('Your Fridge is looking good!'),
              subtitle: const Text(
                'Your fridge has been updated! Looks like you have everything you need for now. Enjoy your fresh ingredients! 🥗',
              ),
              trailing: const Text('1wk', style: TextStyle(fontSize: 12)),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.handshake, color: Colors.blue),
              title: const Text('Welcome to Fridgi-Fi!'),
              subtitle: const Text(
                'Your smart fridge assistant is here to keep your pantry stocked and your groceries fresh. Let’s get started! 🧺',
              ),
              trailing: const Text('1wk', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
