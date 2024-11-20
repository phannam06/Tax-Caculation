import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tax_calculation/screens/login_screen.dart';
import 'package:tax_calculation/utils/colors.dart';

class TableScreen extends StatefulWidget {
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<Map<String, dynamic>> tableData = [];
  Map<String, dynamic> deductionForTaxpayer = {
    "title": "Taxpayer",
    "value": ""
  };
  Map<String, dynamic> deductionForDependents = {
    "title": "Dependent",
    "value": ""
  };

// Khai báo các controller cho TextFormField
  late TextEditingController taxpayerController;
  late TextEditingController dependentController;

  @override
  void initState() {
    super.initState();
    taxpayerController = TextEditingController();
    dependentController = TextEditingController();
    fetchDataFromFirebase();
  }

  @override
  void dispose() {
    taxpayerController.dispose();
    dependentController.dispose();
    super.dispose();
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('formula_value')
          .doc("formulaData")
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          tableData = List<Map<String, dynamic>>.from(data["rows"] ?? []);
          List deductions = data["deductions"] ?? [];
          if (deductions.isNotEmpty) {
            deductionForTaxpayer["value"] = deductions[0]["value"] ?? "";
            taxpayerController.text =
                deductionForTaxpayer["value"]; // Cập nhật controller
          }
          if (deductions.length > 1) {
            deductionForDependents["value"] = deductions[1]["value"] ?? "";
            dependentController.text =
                deductionForDependents["value"]; // Cập nhật controller
          }
        });
      } else {
        print("Document does not exist!");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void addRow() {
    setState(() {
      tableData.add({"min": "", "max": "", "value": ""});
    });
  }

  void deleteRow() {
    setState(() {
      if (tableData.isNotEmpty) {
        tableData.removeLast();
      }
    });
  }

  Future<void> saveDataToFirebase() async {
    await FirebaseFirestore.instance
        .collection('formula_value')
        .doc("formulaData")
        .set({
      "rows": tableData,
      "deductions": [
        {
          "title": deductionForTaxpayer["title"],
          "value": deductionForTaxpayer["value"]
        },
        {
          "title": deductionForDependents["title"],
          "value": deductionForDependents["value"]
        }
      ]
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Add success")));
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
        title: Center(child: Text("Setting")),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveDataToFirebase,
          ),
        ],
      ),
      body: Column(
        children: [
          // Giảm trừ gia cảnh
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Personal deduction",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: Text(deductionForTaxpayer["title"],
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      child: TextFormField(
                        controller: taxpayerController, // Sử dụng controller
                        decoration: InputDecoration(hintText: "Value"),
                        onChanged: (value) {
                          setState(() {
                            deductionForTaxpayer["value"] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: Text(deductionForDependents["title"],
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                    child: TextFormField(
                      controller: dependentController, // Sử dụng controller
                      decoration: InputDecoration(hintText: "Value"),
                      onChanged: (value) {
                        setState(() {
                          deductionForDependents["value"] = value;
                        });
                      },
                    ),
                  )
                ])
              ],
            ),
          ),
          Divider(color: Colors.grey),
          // Tiêu đề cột
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                    child: Text("Min",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("Max",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text("Value",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Divider(color: Colors.grey),
          // Dữ liệu bảng chính
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: tableData.map((row) {
                  int index = tableData.indexOf(row);
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: row["min"],
                            decoration: InputDecoration(
                                hintText: "min", border: OutlineInputBorder()),
                            onChanged: (value) {
                              setState(() {
                                tableData[index]["min"] = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: row["max"],
                            decoration: InputDecoration(
                                hintText: "max", border: OutlineInputBorder()),
                            onChanged: (value) {
                              setState(() {
                                tableData[index]["max"] = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: row["value"],
                            decoration: InputDecoration(
                                hintText: "value",
                                border: OutlineInputBorder()),
                            onChanged: (value) {
                              setState(() {
                                tableData[index]["value"] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Nút thêm và xóa dòng
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: addRow, child: Text("Add Row")),
              SizedBox(width: 10),
              ElevatedButton(onPressed: deleteRow, child: Text("Delete Row")),
            ],
          ),
        ],
      ),
    );
  }
}
