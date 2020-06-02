import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'button.dart';
import 'package:my_pat/generated/l10n.dart';

class ButtonModel {
  final String text;
  final Function action;
  final bool disabled;

  ButtonModel({this.text, this.action, this.disabled = false});
}

class ButtonsBlock extends StatelessWidget {
  final ButtonModel nextActionButton;
  final ButtonModel moreActionButton;
  final Widget spinner;
  final S loc = sl<S>();

  ButtonsBlock({this.nextActionButton, this.moreActionButton, this.spinner});

  @override
  Widget build(BuildContext context) {
    if (moreActionButton != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Button(
            disabled: moreActionButton.disabled,
            text: moreActionButton.text ?? loc.btnMore.toUpperCase(),
            action: moreActionButton.action,
            type: ButtonType.moreBtn,
          ),
          Button(
            disabled: nextActionButton.disabled,
            text: nextActionButton.text ?? loc.btnNext.toUpperCase(),
            action: nextActionButton.action,
            type: ButtonType.nextBtn,
          )
        ],
      );
    } else if (spinner != null) {
      return spinner;
    } else {
      return Button(
        disabled: nextActionButton.disabled,
        text: nextActionButton.text ?? loc.btnNext.toUpperCase(),
        action: nextActionButton.action,
        type: ButtonType.nextBtn,
      );
    }
  }
}
