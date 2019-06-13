import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionIndicatorManager extends ManagerBase {
  SystemStateManager _systemState = sl<SystemStateManager>();

  BehaviorSubject<bool> _btLitState = BehaviorSubject<bool>();

  BehaviorSubject<bool> _sftpLitState = BehaviorSubject<bool>();

  Observable<bool> get btLitStream => _btLitState.stream;

  Observable<bool> get sftpLitStream => _sftpLitState.stream;

  Timer _btLedTimer;
  Timer _sftpLedTimer;

  bool _btLit = false;
  bool _sftpLit = false;

  ConnectionIndicatorManager() {
    Observable.combineLatest2(
      _systemState.deviceCommStateStream,
      _systemState.dataTransferStateStream,
      _handleBTState,
    ).listen(null);
    Observable.combineLatest3(
      _systemState.inetConnectionStateStream,
      sl<SftpService>().sftpConnectionStateStream,
      _systemState.sftpUploadingStateStream,
      _handleSftpTransferState,
    ).listen(null);
  }

  _setBtLedBlinking() {
    if (_btLedTimer == null) {
      _btLedTimer = Timer.periodic(Duration(milliseconds: 250), (Timer timer) {
        _btLit = !_btLit;
        _btLitState.sink.add(_btLit);
      });
    }
  }

  _setBtLedLit(bool lit) {
    if (_btLedTimer != null) {
      _btLedTimer.cancel();
      _btLedTimer = null;
    }
    _btLitState.sink.add(lit);
  }

  _setSftpLedBlinking() {
    if (_sftpLedTimer == null) {
      _sftpLedTimer =
          Timer.periodic(Duration(milliseconds: 250), (Timer timer) {
        _sftpLit = !_sftpLit;
        _sftpLitState.sink.add(_sftpLit);
      });
    }
  }

  _setSftpLedLit(bool lit) {
    if (_sftpLedTimer != null) {
      _sftpLedTimer.cancel();
      _sftpLedTimer = null;
    }
    _sftpLitState.sink.add(lit);
  }

  _handleBTState(DeviceStates btState, DataTransferState dataTransferState) {
    if (btState == DeviceStates.CONNECTED &&
        (dataTransferState == DataTransferState.TRANSFERRING)) {
      _setBtLedBlinking();
    } else if (btState == DeviceStates.CONNECTED) {
      _setBtLedLit(true);
    } else {
      _setBtLedLit(false);
    }
  }

  _handleSftpTransferState(ConnectivityResult inetState,
      SftpConnectionState sftpState, SftpUploadingState uploadingState) {
    if (inetState != ConnectivityResult.none &&
        sftpState == SftpConnectionState.CONNECTED &&
        uploadingState == SftpUploadingState.UPLOADING) {
      _setSftpLedBlinking();
    } else if (inetState != ConnectivityResult.none &&
        sftpState == SftpConnectionState.CONNECTED &&
        uploadingState == SftpUploadingState.WAITING_FOR_DATA) {
      _setSftpLedLit(true);
      _sftpLitState.sink.add(true);
    } else if (inetState != ConnectivityResult.none &&
        sftpState == SftpConnectionState.CONNECTED) {
      _setSftpLedLit(true);
    } else {
      _setSftpLedLit(false);
    }
  }

  @override
  void dispose() {
    _btLitState.close();
    _sftpLitState.close();
  }
}
