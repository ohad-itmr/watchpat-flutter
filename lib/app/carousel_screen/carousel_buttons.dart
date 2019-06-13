import 'package:flutter/material.dart';
import 'package:my_pat/service_locator.dart';
import 'package:url_launcher/url_launcher.dart';

class CarouselButtonBlock extends StatelessWidget {
  final Function leftBtnCallback;
  final Function rightBtnCallback;
  final bool lastSlide;

  final S loc = sl<S>();

  CarouselButtonBlock(
      {Key key,
      @required this.leftBtnCallback,
      @required this.rightBtnCallback,
      @required this.lastSlide})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: CarouselButton(
            title: loc.btnPrevious.toUpperCase(),
            onPressed: leftBtnCallback,
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width / 60),
                child:
                    Image(image: AssetImage("assets/carousel/play_video.png")),
              ),
              onTap: () => launch(GlobalSettings.demoUrl)),
        ),
        Expanded(
          flex: 3,
          child: CarouselButton(
            title: lastSlide
                ? S.of(context).btnFinish.toUpperCase()
                : S.of(context).btnNext.toUpperCase(),
            onPressed: () => rightBtnCallback(context),
          ),
        ),
      ],
    );
  }
}

class CarouselButton extends StatelessWidget {
  final String title;
  final Function onPressed;

  const CarouselButton({Key key, this.title, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        title,
        style: TextStyle(
          color: onPressed != null ? Colors.white : Colors.grey[600],
        ),
      ),
      onPressed: onPressed,
    );
  }
}
