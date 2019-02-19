import 'package:flutter/material.dart';
import 'button.dart';
import '../helpers/localizations.dart';

class ButtonModel {
  final String text;
  final Function action;

  ButtonModel({this.text, this.action});
}

class ButtonsBlock extends StatelessWidget {
  final ButtonModel nextActionButton;
  final ButtonModel moreActionButton;

  ButtonsBlock({this.nextActionButton, this.moreActionButton});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        moreActionButton != null
            ? Button(
                text: moreActionButton.text ?? AppLocalizations.of(context).btnMore,
                action: moreActionButton.action,
                type: ButtonType.moreBtn,
              )
            : null,
        Button(
          text: nextActionButton.text ?? AppLocalizations.of(context).btnNext,
          action: nextActionButton.action,
          type: ButtonType.nextBtn,
        )
      ],
    );
  }
}
