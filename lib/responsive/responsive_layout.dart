import 'package:flutter/material.dart';
import 'package:tax_calculation/responsive/mobile_screen_1.dart';
import 'package:tax_calculation/responsive/mobile_screen_2.dart';
import 'package:tax_calculation/responsive/mobile_screen_3.dart';

class ResponsiveLayout extends StatefulWidget {
  final String position;
  const ResponsiveLayout({super.key, required this.position});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (widget.position == "Admin") {
        return MobileScreen2();
      } else if (widget.position == "User") {
        return MobileScreen1();
      } else if (widget.position == "Manager") {
        return MobileScreen3();
      } else {
        return Center(child: Text('Invalid position')); // Fallback widget
      }
    });
  }
}
