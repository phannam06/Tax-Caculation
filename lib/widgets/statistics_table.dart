import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tax_calculation/resources/firestore_method.dart';
import 'package:tax_calculation/screens/st2.dart';
import 'package:tax_calculation/widgets/text_file_input.dart';

class StatisticsDialog extends StatefulWidget {
  final String email;
  const StatisticsDialog({super.key, required this.email});

  @override
  State<StatisticsDialog> createState() => _StatisticsDialogState();
}

class _StatisticsDialogState extends State<StatisticsDialog> {
  TextEditingController txtIncome = TextEditingController();
  TextEditingController txtOther = TextEditingController();
  TextEditingController txtDependent = TextEditingController();
  TextEditingController txtResult = TextEditingController();
  TextEditingController txtResult2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    getResult(widget.email);
  }

  void getResult(String email) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    FirestoreMethods firestoreMethods = FirestoreMethods();

    // Lấy thông tin bổ sung từ Firestore
    Map<String, dynamic>? incomeInfo =
        await firestoreMethods.getInformationIncome(email);
    if (incomeInfo != null) {
      String incomeStr = incomeInfo['income'] ?? "0";
      String otherStr = incomeInfo['other'] ?? "0";
      String dependentStr = incomeInfo['dependent'] ?? "0";

      int income = int.parse(incomeStr);
      int other = int.parse(otherStr);
      int dependents = int.parse(dependentStr);

      double taxResult = await firestoreMethods.calculateTax(email);

      setState(() {
        txtIncome.text = income.toString();
        txtOther.text = other.toString();
        txtDependent.text = dependents.toString();
        txtResult.text = taxResult.toStringAsFixed(2);
        txtResult2.text = (taxResult * 12).toStringAsFixed(2);
      });
    } else {
      setState(() {
        txtResult.text = "No income information found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Personal Tax Statistics",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow("Income:", txtIncome),
            _buildRow("Other Income:", txtOther),
            _buildRow("Number of Dependents:", txtDependent),
            _buildRow("Monthly Tax:", txtResult),
            _buildRow("Annual Tax:", txtResult2),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => StatisticsScreen2(email: widget.email)));
          },
          child: Text("St"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Close"),
        ),
      ],
    );
  }

  Widget _buildRow(String title, TextEditingController controller,
      {bool readOnly = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextFieldInput(
              textEditingController: controller,
              hintText: '',
              textInputType: TextInputType.number,
              readOnly: readOnly,
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}

// Sử dụng hàm này để hiển thị Dialog
void showStatisticsDialog(BuildContext context, String email) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatisticsDialog(email: email);
    },
  );
}
