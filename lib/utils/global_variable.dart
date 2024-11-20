import 'package:flutter/material.dart';
import 'package:tax_calculation/screens/notifycation.dart';
import 'package:tax_calculation/screens/profile_screen.dart';
import 'package:tax_calculation/screens/statistics_screen.dart';
import 'package:tax_calculation/screens/statistics_table_manager_screen.dart';
import 'package:tax_calculation/screens/statistics_table_screen.dart';
import 'package:tax_calculation/widgets/add_screen.dart';
import 'package:tax_calculation/widgets/receipt_screen.dart';

List<Widget> homeScreenItems1 = [
  StatisticsScreen(),
  StatisticsTableScreen(),
  ProfileScreen()
];

List<Widget> homeScreenItems2 = [Notifycation(), AddScreen(), TableScreen()];

List<Widget> homeScreenItems3 = [
  StatisticsScreen(),
  StatisticsTableManagerScreen(),
  ProfileScreen()
];
