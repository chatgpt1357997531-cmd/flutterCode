import 'package:adminpanelapp/screens/EditAndDeleteScreen.dart';
import 'package:adminpanelapp/screens/AddPriceTab.dart';
import 'package:adminpanelapp/screens/add_accessories.dart';
import 'package:adminpanelapp/screens/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Blues for the theme
    const Color kBlue = Color(0xFF1565C0);
    const Color kBlueLight = Color(0xFFE3F2FD);
    const Color kSurface = Color(0xFFFDFEFF);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: kSurface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110), // Taller app bar
          child: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
           title: RichText(
  text: TextSpan(
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
    children: [
      const TextSpan(
        text: "Doctor ",
        style: TextStyle(color: Colors.black),
      ),
      TextSpan(
        text: "Phone",
        style: TextStyle(color: kSurface), // your theme blue
      ),
    ],
  ),
),

            centerTitle: true,
            backgroundColor: kBlue,
            elevation: 0, // remove shadow
            scrolledUnderElevation: 0, // removes grey line when scrolling
            surfaceTintColor: Colors.transparent, // prevent overlay tint
            shadowColor: Colors.transparent, // ensure no shadow line
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0), // pushes tabs lower
                child: TabBar(
                   dividerColor: Colors.transparent, // remove the grey line
                  indicator: BoxDecoration(
                    color: kBlueLight,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: kBlueLight, width: 1),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: kBlue,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: const [
                    Tab(text: "📱 Add Phone"),
                    Tab(text: "🗑 Delete Phone"),
                    Tab(text: "💰 Add Price"),
                    Tab(text: "💰 Add Accessories"),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            AddCardScreen(),
            EditAndDeleteScreen(),
            AddPriceTab(),
            AddAccessoriesScreen(),
          ],
        ),
      ),
    );
  }
}
