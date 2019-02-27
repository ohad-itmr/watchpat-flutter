import 'helpers/bloc_event_state.dart';
import 'package:meta/meta.dart';
import 'dart:async';

enum AppInitEventType {
  start,
  stop,
}

class AppInitEvent extends BlocEvent {
  final AppInitEventType type;

  AppInitEvent({
    this.type: AppInitEventType.start,
  }) : assert(type != null);
}

class AppInitState extends BlocState {
  AppInitState({
    @required this.isInitialized,
    this.isInitializing: false,
    this.progress: 0,
  });

  final bool isInitialized;
  final bool isInitializing;
  final int progress;

  factory AppInitState.notInitialized() {
    return AppInitState(
      isInitialized: false,
    );
  }

  factory AppInitState.progressing(int progress) {
    return AppInitState(
      isInitialized: progress == 100,
      isInitializing: true,
      progress: progress,
    );
  }

  factory AppInitState.initialized() {
    return AppInitState(
      isInitialized: true,
      progress: 100,
    );
  }
}

class AppInitBloc extends BlocEventStateBase<AppInitEvent, AppInitState> {
  AppInitBloc() : super(initialState: AppInitState.notInitialized());

  @override
  Stream<AppInitState> eventHandler(
    AppInitEvent event,
    AppInitState currentState,
  ) async* {
    if (!currentState.isInitialized) {
      yield AppInitState.notInitialized();
    }

    if (event.type == AppInitEventType.start) {
      for (int progress = 0; progress < 101; progress += 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        yield AppInitState.progressing(progress);
      }
    }

    if (event.type == AppInitEventType.stop) {
      yield AppInitState.initialized();
    }
  }
}
