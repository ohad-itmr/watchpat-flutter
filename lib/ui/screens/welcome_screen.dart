import '../../generated/i18n.dart';
import 'package:flutter/material.dart';
import '../widgets/main_template/main_template.dart';
import '../widgets/main_template/body_template.dart';
import '../widgets/main_template/block_template.dart';
import '../widgets/buttons_block.dart';
import 'package:my_pat/bloc/helpers/bloc_provider.dart';

class WelcomeScreen extends StatelessWidget {
  static const String PATH = '/';

  WelcomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
//    print(appBloc.initialChecksComplete.listen((onData) => print('onData $onData')));
    final S loc = S.of(context);

    return MainTemplate(
      showBack: false,
      showMenu: true,
      body: BodyTemplate(
        topBlock: BlockTemplate(
          type: BlockType.image,
          imageName: 'welcome.png',
        ),
        bottomBlock: BlockTemplate(
          type: BlockType.text,
          title: loc.welcomeTitle,
          content: [
            loc.welcomeContent,
          ],
        ),
        buttons: StreamBuilder(
          stream: appBloc.initialChecksComplete,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            print('[SNAPSHOT] ${snapshot.data}');
            if (snapshot.data == true) {
              return ButtonsBlock(
                nextActionButton: ButtonModel(
                  action: () {
                    Navigator.pushNamed(context, '/battery');
                  },
                ),
                moreActionButton: ButtonModel(
                  action: () {},
                ),
              );
            }
            return Container();
          },
        ),
        showSteps: false,
      ),
    );
  }
}
