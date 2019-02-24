import 'package:flutter/material.dart';
import 'file_bloc.dart';
export 'file_bloc.dart';

class FileBlocProvider extends InheritedWidget {
  final FileBloc bloc;

  FileBlocProvider({Key key, Widget child})
    : bloc = FileBloc(),
      super(key: key, child: child);

  @override
  bool updateShouldNotify(_) => true;


  static FileBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(FileBlocProvider) as FileBlocProvider).bloc;
  }

}
