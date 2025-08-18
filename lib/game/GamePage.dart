import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/bg_home.webp", fit: BoxFit.cover),
          ),
          // top bar
          Positioned(
            top: 43.h,
            left:8.w,
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/bg_home.webp",
                  width: 45.w,
                  height: 45.h,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
