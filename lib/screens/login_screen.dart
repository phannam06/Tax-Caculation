import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tax_calculation/resources/auth_methods.dart';
import 'package:tax_calculation/responsive/mobile_screen_2.dart';
import 'package:tax_calculation/responsive/responsive_layout.dart';
import 'package:tax_calculation/utils/colors.dart';
import 'package:tax_calculation/widgets/text_file_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isForgotPassword = false;
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    // Authenticate user
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);

    if (res == 'success') {
      // Fetch user position
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text)
          .get();

      String position = userQuery.docs.isNotEmpty
          ? userQuery.docs.first['position']
          : 'User'; // Default to 'User' if not found

      if (context.mounted) {
        // Navigate based on position
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => ResponsiveLayout(position: position)),
          (route) => false,
        );

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
      }
    }
  }

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Password reset email sent to ${_emailController.text}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter email')),
      );
    }
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
          Flexible(
            child: Container(),
            flex: 2,
          ),
          // SvgPicture.asset(
          //   "assets/ic_instagram.svg",
          //   color: primaryColor,
          //   height: 64,
          // ),
          SizedBox(
            width: 150, // Chiều rộng mong muốn
            height: 150, // Chiều cao mong muốn
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Điều chỉnh độ bo góc
              child: Image.asset(
                'assets/images/img1.webp',
                fit: BoxFit.cover, // Điều chỉnh cách ảnh hiển thị
              ),
            ),
          ),

          const SizedBox(
            height: 64,
          ),
          TextFieldInput(
              textEditingController: _emailController,
              isPass: false,
              hintText: "Enter your email",
              textInputType: TextInputType.emailAddress),
          const SizedBox(
            height: 24,
          ),
          TextFieldInput(
              textEditingController: _passwordController,
              isPass: true,
              hintText: "Enter your password",
              textInputType: TextInputType.visiblePassword),
          const SizedBox(
            height: 24,
          ),
          InkWell(
            onTap: () {
              loginUser();
            },
            child: Container(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : Text("Login"),
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  color: blueColor),
            ),
          ),
          const SizedBox(
            height: 22,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isForgotPassword = true;
              });
              resetPassword(); // Gọi hàm reset mật khẩu
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Flexible(
            child: Container(),
            flex: 2,
          ),
        ],
      ),
    )));
  }
}
