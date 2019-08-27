import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/services/services.dart';
import 'package:my_pat/utils/FirmwareUpgrader.dart';
import 'package:my_pat/utils/ParameterFileHandler.dart';
import 'package:my_pat/utils/log/log.dart';
export 'package:my_pat/managers/managers.dart';
export 'package:my_pat/services/services.dart';
export 'package:my_pat/generated/i18n.dart';

GetIt sl = new GetIt();

Future<void> setupServices() async {
  sl.registerSingleton<FileSystemService>(FileSystemService());
  await _initializeLogger();
  _initializeCrucialServices();
  _initializeAllServices();
}

Future <void> _initializeLogger() async {
  await Log.init();
  Log.setLevel(Level.INFO);
}

void _initializeAllServices() {
  Log.info("ServiceLocator", "Initializing all services");

  sl.registerSingleton<S>(S());

  // Services
  sl.registerSingleton<BleService>(BleService());
  sl.registerSingleton<IncomingPacketHandlerService>(IncomingPacketHandlerService());
  sl.registerSingleton<DispatcherService>(DispatcherService());
  sl.registerSingleton<UserAuthenticationService>(UserAuthenticationService());

  sl.registerSingleton<SftpService>(SftpService());
  sl.registerSingleton<DataWritingService>(DataWritingService());
//  sl.registerSingleton<NotificationsService>(NotificationsService());

  sl.registerSingleton<EmailSenderService>(EmailSenderService());

  // Managers
  sl.registerSingleton<BatteryManager>(BatteryManager());
  sl.registerSingleton<CommandTaskerManager>(CommandTaskerManager());

  sl.registerSingleton<BleManager>(BleManager());
  sl.registerSingleton<AuthenticationManager>(AuthenticationManager());
  sl.registerSingleton<WelcomeActivityManager>(WelcomeActivityManager());
  sl.registerSingleton<DeviceConfigManager>(DeviceConfigManager());

  sl.registerSingleton<CarouselManager>(CarouselManager());
  sl.registerSingleton<TestingManager>(TestingManager());
  sl.registerSingleton<ConnectionIndicatorManager>(ConnectionIndicatorManager());

  sl.registerSingleton<FirmwareUpgrader>(FirmwareUpgrader());
  sl.registerSingleton<ParameterFileHandler>(ParameterFileHandler());
  sl.registerSingleton<ServiceScreenManager>(ServiceScreenManager());
  sl.registerSingleton<BitOperationsManager>(BitOperationsManager());

  sl.registerSingleton<TransactionManager>(TransactionManager());


}

void _initializeCrucialServices() {
  sl.registerSingleton<SystemStateManager>(SystemStateManager());
}
