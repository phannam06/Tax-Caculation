import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tax_calculation/models/user_model.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return UserModel.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String position,
      required String roomId}) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty || password.isNotEmpty || position.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        UserModel user = UserModel(
            email: email,
            password: password,
            position: position,
            roomId: roomId,
            userId: cred.user!.uid);

        _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
        res = 'success';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteUser(String userId) async {
    String res = 'Some error occurred';
    try {
      // Lấy thông tin người dùng từ Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Đăng nhập vào tài khoản bằng email và password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: userDoc['email'], // Lấy email từ tài liệu
          password: userDoc['password'], // Sử dụng mật khẩu đã cung cấp
        );

        // Nếu đăng nhập thành công, xóa người dùng khỏi Firestore
        await _firestore.collection('users').doc(userId).delete();

        // Xóa tài khoản người dùng
        await userCredential.user!.delete(); // Xóa tài khoản người dùng

        res = 'User deleted successfully';
      } else {
        res = 'User not found';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        return res = "Please enter all fields";
      }
    } catch (err) {
      res = "Email or password is incorrect.";
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
