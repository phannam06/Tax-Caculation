import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tax_calculation/resources/firestore_method.dart';
import 'package:tax_calculation/screens/st2.dart';
import 'package:tax_calculation/screens/statistics_screen.dart';
import 'package:tax_calculation/widgets/text_file_input.dart';

class StatisticsTableManagerScreen extends StatefulWidget {
  const StatisticsTableManagerScreen({super.key});

  @override
  State<StatisticsTableManagerScreen> createState() =>
      _StatisticsTableManagerScreenState();
}

class _StatisticsTableManagerScreenState
    extends State<StatisticsTableManagerScreen> {
  String? roomId;

  @override
  void initState() {
    super.initState();
    getRoomId();
    getEmail();
  }

  void getRoomId() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users') // Sửa thành collection phù hợp
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      roomId = snapshot['roomId'];
    });
  }

  Future<String> getEmail() async {
    try {
      // Lấy UID của người dùng hiện tại
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Truy cập tài liệu Firestore của người dùng và lấy trường 'email'
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Trả về email nếu tồn tại
      return userDoc['email'];
    } catch (e) {
      print("Lỗi khi lấy email: $e");
      return ""; // Trả về null nếu có lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Statistics")),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.calculator),
            onPressed: () async {
              String? email =
                  await getEmail(); // Chờ hàm getEmail() trả về email
              showDialog(
                context: context,
                builder: (context) => _buildStatisticsDialogV2(email, false),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('roomId', isEqualTo: roomId) // Sửa biến roomId
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No users available"));
                }

                // Hiển thị danh sách người dùng
                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () {
                        showStatisticsDialog(context, user['email']);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween, // Căn giữa
                          children: [
                            Expanded(
                              child: Text(
                                user['email'] ?? 'Unnamed',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            // IconButton(
                            //   icon: const Icon(Icons.delete,
                            //       color: Colors.red), // Biểu tượng xóa
                            //   onPressed: () async {
                            //     // Xác nhận trước khi xóa
                            //     bool? confirm = await showDialog<bool>(
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return AlertDialog(
                            //           title: const Text('Confirm Delete'),
                            //           content: const Text(
                            //               'Are you sure you want to delete this user?'),
                            //           actions: [
                            //             TextButton(
                            //               onPressed: () =>
                            //                   Navigator.of(context).pop(false),
                            //               child: const Text('Cancel'),
                            //             ),
                            //             TextButton(
                            //               onPressed: () =>
                            //                   Navigator.of(context).pop(true),
                            //               child: const Text('Delete'),
                            //             ),
                            //           ],
                            //         );
                            //       },
                            //     );

                            //     if (confirm == true) {
                            //       // Thực hiện xóa user
                            //       await FirebaseFirestore.instance
                            //           .collection('users')
                            //           .doc(user.id)
                            //           .delete();
                            //     }
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showStatisticsDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => _buildStatisticsDialog(email, true),
    );
  }

  Widget _buildStatisticsDialog(String email, bool read) {
    TextEditingController txtIncome = TextEditingController();
    TextEditingController txtOther = TextEditingController();
    TextEditingController txtDependent = TextEditingController();
    TextEditingController txtResult = TextEditingController();
    TextEditingController txtResult2 = TextEditingController();

    getResult(email, txtIncome, txtOther, txtDependent, txtResult, txtResult2);

    return AlertDialog(
      title: Text("Personal Tax Statistics"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow("Income:", txtIncome, read),
            _buildRow("Other Income:", txtOther, read),
            _buildRow("Number of Dependents:", txtDependent, read),
            _buildRow("Monthly Tax:", txtResult, read),
            _buildRow("Annual Tax:", txtResult2, read),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => StatisticsScreen2(email: email)));
          },
          child: Text("Table"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Close"),
        ),
      ],
    );
  }

  Widget _buildStatisticsDialogV2(String email, bool read) {
    TextEditingController txtIncome = TextEditingController();
    TextEditingController txtOther = TextEditingController();
    TextEditingController txtDependent = TextEditingController();
    TextEditingController txtResult = TextEditingController();
    TextEditingController txtResult2 = TextEditingController();

    getResult(email, txtIncome, txtOther, txtDependent, txtResult, txtResult2);

    return AlertDialog(
      title: Text("Personal Tax Statistics"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow("Income:", txtIncome, read),
            _buildRow("Other Income:", txtOther, read),
            _buildRow("Number of Dependents:", txtDependent, read),
            _buildRow("Monthly Tax:", txtResult, read),
            _buildRow("Annual Tax:", txtResult2, read),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() async {
                  FirestoreMethods firestoreMethods = FirestoreMethods();
                  double taxResult = await firestoreMethods.calculateTaxV2(
                      int.parse(txtIncome.text),
                      int.parse(txtOther.text),
                      int.parse(txtDependent.text));
                  txtResult.text = taxResult.toStringAsFixed(2);
                  txtResult2.text = (taxResult * 12).toStringAsFixed(2);
                });
              },
              child: Text("Update"),
            ),
            SizedBox(
              width: 5,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        )
      ],
    );
  }

  void getResult(
      String email,
      TextEditingController txtIncome,
      TextEditingController txtOther,
      TextEditingController txtDependent,
      TextEditingController txtResult,
      TextEditingController txtResult2) async {
    FirestoreMethods firestoreMethods = FirestoreMethods();

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

  Widget _buildRow(
      String title, TextEditingController controller, bool readOnly) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
        ],
      ),
    );
  }
}
