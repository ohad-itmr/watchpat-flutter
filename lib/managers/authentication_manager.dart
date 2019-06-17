import 'package:connectivity/connectivity.dart';
import 'package:my_pat/app/screens.dart';
import 'package:my_pat/domain_model/device_config_payload.dart';
import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/service_locator.dart';
import 'package:rxdart/rxdart.dart';

enum PatientAuthState {
  NotStarted,
  InProgress,
  Authenticated,
  FailedTryAgain,
  FailedClose,
  FailedNoInternet
}

class AuthenticationManager extends ManagerBase {
  static const String TAG = 'PinManager';

  String _pin = '';

  static List<int> _pinNumberList = List<int>(4);

  final PublishSubject<String> _inputSubject = PublishSubject<String>();
  final BehaviorSubject<PatientAuthState> _authStateSubject =
      BehaviorSubject<PatientAuthState>.seeded(PatientAuthState.NotStarted);
  final BehaviorSubject<List<int>> _resultSubject =
      BehaviorSubject<List<int>>.seeded(_pinNumberList);
  final BehaviorSubject<bool> _pinIsValid = BehaviorSubject<bool>.seeded(false);

  Observable<List<int>> get pinStream => _resultSubject.stream;

  Observable<PatientAuthState> get authStateStream => _authStateSubject.stream;

  Observable<bool> get pinIsValid => _pinIsValid.stream;

  String get pin => _pin;

  void onPinChange(int value) {
    if (_authStateSubject.value == PatientAuthState.FailedClose) return;
    print('onPinChange, value: $value');

    var newPin = '';
    if (value >= 0) {
      if (_pin.length < 4) {
        newPin = _pin + '$value';
        print('onPinChange newPin $newPin');

        _inputSubject.add(newPin);
      } else {
        newPin = _pin;
      }
    } else {
      if (_pin.length > 0) {
        newPin = _pin.substring(0, _pin.length - 1);
        print('onPinChange newPin $newPin');

        _inputSubject.add(newPin);
      }
    }

    for (int i = 0; i < 4; i++) {
      if (newPin.length > i) {
        final String char = newPin.substring(i, i + 1);
        _pinNumberList[i] = int.parse(char);
      } else {
        _pinNumberList[i] = null;
      }
    }
  }

  authenticatePatient() async {
    ConnectivityResult inetState =
        await sl<SystemStateManager>().inetConnectionStateStream.first;
    if (inetState == ConnectivityResult.none) {
      sl<SystemStateManager>()
          .setDispatcherState(DispatcherStates.AUTHENTICATION_FAILURE);
      _authStateSubject.add(PatientAuthState.FailedNoInternet);
      return;
    }

    _authStateSubject.add(PatientAuthState.InProgress);

    AuthenticateUserResponseModel data = await sl<DispatcherService>()
        .sendAuthenticatePatient(PrefsProvider.loadDeviceSerial(), pin);

    print('AuthenticateUserResponseModel data ${data.error}');

    if (data.error) {
      sl<SystemStateManager>()
          .setDispatcherState(DispatcherStates.AUTHENTICATION_FAILURE);
      resetPin();
      if (data.message == '1') {
        _authStateSubject.add(PatientAuthState.FailedTryAgain);
      } else {
        _authStateSubject.add(PatientAuthState.FailedClose);
      }
    } else {
      // set up sftp
      sl<UserAuthenticationService>().setSftpParams(data.credentials);
      _authStateSubject.add(PatientAuthState.Authenticated);
      sl<SystemStateManager>()
          .setDispatcherState(DispatcherStates.AUTHENTICATED);

      // disable internet warning
      internetWarningSub.cancel();

      // update pin and save device config to a local file for further upload to sftp
      DeviceConfigPayload config = sl<DeviceConfigManager>().deviceConfig;
      config.updatePin(pin);
      sl<DataWritingService>().writeToLocalFile(config.payloadBytes);
    }
  }

  resetPin() {
    _pinNumberList = [null, null, null, null];
    _inputSubject.add('');
  }

  AuthenticationManager() {
    _inputSubject
        .map((newVal) => _pin = '$newVal')
        .listen((value) => _resultSubject.add(_pinNumberList));

    _resultSubject.listen(
        (value) => _pinIsValid.add(value.where((n) => n != null).length == 4));
  }

  dispose() {
    _inputSubject.close();
    _resultSubject.close();
    _pinIsValid.close();
    _authStateSubject.close();
  }
}
