import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tax_calculation/resources/firestore_method.dart';
import 'package:tax_calculation/screens/login_screen.dart';

class Notifycation extends StatefulWidget {
  const Notifycation({super.key});

  @override
  State<Notifycation> createState() => _NotifycationState();
}

class _NotifycationState extends State<Notifycation> {
  void _showIncomeInformationDialog(String email) async {
    final TextEditingController incomeController = TextEditingController();
    final TextEditingController dependentController = TextEditingController();
    final TextEditingController otherController = TextEditingController();

    // Tạo một thể hiện của FirestoreMethods
    FirestoreMethods firestoreMethods = FirestoreMethods();

    // Lấy dữ liệu từ Firestore và điền vào TextEditingController
    Map<String, dynamic>? data =
        await firestoreMethods.getInformationIncometest(email);
    if (data != null) {
      incomeController.text = data['income'] ?? '';
      dependentController.text = data['dependent'] ?? '';
      otherController.text = data['other'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Information Income'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: incomeController,
                decoration: const InputDecoration(labelText: 'Income'),
              ),
              TextField(
                controller: dependentController,
                decoration: const InputDecoration(labelText: 'Dependent'),
              ),
              TextField(
                controller: otherController,
                decoration: const InputDecoration(labelText: 'Other'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Thêm hoặc cập nhật thông tin vào Firebase
                String income = incomeController.text.trim();
                String dependent = dependentController.text.trim();
                String other = otherController.text.trim();
                String res = await firestoreMethods.addInformationincome(
                  income,
                  dependent,
                  other,
                  email,
                );

                firestoreMethods.deleteInformationIncomeTest(email);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res)),
                );

                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.of(context)
        //         .push(MaterialPageRoute(builder: (context) => LoginScreen()));
        //   },
        //   icon: Icon(Icons.arrow_back),
        // ),
        title: Center(child: Text("Notifycation")),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('information_income_test')
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
                        _showIncomeInformationDialog(user['email']);
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
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red), // Biểu tượng xóa
                              onPressed: () async {
                                // Xác nhận trước khi xóa
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this user?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  FirestoreMethods firestoreMethods =
                                      FirestoreMethods();
                                  String result = await firestoreMethods
                                      .deleteInformationIncomeTest(
                                          user['email']);

                                  Future.delayed(Duration.zero, () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result)),
                                    );
                                  });
                                }
                              },
                            ),
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
}
