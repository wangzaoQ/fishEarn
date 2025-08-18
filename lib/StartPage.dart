import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
final int type ;
const StartPage({super.key,required this.type});

@override
_StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
      ],),
    );
  }

}
