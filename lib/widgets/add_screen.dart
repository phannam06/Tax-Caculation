import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tax_calculation/screens/login_screen.dart';
import 'package:tax_calculation/widgets/room_detail_screen.dart';
import 'package:uuid/uuid.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  void addRoom(String name) {
    String id = Uuid().v1();
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(id)
        .set({'id': id, 'name': name}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room added successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add room: $error')),
      );
    });
  }

  void showAddRoomDialog() {
    String roomName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Room'),
          content: TextField(
            onChanged: (value) {
              roomName = value;
            },
            decoration: InputDecoration(hintText: "Enter room name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (roomName.isNotEmpty) {
                  addRoom(roomName);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Room name cannot be empty')),
                  );
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void navigateToRoomDetail(String roomId, String roomName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RoomDetailScreen(roomId: roomId, roomName: roomName),
      ),
    );
  }

  void editRoom(String roomId, String currentName) {
    TextEditingController _nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Room Name"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: 'Enter new room name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(roomId)
                      .update({'name': newName}).then((_) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Room name updated successfully!')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to update room name: $error')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Room name cannot be empty')),
                  );
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.home),
          ),
          title: Center(child: Text("Add room")),
          actions: [
            IconButton(
              onPressed: showAddRoomDialog,
              icon: Icon(
                Icons.add,
                size: 30,
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('rooms').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No rooms available"));
                  }

                  // Hiển thị danh sách phòng
                  final rooms = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return GestureDetector(
                        onTap: () =>
                            navigateToRoomDetail(room['id'], room['name']),
                        child: Container(
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Room name display
                                Text(
                                  room['name'],
                                  style: TextStyle(fontSize: 18),
                                ),

                                // Edit icon button
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      editRoom(room['id'], room['name']),
                                )
                              ]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
