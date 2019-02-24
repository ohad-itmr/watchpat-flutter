import 'package:my_pat/bloc/pin_bloc_provider.dart';
import 'package:flutter/material.dart';

class PinInputs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 70.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          buildDot(context, 0),
          buildDot(context, 1),
          buildDot(context, 2),
          buildDot(context, 3),
        ],
      ),
    );
  }

  Widget buildDot(BuildContext context, int index) {
    final PinBloc pinBloc = PinBlocProvider.of(context);
    return StreamBuilder(
      stream: pinBloc.pin,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        var active = snapshot.hasData && snapshot.data.length - 1 >= index;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.5),
            border: Border.all(
              color: Theme.of(context).accentColor,
              width: 2.0,
              style: BorderStyle.solid,
            ),
            color: active ? Theme.of(context).accentColor : null,
          ),
          width: 15.0,
          height: 15.0,
        );
      },
    );
  }
}
