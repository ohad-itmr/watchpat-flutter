import 'package:flutter/material.dart';
import 'button.dart';
import '../helpers/localizations.dart';

class ButtonModel {
  final String text;
  final Function action;
  final bool disabled;

  ButtonModel({this.text, this.action, this.disabled = false});
}

class ButtonsBlock extends StatelessWidget {
  final ButtonModel nextActionButton;
  final ButtonModel moreActionButton;

  ButtonsBlock({this.nextActionButton, this.moreActionButton});

  @override
  Widget build(BuildContext context) {
    if (moreActionButton != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Button(
            disabled: moreActionButton.disabled,
            text: moreActionButton.text ?? AppLocalizations.of(context).btnMore,
            action: moreActionButton.action,
            type: ButtonType.moreBtn,
          ),
          Button(
            disabled: nextActionButton.disabled,
            text: nextActionButton.text ?? AppLocalizations.of(context).btnNext,
            action: nextActionButton.action,
            type: ButtonType.nextBtn,
          )
        ],
      );
    } else {
      return Button(
        disabled: nextActionButton.disabled,
        text: nextActionButton.text ?? AppLocalizations.of(context).btnNext,
        action: nextActionButton.action,
        type: ButtonType.nextBtn,
      );
    }
  }
}
