import 'package:adminpanelapp/screens/EditAndDeleteScreen.dart';
import 'package:adminpanelapp/screens/AddPriceTab.dart';
import 'package:adminpanelapp/screens/add_card_screen.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8E9),
        appBar: AppBar(
          title: const Text(
            "Admin Panel",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: const Color(0xFF558B2F),
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
         bottom: TabBar(
  indicator: BoxDecoration(
    color: Color(0xFFC5E1A5), // Soft green indicator background
    borderRadius: BorderRadius.circular(30),
  ),
  labelColor: Colors.black,
  unselectedLabelColor: Colors.white,
  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
  tabs: const [
    Tab(text: "📱 Add Phone"),
    Tab(text: "🗑 Delete Phone"),
    Tab(text: "💰 Add Price"),
  ],
),

        ),
        body: const TabBarView(
          children: [
            AddCardScreen(),
            EditAndDeleteScreen(),
            AddPriceTab(),
          ],
        ),
      ),
    );
  }
}
