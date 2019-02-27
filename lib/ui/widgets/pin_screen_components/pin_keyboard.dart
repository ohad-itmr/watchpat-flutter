import 'package:my_pat/bloc/helpers/bloc_provider.dart';
import 'package:flutter/material.dart';

class PinKeyboard extends StatelessWidget {
  final children = <Widget>[];


  @override
  Widget build(BuildContext context) {
    final PinBloc pinBloc = BlocProvider.of<PinBloc>(context);

    for (var i = 0; i <= 6; i = i + 3) {
      final rowChildren = <Widget>[];
      for (var j = 0; j <= 2; j++) {
        var number = j + i + 1;
        rowChildren.add(
          MaterialButton(
            onPressed: ()=>pinBloc.onPinChange(number),
            minWidth: 20.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 17.0),
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.display1.fontSize),
              ),
            ),
          ),
        );
      }
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
      );
    }

    children.add(
      Center(
        child: MaterialButton(
          onPressed: ()=>pinBloc.onPinChange(10),
          minWidth: 30.0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
            child: Text(
              '0',
              style:
              TextStyle(fontSize: Theme.of(context).textTheme.display1.fontSize),
            ),
          ),
        ),
      ),
    );

    return Column(
      children: <Widget>[
        Container(
          height: 10,
          color: Colors.grey[350],
        ),
        Container(
          height: 0.5,
          color: Colors.grey[200],
        ),
        Expanded(
          child: Container(
            alignment: Alignment(0.0, 0.0),
            color: Colors.grey[300],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.only(top: 20.0),
                    child: IconButton(
                      icon: Icon(Icons.backspace),
                      color: Colors.grey,
                      onPressed: ()=>pinBloc.onPinChange(-1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
