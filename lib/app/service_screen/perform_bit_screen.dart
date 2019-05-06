import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/widgets/appbar_decoration.dart';
import 'package:my_pat/widgets/mypat_toast.dart';
import 'package:my_pat/widgets/widgets.dart';

class PerformBitScreen extends StatefulWidget {
  @override
  _PerformBitScreenState createState() => _PerformBitScreenState();
}

class _PerformBitScreenState extends State<PerformBitScreen> {
  List<BitOption> _selectedBitOptions = [];
  final _manager = sl<BitOperationsManager>();

  @override
  void initState() {
    _manager.toasts.listen((String msg) => MyPatToast.show(msg, context));
    sl<IncomingPacketHandlerService>().bitResponse.listen(_showResponseDialog);
    super.initState();
  }

  _showResponseDialog(int response) {
    _manager.loader.sink.add(false);
    final msg = _manager.getBitResponseMessage(response);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("BIT response"),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

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
              action: () => _manager.performBitOperation(_selectedBitOptions),
              type: ButtonType.nextBtn,
              disabled: _selectedBitOptions.length == 0,
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
        actions: <Widget>[
          FlatButton(
            onPressed: null,
            child: StreamBuilder(
              stream: _manager.loading,
              initialData: false,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return snapshot.data
                    ? CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white))
                    : Container();
              },
            ),
          ),
        ],
      ),
      body: ListView.separated(
          shrinkWrap: true,
          itemBuilder: _buildListViewItem,
          separatorBuilder: (_, __) => Divider(),
          itemCount: _manager.bitOptions.length + 1),
    );
  }
}
