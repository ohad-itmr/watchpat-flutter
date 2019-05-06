import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/appbar_decoration.dart';
import 'package:my_pat/widgets/widgets.dart';

class PerformBitScreen extends StatefulWidget {
  @override
  _PerformBitScreenState createState() => _PerformBitScreenState();

}

class _PerformBitScreenState extends State<PerformBitScreen> {
  List<BitOption> _selectedBitOptions = [];
  final _manager = sl<ServiceScreenManager>();

  Widget _buildListViewItem(BuildContext context, int i) {
    if (i != _manager.bitOptions.length) {
      BitOption option = _manager.bitOptions[i];
      return CheckboxListTile(
        title: Text(option.title),
        value: _selectedBitOptions.contains(option),
        onChanged: (bool val) => setState(() => val
            ? _selectedBitOptions.add(option)
            : _selectedBitOptions.remove(option)),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Button(
              text: "Cancel",
              action: () => Navigator.pop(context),
              type: ButtonType.moreBtn,
              disabled: false,
            ),
            Button(
              text: "Execute",
              action: _selectedBitOptions.length > 0 ? () =>_manager.performBitOperation(_selectedBitOptions) : null,
              type: ButtonType.nextBtn,
              disabled: false,
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select BIT type"),
        flexibleSpace: AppBarDecoration(),
      ),
      body: ListView.separated(
          shrinkWrap: true,
          itemBuilder: _buildListViewItem,
          separatorBuilder: (_, __) => Divider(),
          itemCount: _manager.bitOptions.length + 1),
    );
  }
}
