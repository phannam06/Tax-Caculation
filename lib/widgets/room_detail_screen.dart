import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tax_calculation/resources/auth_methods.dart';
import 'package:tax_calculation/resources/firestore_method.dart';
import 'package:tax_calculation/widgets/statistics_table.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const RoomDetailScreen({
    Key? key,
    required this.roomId,
    required this.roomName,
  }) : super(key: key);

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedPosition = 'User';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    String selectedPosition = 'User';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // Sử dụng DropdownButton cho vị trí
              DropdownButtonFormField<String>(
                value: selectedPosition,
                decoration: const InputDecoration(labelText: 'Position'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPosition = newValue!;
                  });
                },
                items: <String>['User', 'Manager']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
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
                // Thêm người dùng vào Firebase
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                String userId = widget.roomId;
                String position = selectedPosition; // Lấy giá trị từ dropdown

                String res = await AuthMethods().signUpUser(
                  email: email,
                  password: password,
                  position: position,
                  roomId: userId,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res)),
                );

                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showIncomeInformationDialog(String email) async {
    final TextEditingController incomeController = TextEditingController();
    final TextEditingController dependentController = TextEditingController();
    final TextEditingController otherController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    FirestoreMethods firestoreMethods = FirestoreMethods();

    // Gọi hàm để lấy thông tin thu nhập
    Map<String, dynamic>? incomeData =
        await firestoreMethods.getInformationIncome(email);

    // Nếu dữ liệu tồn tại, điền vào TextField
    if (incomeData != null) {
      incomeController.text = incomeData['income'] ?? '';
      dependentController.text = incomeData['dependent'] ?? '';
      otherController.text = incomeData['other'] ?? '';
      dateController.text =
          incomeData['date'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    // Nếu chưa có ngày, hiển thị ngày hiện tại theo định dạng dd/MM/yyyy
    if (dateController.text.isEmpty) {
      dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Information Income'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration:
                      const InputDecoration(labelText: 'Date (dd/MM/yyyy)'),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    try {
                      DateFormat('dd/MM/yyyy').parseStrict(value);
                    } catch (e) {
                      return 'Invalid date format';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: incomeController,
                  decoration: const InputDecoration(labelText: 'Income'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Income is required';
                    } else if (double.tryParse(value)! <= 0) {
                      return 'Income must be greater than 0';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: dependentController,
                  decoration: const InputDecoration(labelText: 'Dependent'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Dependent is required';
                    } else if (double.tryParse(value)! < 0) {
                      return 'Other must be greater than or 0';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: otherController,
                  decoration: const InputDecoration(labelText: 'Other'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Other is required';
                    } else if (double.tryParse(value)! <= 0) {
                      return 'Other must be greater than  0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showStatisticsDialog(context, email); // Open statistics dialog
              },
              child: const Text('Table'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Chỉ thêm hoặc cập nhật khi tất cả các trường hợp hợp lệ
                  String income = incomeController.text.trim();
                  String dependent = dependentController.text.trim();
                  String other = otherController.text.trim();
                  String date = dateController.text.trim();

                  // Trích xuất năm và tháng từ ngày
                  DateTime selectedDate = DateFormat('dd/MM/yyyy').parse(date);
                  int selectedYear = selectedDate.year;
                  int selectedMonth = selectedDate.month;

                  // Lưu thông tin vào Firestore
                  String res = await firestoreMethods.addInformationincome(
                      income, dependent, other, email);

                  // Làm mới lại thông tin thu nhập
                  Map<String, dynamic>? updatedIncomeData =
                      await firestoreMethods.getInformationIncome(email);
                  if (updatedIncomeData != null) {
                    incomeController.text = updatedIncomeData['income'] ?? '';
                    dependentController.text =
                        updatedIncomeData['dependent'] ?? '';
                    otherController.text = updatedIncomeData['other'] ?? '';
                  }

                  // Tính thuế từ thu nhập
                  double calculateTax =
                      await firestoreMethods.calculateTax(email);

                  // Lưu thông tin vào Firestore với tax tính toán
                  await firestoreMethods.saveIncomeInformation(
                      email,
                      selectedYear,
                      selectedMonth,
                      int.parse(income) + int.parse(other),
                      int.parse(dependent),
                      calculateTax);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res)),
                  );

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
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
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Center(child: Text('Add ns')),
        actions: [
          IconButton(
            onPressed: _showAddUserDialog,
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('roomId', isEqualTo: widget.roomId)
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
                                  // Gọi phương thức để xóa người dùng từ Firebase
                                  String result = await AuthMethods()
                                      .deleteUser(user[
                                          'userId']); // Thay đổi theo phương thức xóa của bạn

                                  // Hiển thị thông báo dựa trên kết quả
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            result)), // Hiển thị thông báo xóa
                                  );
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
