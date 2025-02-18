import 'package:flutter/cupertino.dart';


import '../utils/utils.dart';
import 'login.dart';


class Intermediatepage extends StatefulWidget {
  Map<String,dynamic> userdata;
  bool isLogged;
  Intermediatepage({required this.userdata ,required this.isLogged ,super.key});

  @override
  State<Intermediatepage> createState() => _IntermediatepageState();
}

class _IntermediatepageState extends State<Intermediatepage> {
  @override

  Widget build(BuildContext context) {
    if(widget.isLogged){
      return utils().intermediate(widget.userdata, context);
    }else{
      return LoginScreen();
    }

  }
}
