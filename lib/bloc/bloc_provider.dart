import 'package:flutter/material.dart';
import 'package:my_pat/bloc/bloc_base.dart';
export 'pin_bloc.dart';
export 'file_bloc.dart';
export 'network_bloc.dart';

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  BlocProvider({
    Key key,
    this.child,
    @required this.bloc,
  }) : super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  BlocProvider<T> copyWith(Widget child) {
    return BlocProvider<T>(
      key: key,
      bloc: bloc,
      child: child,
    );
  }

  static T of<T extends BlocBase>(BuildContext context) {
    final type = _typeOf<BlocProvider<T>>();
    BlocProvider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override
  void dispose(){
    widget.bloc.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class BlocProviderTree extends StatelessWidget {
  final List<BlocProvider> blocProviders;

  final Widget child;

  BlocProviderTree({
    Key key,
    @required this.blocProviders,
    @required this.child,
  })  : assert(blocProviders != null),
      assert(child != null),
      super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final blocProvider in blocProviders.reversed) {
      tree = blocProvider.copyWith(tree);
    }
    return tree;
  }
}
