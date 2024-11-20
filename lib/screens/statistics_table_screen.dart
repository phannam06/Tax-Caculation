import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tax_calculation/resources/firestore_method.dart';
import 'package:tax_calculation/widgets/text_file_input.dart';

class StatisticsTableScreen extends StatefulWidget {
  const StatisticsTableScreen({super.key});

  @override
  State<StatisticsTableScreen> createState() => _StatisticsTableScreenState();
}

class _StatisticsTableScreenState extends State<StatisticsTableScreen> {
  TextEditingController txtIncome = TextEditingController();
  TextEditingController txtOther = TextEditingController();
  TextEditingController txtDependent = TextEditingController();
  TextEditingController txtResult = TextEditingController();
  TextEditingController txtResult2 = TextEditingController();
  FirestoreMethods firestoreMethods = FirestoreMethods();

  @override
  void initState() {
    super.initState();
    getResult();
  }

  void getResult() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Lấy dữ liệu người dùng từ Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    String email = userDoc.get('email');

    // Lấy thông tin bổ sung từ Firestore
    Map<String, dynamic>? incomeInfo =
        await firestoreMethods.getInformationIncome(email);
    if (incomeInfo != null) {
      // Lấy các giá trị cần thiết từ thông tin thu nhập
      String incomeStr = incomeInfo['income'] ?? "0";
      String otherStr = incomeInfo['other'] ?? "0";
      String dependentStr = incomeInfo['dependent'] ?? "0";

      // Chuyển đổi sang số
      int income = int.parse(incomeStr);
      int other = int.parse(otherStr);
      int dependents = int.parse(dependentStr);

      // Gọi hàm calculateTax với thông tin đã lấy
      double taxResult = await firestoreMethods.calculateTax(email);

      // Cập nhật các TextEditingController với thông tin đã lấy
      setState(() {
        txtIncome.text = income.toString();
        txtOther.text = other.toString();
        txtDependent.text = dependents.toString();
        txtResult.text =
            taxResult.toStringAsFixed(2); // Giới hạn đến 2 số thập phân
        txtResult2.text = (taxResult * 12).toStringAsFixed(2);
      });
    } else {
      // Xử lý trường hợp không có thông tin thu nhập
      setState(() {
        txtResult.text =
            "No income information found"; // Gán thông báo vào TextEditingController
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Personal Tax Statistics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildRow("Income:", txtIncome),
          _buildRow("Other Income:", txtOther),
          _buildRow("Number of Dependents:", txtDependent),
          _buildRow("Monthly Tax :", txtResult),
          _buildRow("Annual Tax :", txtResult2),
          SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() async {
                  double taxResult = await firestoreMethods.calculateTaxV2(
                      int.parse(txtIncome.text),
                      int.parse(txtOther.text),
                      int.parse(txtDependent.text));
                  txtResult.text = taxResult.toStringAsFixed(2);
                  txtResult2.text = (taxResult * 12).toStringAsFixed(2);
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  backgroundColor: Colors.blue),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRow(String title, TextEditingController controller,
      {bool readOnly = false}) {
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
          SizedBox(width: 16), // Khoảng cách giữa tiêu đề và kết quả
          Expanded(
            child: TextFieldInput(
              textEditingController: controller,
              hintText: '',
              textInputType: TextInputType.number,
              readOnly: readOnly, // Đặt readOnly nếu cần
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
