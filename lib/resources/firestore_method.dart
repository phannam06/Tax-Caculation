import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:tax_calculation/resources/storage_method.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('profile')
          .doc(_auth.currentUser!.uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> uploadProfile(
      String name, String phone, String address) async {
    try {
      // String photoUrl =
      //     await StorageMethods().uploadImageToStorage('profile', file);
      await _firestore.collection('profile').doc(_auth.currentUser!.uid).set({
        'name': name,
        'phone': phone,
        'address': address,
        // 'img': photoUrl,
      });
      return "Profile updated successfully";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> addInformationincome(
      String income, String dependent, String other, String email) async {
    try {
      // String photoUrl =
      //     await StorageMethods().uploadImageToStorage('profile', file);
      await _firestore.collection('information_income').doc(email).set({
        'income': income,
        'dependent': dependent,
        'other': other,
      });
      return "Information add successfully";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> addInformationincometest(
      String income, String dependent, String other, String email) async {
    try {
      // String photoUrl =
      //     await StorageMethods().uploadImageToStorage('profile', file);
      await _firestore.collection('information_income_test').doc(email).set({
        'income': income,
        'dependent': dependent,
        'other': other,
        'email': email
      });
      return "Information send successfully";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> deleteInformationIncomeTest(String email) async {
    try {
      // Xóa tài liệu của người dùng dựa trên email
      await _firestore
          .collection('information_income_test')
          .doc(email)
          .delete();
      return "Information deleted successfully";
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> getInformationIncome(String email) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('information_income').doc(email).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getInformationIncometest(String email) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('information_income_test')
          .doc(email)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  Future<double> calculateTax(String email) async {
    try {
      // Lấy dữ liệu từ Firebase Firestore
      DocumentSnapshot snap1 =
          await _firestore.collection('information_income').doc(email).get();
      DocumentSnapshot snap2 =
          await _firestore.collection('formula_value').doc('formulaData').get();

      double result = 0.0;

      // Chuyển đổi các giá trị từ Firestore
      int income = int.parse(snap1['income'].toString()) +
          int.parse(snap1['other'].toString()); // Tổng thu nhập
      print("income: $income");

      int dependents =
          int.parse(snap1['dependent'].toString()); // Số người phụ thuộc
      print("dependents: $dependents");

      double deductionPerDependent = double.parse(snap2['deductions'][1]
              ['value']
          .toString()); // Giảm trừ cho từng người phụ thuộc
      print("deductionPerDependent: $deductionPerDependent");

      // Tính toán thu nhập điều chỉnh
      double adjustedIncome = income - (dependents * deductionPerDependent);
      double personalDeduction =
          double.parse(snap2['deductions'][0]['value'].toString());

      // Kiểm tra và trừ giảm trừ bản thân
      if (adjustedIncome > personalDeduction) {
        adjustedIncome -= personalDeduction;
      } else {
        return 0.0; // Nếu thu nhập điều chỉnh nhỏ hơn hoặc bằng giảm trừ bản thân
      }

      print("personalDeduction: $personalDeduction");
      print("adjustedIncome: $adjustedIncome");

      // Kiểm tra nếu thu nhập nhỏ hơn khoảng thu nhập tối thiểu
      List rows = snap2['rows'];
      if (adjustedIncome < int.parse(rows.first['min'].toString())) {
        return double.parse(adjustedIncome.toStringAsFixed(
            2)); // Nếu thu nhập đã điều chỉnh nhỏ hơn khoảng tối thiểu
      }

      // Duyệt qua các khoảng thuế để tính thuế
      for (var c in rows) {
        int min = int.parse(c['min'].toString());
        int max = int.parse(c['max'].toString());
        int taxRate = int.parse(c['value'].toString());

        if (adjustedIncome > max) {
          // Nếu thu nhập lớn hơn khoảng tối đa, tính thuế cho toàn bộ khoảng
          result += (max - min) * (taxRate / 100);
        } else if (adjustedIncome > min) {
          // Nếu thu nhập nằm trong khoảng này, tính thuế cho phần chênh lệch
          result += (adjustedIncome - min) * (taxRate / 100);
          break; // Kết thúc vòng lặp vì đã tính thuế
        }
      }

      // Đảm bảo luôn trả về kết quả với số thập phân thứ 2
      return double.parse(result.toStringAsFixed(2));
    } catch (e) {
      print("Error calculating tax: $e");
      return 0.0; // Trả về 0.0 trong trường hợp có lỗi
    }
  }

  Future<double> calculateTaxV2(int income, int other, int dependents) async {
    try {
      // Lấy dữ liệu từ Firebase Firestore
      // DocumentSnapshot snap1 =
      //     await _firestore.collection('information_income').doc(email).get();
      DocumentSnapshot snap2 =
          await _firestore.collection('formula_value').doc('formulaData').get();

      double result = 0.0;

      // Chuyển đổi các giá trị từ Firestore
      // int income = int.parse(snap1['income'].toString()) +
      //     int.parse(snap1['other'].toString()); // Tổng thu nhập
      // print("income: $income");

      // int dependents =
      //     int.parse(snap1['dependent'].toString()); // Số người phụ thuộc
      // print("dependents: $dependents");

      double deductionPerDependent = double.parse(snap2['deductions'][1]
              ['value']
          .toString()); // Giảm trừ cho từng người phụ thuộc
      print("deductionPerDependent: $deductionPerDependent");

      // Tính toán thu nhập điều chỉnh
      double adjustedIncome = income - (dependents * deductionPerDependent);
      double personalDeduction =
          double.parse(snap2['deductions'][0]['value'].toString());

      // Kiểm tra và trừ giảm trừ bản thân
      if (adjustedIncome > personalDeduction) {
        adjustedIncome -= personalDeduction;
      } else {
        return 0.0; // Nếu thu nhập điều chỉnh nhỏ hơn hoặc bằng giảm trừ bản thân
      }

      print("personalDeduction: $personalDeduction");
      print("adjustedIncome: $adjustedIncome");

      // Kiểm tra nếu thu nhập nhỏ hơn khoảng thu nhập tối thiểu
      List rows = snap2['rows'];
      if (adjustedIncome < int.parse(rows.first['min'].toString())) {
        return double.parse(adjustedIncome.toStringAsFixed(
            2)); // Nếu thu nhập đã điều chỉnh nhỏ hơn khoảng tối thiểu
      }

      // Duyệt qua các khoảng thuế để tính thuế
      for (var c in rows) {
        int min = int.parse(c['min'].toString());
        int max = int.parse(c['max'].toString());
        int taxRate = int.parse(c['value'].toString());

        if (adjustedIncome > max) {
          // Nếu thu nhập lớn hơn khoảng tối đa, tính thuế cho toàn bộ khoảng
          result += (max - min) * (taxRate / 100);
        } else if (adjustedIncome > min) {
          // Nếu thu nhập nằm trong khoảng này, tính thuế cho phần chênh lệch
          result += (adjustedIncome - min) * (taxRate / 100);
          break; // Kết thúc vòng lặp vì đã tính thuế
        }
      }

      // Đảm bảo luôn trả về kết quả với số thập phân thứ 2
      return double.parse(result.toStringAsFixed(2));
    } catch (e) {
      print("Error calculating tax: $e");
      return 0.0; // Trả về 0.0 trong trường hợp có lỗi
    }
  }

  // Future<void> saveIncomeInformation(String email, int year, int month,
  //     int income, int dependent, double calculateTax) async {
  //   try {
  //     // Lấy tham chiếu tài liệu của người dùng
  //     DocumentReference docRef =
  //         FirebaseFirestore.instance.collection('statistics').doc(email);

  //     // Tạo dữ liệu cho tháng
  //     Map<String, dynamic> monthData = {
  //       'income': income,
  //       'dependent': dependent,
  //       'calculate_tax': calculateTax,
  //     };

  //     // Cập nhật hoặc tạo tài liệu mới cho người dùng với thông tin năm và tháng
  //     await docRef.set({
  //       // Nếu không có trường "years", nó sẽ tự tạo, còn nếu có rồi thì sẽ thêm tháng vào
  //       '$year': FieldValue.arrayUnion([
  //         {'month': month, 'data': monthData}
  //       ])
  //     }, SetOptions(merge: true)); // Merge để chỉ cập nhật các trường cần thiết

  //     print('Income information saved successfully!');
  //   } catch (e) {
  //     print('Error saving income information: $e');
  //   }
  // }

  Future<void> saveIncomeInformation(String email, int year, int month,
      int income, int dependent, double calculateTax) async {
    Excel excelFile = Excel.createExcel();
    try {
      // Lấy tham chiếu tài liệu của người dùng
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('statistics').doc(email);

      // Lấy tài liệu người dùng
      DocumentSnapshot docSnapshot = await docRef.get();

      // Tạo dữ liệu cho tháng
      Map<String, dynamic> monthData = {
        'income': income,
        'dependent': dependent,
        'calculate_tax': calculateTax,
      };

      // Kiểm tra xem tài liệu có tồn tại không
      if (docSnapshot.exists) {
        // Lấy dữ liệu từ tài liệu và ép kiểu về Map<String, dynamic>
        Map<String, dynamic> yearsData =
            (docSnapshot.data() as Map<String, dynamic>)['years'] ?? {};

        // Kiểm tra xem năm đã tồn tại chưa
        if (yearsData.containsKey(year.toString())) {
          // Ensure year is treated as a String
          // Kiểm tra xem tháng đã tồn tại chưa trong năm
          List<dynamic> months =
              yearsData[year.toString()]; // Treat year as String
          bool monthExists = false;

          // Duyệt qua các tháng để kiểm tra
          for (var item in months) {
            if (item['month'] == month) {
              item['data'] = monthData; // Cập nhật dữ liệu nếu tháng đã tồn tại
              monthExists = true;
              break;
            }
          }

          // Nếu tháng chưa tồn tại, thêm mới vào mảng
          if (!monthExists) {
            months.add({'month': month, 'data': monthData});
          }

          // Cập nhật lại toàn bộ dữ liệu
          await docRef.update({
            'years.$year': months,
          });
        } else {
          // Nếu năm chưa tồn tại, tạo mới mảng các tháng
          await docRef.update({
            'years.$year': [
              {'month': month, 'data': monthData}
            ],
          });
        }
      } else {
        // Nếu tài liệu người dùng chưa tồn tại, tạo tài liệu mới
        await docRef.set({
          'years': {
            year.toString(): [
              {'month': month, 'data': monthData}
            ]
          }
        });
      }

      print('Income information saved successfully!');
    } catch (e) {
      print('Error saving income information: $e');
    }
  }

  Future<void> exportToExcel(String email) async {
    try {
      // Create a new Excel file
      final Workbook workbook = Workbook();
      Worksheet sheet = workbook.worksheets[0];

      // Add headers to the first row
      // List<String> headers = [
      //   "Year",
      //   "Month",
      //   "Income",
      //   "Dependent",
      //   "Calculated Tax"
      // ];
      // for (int col = 0; col < headers.length; col++) {
      //   sheet.getRangeByIndex(0, col).setText(headers[col]);
      // }

      // // Fetch data from Firestore
      // DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      //     .collection('statistics')
      //     .doc(email)
      //     .get();

      // if (!docSnapshot.exists) {
      //   print("No data found for email: $email");
      //   return;
      // }

      // Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
      // if (data == null) {
      //   print("Error: Data is null for email: $email");
      //   return;
      // }

      // Map<String, dynamic>? yearsData = data['years'] as Map<String, dynamic>?;
      // if (yearsData == null) {
      //   print("Error: 'years' data is missing for email: $email");
      //   return;
      // }

      // // Print out the years data for debugging
      // print("Years Data: $yearsData");

      // // Start from row 1 (the second row in the sheet, as row 0 is for headers)
      // int row = 1;

      // // Iterate over the years data
      // yearsData.forEach((year, months) {
      //   if (months is List) {
      //     for (var monthData in months) {
      //       if (monthData is Map<String, dynamic> &&
      //           monthData.containsKey('month') &&
      //           monthData.containsKey('data')) {
      //         var month = monthData['month'];
      //         Map<String, dynamic>? details = monthData['data'];

      //         // Ensure all necessary data is present
      //         if (details != null &&
      //             details.containsKey('income') &&
      //             details.containsKey('dependent') &&
      //             details.containsKey('calculate_tax')) {
      //           // Print data for debugging
      //           print(
      //               "Writing data for Year: $year, Month: $month, Income: ${details['income']}, Dependent: ${details['dependent']}, Tax: ${details['calculate_tax']}");

      //           // Check if the row index is within a valid range (Excel limit: 1048576 rows)
      //           if (row < 1048576) {
      //             sheet
      //                 .getRangeByIndex(row, 0)
      //                 .setText(year.toString()); // Year
      //             sheet
      //                 .getRangeByIndex(row, 1)
      //                 .setText(month.toString()); // Month
      //             sheet
      //                 .getRangeByIndex(row, 2)
      //                 .setNumber(details['income']); // Income
      //             sheet
      //                 .getRangeByIndex(row, 3)
      //                 .setNumber(details['dependent']); // Dependent
      //             sheet
      //                 .getRangeByIndex(row, 4)
      //                 .setNumber(details['calculate_tax']); // Calculated Tax
      //             row++; // Move to the next row
      //           } else {
      //             print("Reached maximum number of rows in Excel.");
      //             return;
      //           }
      //         } else {
      //           print("Missing data for Month: $month, Year: $year");
      //         }
      //       } else {
      //         print("Invalid month data structure for Year: $year");
      //       }
      //     }
      //   } else {
      //     print("Expected List for months data under Year: $year");
      //   }
      // });

      // Save the workbook as bytes
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Save the Excel file to the external directory
      final directory = await getExternalStorageDirectory();
      final path = directory?.path;
      if (path != null) {
        final file = File('$path/Income_Report_${email}.xlsx');
        await file.writeAsBytes(bytes);
        print("Excel file saved successfully: ${file.path}");
      }
    } catch (e) {
      print("Error exporting data to Excel: $e");
    }
  }
}
