import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  Room({required this.id, required this.name});

  static Room fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Room(id: snapshot['id'], name: snapshot['name']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
