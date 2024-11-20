import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tax_calculation/resources/firestore_method.dart';
import 'package:tax_calculation/screens/login_screen.dart';
import 'package:tax_calculation/utils/colors.dart';
import 'package:tax_calculation/widgets/text_file_input.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _image; // Allow null value

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    FirestoreMethods firestoreMethod = FirestoreMethods();
    Map<String, dynamic>? userProfile = await firestoreMethod.getUserProfile();

    if (userProfile != null) {
      _nameController.text = userProfile['name'] ?? '';
      _phoneController.text = userProfile['phone'] ?? '';
      _addressController.text = userProfile['address'] ?? '';

      //   // Check if there's an image URL
      //   if (userProfile['img'] != null) {
      //     setState(() {});
      //   }
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text("Unable to load user profile")),
      //   );
      // }
    }

    // Future<void> selectImage() async {
    //   final XFile? img =
    //       await ImagePicker().pickImage(source: ImageSource.gallery);
    //   if (img != null) {
    //     setState(() {
    //       _image = File(img.path); // Load selected image
    //     });
    //   }
  }

  void updateProfile() async {
    FirestoreMethods firestoreMethod = FirestoreMethods();
    String res = await firestoreMethod.uploadProfile(
      _nameController.text,
      _phoneController.text,
      _addressController.text,
      // _image!, // Use _image which can be null now
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res)),
    );
  }

  void _showIncomeInformationDialog(String email) async {
    final TextEditingController incomeController = TextEditingController();
    final TextEditingController dependentController = TextEditingController();
    final TextEditingController otherController = TextEditingController();

    // Tạo một thể hiện của FirestoreMethods
    FirestoreMethods firestoreMethods = FirestoreMethods();

    // Lấy dữ liệu từ Firestore và điền vào TextEditingController
    Map<String, dynamic>? data =
        await firestoreMethods.getInformationIncome(email);
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
                String res = await firestoreMethods.addInformationincometest(
                  income,
                  dependent,
                  other,
                  email,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res)),
                );

                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 2),
              const SizedBox(height: 24),
              Stack(
                children: [
                  // Display image based on whether _image is null or not
                  // _image != null
                  //     ? CircleAvatar(
                  //         radius: 64,
                  //         backgroundImage:
                  //             FileImage(_image!), // Use local file image
                  //       )
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(
                        'https://thumbs.dreamstime.com/b/default-avatar-profile-icon-vector-social-media-user-image-182145777.jpg'), // Default image
                  ),
                  // Positioned(
                  //   bottom: -10,
                  //   left: 80,
                  //   child: IconButton(
                  //     onPressed: selectImage,
                  //     icon: const Icon(Icons.add_a_photo),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 14),
              TextFieldInput(
                hintText: 'Enter your name',
                textInputType: TextInputType.text,
                textEditingController: _nameController,
              ),
              const SizedBox(height: 14),
              TextFieldInput(
                textEditingController: _phoneController,
                hintText: "Enter your phone",
                textInputType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              TextFieldInput(
                textEditingController: _addressController,
                hintText: "Enter your address",
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 14),
              Center(
                child: Row(
                  children: [
                    InkWell(
                      onTap: updateProfile,
                      child: Container(
                        // width: 150,
                        width: 140,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          color: blueColor,
                        ),
                        child: const Text('Update'),
                      ),
                    ),
                    const SizedBox(
                      // width: 25
                      width: 15,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      },
                      child: Container(
                        // width: 150,
                        width: 140,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          color: Colors.red,
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () async {
                  // Lấy tài liệu người dùng từ Firestore
                  DocumentSnapshot snapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get();

                  // Kiểm tra nếu email tồn tại trong dữ liệu của snapshot
                  if (snapshot.exists && snapshot.data() != null) {
                    Map<String, dynamic> userData =
                        snapshot.data() as Map<String, dynamic>;
                    String? email = userData[
                        'email']; // lấy trường email từ dữ liệu Firestore
                    if (email != null) {
                      _showIncomeInformationDialog(email);
                    } else {
                      print("Email field is missing for this user.");
                    }
                  } else {
                    print("User document does not exist.");
                  }
                },
                child: Container(
                  width: 320,
                  // width: 325,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: Colors.green,
                  ),
                  child: const Text('Request'),
                ),
              ),
              const SizedBox(height: 15),
              Flexible(child: Container(), flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
