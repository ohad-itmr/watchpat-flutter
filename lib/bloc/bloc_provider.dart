import 'package:flutter/material.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
export 'pin_bloc.dart';
export 'app_bloc.dart';
export 'ble_bloc.dart';
export 'battery_bloc.dart';
export 'my_pat_logger_bloc.dart';
export 'welcome_activity_bloc.dart';
export 'command_tasker_bloc.dart';
export 'device_config_bloc.dart';
export 'system_state_bloc.dart';
export 'incoming_packet_handler_bloc.dart';

Type _typeOf<T>() => T;


class BlocProvider<T extends BlocBase> extends StatefulWidget {
  BlocProvider({
    Key key,
    this.child,
    @required this.bloc,
  }): super(key: key);

  final Widget child;
  final T bloc;

  @override
  _BlocProviderState<T> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context){
    final type = _typeOf<_BlocProviderInherited<T>>();
    _BlocProviderInherited<T> provider =
      context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;
    return provider?.bloc;
  }

  BlocProvider<T> copyWith(Widget child) {
    return BlocProvider<T>(
      key: key,
      bloc: bloc,
      child: child,
    );
  }
}

class _BlocProviderState<T extends BlocBase> extends State<BlocProvider<T>>{
  @override
  void dispose(){
    widget.bloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return new _BlocProviderInherited<T>(
      bloc: widget.bloc,
      child: widget.child,
    );
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  _BlocProviderInherited({
    Key key,
    Widget child,
    @required this.bloc,
  }) : super(key: key, child: child);

  final T bloc;

  @override
  bool updateShouldNotify(_BlocProviderInherited oldWidget) => false;
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
