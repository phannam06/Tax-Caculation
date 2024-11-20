import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tax_calculation/resources/firestore_method.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  int selectedYear = DateTime.now().year;
  List<Map<String, dynamic>> monthData = [];

  double totalPaidTax = 0.0;
  double totalTaxDue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    loadIncomeInformation();
  }

  @override
  void dispose() {
    for (var row in monthData) {
      row['income'].dispose();
      row['dependent'].dispose();
      row['monthlyTax'].dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadIncomeInformation() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      String email = userDoc.get('email');
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('statistics')
          .doc(email); // Use user email to fetch data
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        Map<String, dynamic> yearsData =
            (docSnapshot.data() as Map<String, dynamic>)['years'] ?? {};
        if (yearsData.containsKey(selectedYear.toString())) {
          List<dynamic> months = yearsData[selectedYear.toString()];

          List<Map<String, dynamic>> monthDataFromDb = [];
          for (var item in months) {
            if (item['month'] != null && item['data'] != null) {
              monthDataFromDb.add({
                'month': item['month'] ?? 0, // Default to 0 if month is null
                'income': TextEditingController(
                    text: item['data']['income']?.toString() ?? ''),
                'dependent': TextEditingController(
                    text: item['data']['dependent']?.toString() ?? ''),
                'monthlyTax': TextEditingController(
                    text: item['data']['calculate_tax']?.toString() ?? ''),
              });
            }
          }

          // Calculate total paid tax (month 1 * 12)
          double januaryTax = 0.0;
          if (monthDataFromDb.isNotEmpty &&
              monthDataFromDb[0]['monthlyTax'] != null) {
            januaryTax =
                double.tryParse(monthDataFromDb[0]['monthlyTax']!.text) ?? 0.0;
          }
          totalPaidTax = januaryTax * 12;

          // Calculate total tax due (sum of monthly tax for all months)
          totalTaxDue = monthDataFromDb.fold(0.0, (sum, month) {
            double monthlyTax =
                double.tryParse(month['monthlyTax']!.text) ?? 0.0;
            return sum + monthlyTax;
          });

          setState(() {
            monthData = monthDataFromDb;
          });
        } else {
          print("No data for the selected year.");
          setState(() {
            monthData = [];
            totalPaidTax = 0.0;
            totalTaxDue = 0.0;
          });
        }
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error loading income information: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double difference = totalPaidTax - totalTaxDue;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Statistical Table")),
        // actions: [
        //   IconButton(
        //       onPressed: () async {
        //         FirestoreMethods _firestore = FirestoreMethods();
        //         String email = FirebaseAuth.instance.currentUser!.email!;
        //         await _firestore.exportToExcel(email);
        //       },
        //       icon: Icon(Icons.file_download))
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        children: List.generate(
                          DateTime.now().year - 2020 + 1,
                          (index) => ListTile(
                            title: Text('${2020 + index}'),
                            onTap: () {
                              setState(() {
                                selectedYear = 2020 + index;
                              });
                              Navigator.pop(context); // Đóng modal sau khi chọn
                              loadIncomeInformation();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text(
                selectedYear != null
                    ? 'Year Selected: $selectedYear'
                    : 'Select Year',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Divider(color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                    child: Text('Month',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Income',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Dependent',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Monthly Tax',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Divider(color: Colors.grey),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: monthData.map((row) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(child: Text(row['month'].toString())),
                        Expanded(
                          child: TextFormField(
                            controller: row['income'],
                            decoration: InputDecoration(
                              hintText: 'Income',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: row['dependent'],
                            decoration: InputDecoration(
                              hintText: 'Dependent',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: row['monthlyTax'],
                            decoration: InputDecoration(
                              hintText: 'Monthly Tax',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                // Hiển thị dialog khi bấm vào
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Tax Details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Total Paid Tax: ${totalPaidTax.toStringAsFixed(2)}'),
                          Text(
                              'Total Tax Due: ${totalTaxDue.toStringAsFixed(2)}'),
                          Text('Difference: ${difference.toStringAsFixed(2)}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 8),
                  height: 8,
                  width: MediaQuery.of(context).size.width /
                      5, // Chiều rộng divider ngắn
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
