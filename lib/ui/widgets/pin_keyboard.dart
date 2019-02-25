import 'package:my_pat/bloc/bloc_provider.dart';
import 'package:flutter/material.dart';

class PinKeyboard extends StatelessWidget {
  final children = <Widget>[];

  onInput(PinBloc pinBloc, AsyncSnapshot<String> snapshot, int value) {
    var currentPin = snapshot.hasData ? snapshot.data : '';
    var newPin='';
    if (value >= 0) {
      if (currentPin.length < 4) {
        newPin = currentPin + '$value';
        pinBloc.changePin(newPin);
      }
    } else {
      if (currentPin.length > 0) {
        newPin = currentPin.substring(0, currentPin.length-1);
        pinBloc.changePin(newPin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PinBloc pinBloc = BlocProvider.of<PinBloc>(context);

    for (var i = 0; i <= 6; i = i + 3) {
      final rowChildren = <Widget>[];
      for (var j = 0; j <= 2; j++) {
        var number = j + i + 1;
        rowChildren.add(
          StreamBuilder(
            stream: pinBloc.pin,
            builder: (BuildContext context, snapshot) {
              return MaterialButton(
                onPressed: () => onInput(pinBloc, snapshot, number),
                minWidth: 20.0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 17.0),
                  child: Text(
                    '$number',
                    style: TextStyle(
                        fontSize: Theme.of(context).textTheme.display1.fontSize),
                  ),
                ),
              );
            },
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
      StreamBuilder(
        stream: pinBloc.pin,
        builder: (BuildContext context, snapshot) {
          return Center(
            child: MaterialButton(
              onPressed: () => onInput(pinBloc, snapshot, 0),
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
          );
        },
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
                    child: StreamBuilder(
                      stream: pinBloc.pin,
                      builder: (BuildContext context, snapshot) {
                        return IconButton(
                          icon: Icon(Icons.backspace),
                          color: Colors.grey,
                          onPressed: ()=>onInput(pinBloc, snapshot, -1),
                        );
                      },
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
