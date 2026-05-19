import 'package:flutter/material.dart';
import 'ai_assistant_screen.dart';
import '../main.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {

  final String token;

  const HomeScreen({
    super.key,
    required this.token,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int currentIndex = 0;

  late List screens;

  @override
  void initState() {
    super.initState();

    screens = [
      TodoScreen(token: widget.token),

      DashboardScreen(
        token: widget.token,
      ),
      AIAssistantScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: currentIndex,

        selectedItemColor:
            const Color(0xFF6C63FF),

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: "Tasks",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "AI Assistant",
          ),
        ],
      ),
    );
  }
}