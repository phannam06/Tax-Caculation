import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tax_calculation/utils/colors.dart';
import 'package:tax_calculation/utils/global_variable.dart';

class MobileScreen2 extends StatefulWidget {
  const MobileScreen2({super.key});

  @override
  State<MobileScreen2> createState() => _MobileScreen2State();
}

class _MobileScreen2State extends State<MobileScreen2> {
  int _page = 1;
  late PageController pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: _page);
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
        children: homeScreenItems2,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: Stack(
        children: [
          CupertinoTabBar(
            currentIndex: _page,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications,
                    color: (_page == 0) ? primaryColor : secondaryColor,
                  ),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add,
                    color: (_page == 1) ? primaryColor : secondaryColor,
                  ),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.settings,
                    color: (_page == 2) ? primaryColor : secondaryColor,
                  ),
                  label: '')
            ],
            onTap: navigationTapped,
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2.3,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blueColor,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  navigationTapped(1); // Chuyển đến trang 1
                },
                backgroundColor: blueColor, // Màu nền của nút
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40, // Kích thước biểu tượng
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
