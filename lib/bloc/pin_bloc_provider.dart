import 'package:flutter/material.dart';
import 'pin_bloc.dart';
export 'pin_bloc.dart';

class PinBlocProvider extends InheritedWidget {
  final PinBloc bloc;

  PinBlocProvider({Key key, Widget child})
    : bloc = PinBloc(),
      super(key: key, child: child);

  @override
  bool updateShouldNotify(_) => true;


  static PinBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(PinBlocProvider) as PinBlocProvider).bloc;
  }

}
