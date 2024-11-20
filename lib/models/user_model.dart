import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String password;
  final String position;
  final String userId;
  final String roomId;
  UserModel(
      {required this.email,
      required this.password,
      required this.position,
      required this.roomId,
      required this.userId});
  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
        email: snapshot['email'],
        password: snapshot['password'],
        position: snapshot['position'],
        roomId: snapshot['roomId'],
        userId: snapshot['userId']);
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'position': position,
        'roomId': roomId,
        'userId': userId,
      };
}
