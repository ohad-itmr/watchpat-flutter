import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppBarDecoration extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).accentColor,
            Theme.of(context).primaryColor,
          ],
        ),
      ),
    );
  }

}