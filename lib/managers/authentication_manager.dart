import 'package:my_pat/domain_model/device_config_payload.dart';
import 'package:my_pat/domain_model/dispatcher_response_models.dart';
import 'package:my_pat/managers/manager_base.dart';
import 'package:my_pat/service_locator.dart';
import 'package:my_pat/services/sftp_service.dart';
import 'package:rxdart/rxdart.dart';

enum PatientAuthState {
  NotStarted,
  InProgress,
  Authenticated,
  FailedTryAgain,
  FailedClose
}

class AuthenticationManager extends ManagerBase {
  static const String TAG = 'PinManager';

  String _pin = '';

  final PublishSubject<String> _inputSubject = PublishSubject<String>();
  final BehaviorSubject<PatientAuthState> _authStateSubject =
      BehaviorSubject<PatientAuthState>.seeded(PatientAuthState.NotStarted);
  final BehaviorSubject<String> _resultSubject =
      BehaviorSubject<String>.seeded('');
  final BehaviorSubject<bool> _pinIsValid = BehaviorSubject<bool>.seeded(false);

  Observable<String> get pinStream => _resultSubject.stream;

  Observable<PatientAuthState> get authStateStream => _authStateSubject.stream;

  Observable<bool> get pinIsValid => _pinIsValid.stream;

  String get pin => _pin;

  void onPinChange(int value) {
    print('onPinChange $value');
    var newPin = '';
    if (value >= 0) {
      if (_pin.length < 4) {
        newPin = _pin + '$value';
        print('onPinChange newPin $newPin');

        _inputSubject.add(newPin);
      }
    } else {
      if (_pin.length > 0) {
        newPin = _pin.substring(0, _pin.length - 1);
        print('onPinChange newPin $newPin');

        _inputSubject.add(newPin);
      }
    }
  }

  authenticatePatient() async {
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
      sl<UserAuthenticationService>().setSftpParams(data.credentials);
      _authStateSubject.add(PatientAuthState.Authenticated);
      sl<SystemStateManager>()
          .setDispatcherState(DispatcherStates.AUTHENTICATED);

      // update pin and save device config to a local file for further upload to sftp
      DeviceConfigPayload config = sl<DeviceConfigManager>().deviceConfig;
      config.updatePin(pin);
      sl<DataWritingService>().enqueueWritingToFile(config.payloadBytes);
    }
  }

  resetPin() {
    _inputSubject.add('');
    _resultSubject.add('');
  }

  AuthenticationManager() {
    _inputSubject
        .map((newVal) => _pin = '$newVal')
        .listen((value) => _resultSubject.add(value));

    _resultSubject.listen((value) => _pinIsValid.add(value.length == 4));
  }

  dispose() {
    _inputSubject.close();
    _resultSubject.close();
    _pinIsValid.close();
    _authStateSubject.close();
  }
}
