import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  final double remainingBudget;
  final double usedBudget;
  final Function(double, double) onBudgetChanged;

  BudgetScreen({required this.remainingBudget, required this.usedBudget, required this.onBudgetChanged});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late double totalBudget;
  late double usedBudget;

  @override
  void initState() {
    super.initState();
    totalBudget = widget.remainingBudget + widget.usedBudget;
    usedBudget = widget.usedBudget;
  }

  double get remainingBudget => totalBudget - usedBudget;

  double get progress => totalBudget > 0 ? usedBudget / totalBudget : double.nan;

  String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID', name: 'Rp ');
    return formatter.format(value).replaceAll(",00", "");
  }

  void editBudget() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Total Budget'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter new total budget amount',
            ),
            onChanged: (value) {
              setState(() {
                totalBudget = double.tryParse(value) ?? totalBudget;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onBudgetChanged(totalBudget - usedBudget, usedBudget);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void editUsedBudget(double amount) {
    setState(() {
      usedBudget += amount;
      if (usedBudget < 0) usedBudget = 0;
    });
    widget.onBudgetChanged(totalBudget - usedBudget, usedBudget); 
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

    String startDate = DateFormat('d MMMM yyyy').format(startOfMonth);
    String endDate = DateFormat('d MMMM yyyy').format(endOfMonth);
    String currentMonthRange = '$startDate - $endDate';

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('d MMMM y').format(now),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '$currentMonthRange Budget',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              formatCurrency(totalBudget),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150.0,
                    height: 150.0,
                    child: progress.isNaN
                        ? Container()
                        : CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[400],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                  ),
                  progress.isNaN
                      ? Container()
                      : Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => editUsedBudget(100000),
                      child: Icon(Icons.add, color: Colors.green, size: 15),
                    ),
                    Text(
                      'Budget Used',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      formatCurrency(usedBudget),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => editUsedBudget(-100000),
                      child: Icon(Icons.remove, color: Colors.red, size: 15),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Remaining Budget',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      formatCurrency(remainingBudget),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: editBudget,
                child: Text('Edit Total Budget'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}