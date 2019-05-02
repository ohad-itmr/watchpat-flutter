import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';

class InteractiveTitle extends StatefulWidget {
  final String title;

  const InteractiveTitle({Key key, this.title}) : super(key: key);
  @override
  _InteractiveTitleState createState() => _InteractiveTitleState();
}

class _InteractiveTitleState extends State<InteractiveTitle> {
  final _manager = sl<ServiceScreenManager>();

  _InteractiveTitleState();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _manager.onTitleTap(),
      child: Text(widget.title),
    );
  }
}
