import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tax_calculation/utils/colors.dart';
import 'package:tax_calculation/utils/global_variable.dart';

class MobileScreen1 extends StatefulWidget {
  const MobileScreen1({super.key});

  @override
  State<MobileScreen1> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen1> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: homeScreenItems1,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.table_chart,
                color: (_page == 0) ? primaryColor : secondaryColor,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.calculate,
                color: (_page == 1) ? primaryColor : secondaryColor,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: (_page == 2) ? primaryColor : secondaryColor,
              ),
              label: '')
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
