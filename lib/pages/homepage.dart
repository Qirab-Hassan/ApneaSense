import 'package:apneasense/components/drawer.dart';
import 'package:apneasense/pages/ecgpage.dart';
import 'package:apneasense/pages/history.dart';
import 'package:apneasense/pages/spo2page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const SpO2Page(),
    const ECGPage(),
    const ResultPage(),
  ];

  final List<String> appBarTitles = ['S P O 2', 'E C G', 'R E S U L T S'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            appBarTitles[currentIndex],
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                  color: Color(0xff64EBB6),
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(
                Icons.logout,
                color: Color(0xff64EBB6),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xff64EBB6),
        ),
      ),
      drawer: const CustomDrawer(),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xff64EBB6),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedIconTheme: const IconThemeData(opacity: 0.0, size: 0),
        unselectedIconTheme: const IconThemeData(opacity: 0.0, size: 0),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'S P O 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'E C G',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'R E S U L T',
          ),
        ],
        selectedLabelStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
