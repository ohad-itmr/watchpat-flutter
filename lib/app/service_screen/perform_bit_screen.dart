import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/widgets/appbar_decoration.dart';
import 'package:my_pat/widgets/widgets.dart';

class PerformBitScreen extends StatefulWidget {
  @override
  _PerformBitScreenState createState() => _PerformBitScreenState();

  final List<String> bitOptions = [
    "AII tests",
    "AFE LEDs",
    "AFE Photo-diode",
    "DC-DC",
    "Battery",
    "Flash",
    "Actigraph",
    "SBP Exists",
    "UPAT EEPROM",
    "Bracelet",
    "Finger"
  ];
}

class _PerformBitScreenState extends State<PerformBitScreen> {
  List<String> _selectedBitOptions = [];
  final _manager = sl<ServiceScreenManager>();

  Widget _buildListViewItem(BuildContext context, int i) {
    if (i != widget.bitOptions.length) {
      String option = widget.bitOptions[i];
      return CheckboxListTile(
        title: Text(option),
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
              action: () =>_manager.performBitOperation(),
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
          itemCount: widget.bitOptions.length + 1),
    );
  }
}
