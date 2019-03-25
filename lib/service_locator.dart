import 'package:get_it/get_it.dart';
import 'package:my_pat/generated/i18n.dart';
import 'package:my_pat/managers/managers.dart';
import 'package:my_pat/services/services.dart';
export 'package:my_pat/managers/managers.dart';
export 'package:my_pat/services/services.dart';
export 'package:my_pat/generated/i18n.dart';

GetIt sl = new GetIt();

void setUpServiceLocator() {
  sl.registerSingleton<S>(S());
  // Services
  sl.registerSingleton<FileSystemService>(FileSystemService());
  sl.registerSingleton<BleService>(BleService());
  sl.registerSingleton<IncomingPacketHandlerService>(IncomingPacketHandlerService());
  sl.registerSingleton<DispatcherService>(DispatcherService());

  // Managers
  sl.registerSingleton<BatteryManager>(BatteryManager());
  sl.registerSingleton<SystemStateManager>(SystemStateManager());
  sl.registerSingleton<CommandTaskerManager>(CommandTaskerManager());

  sl.registerSingleton<BleManager>(BleManager());
  sl.registerSingleton<PinManager>(PinManager());
  sl.registerSingleton<WelcomeActivityManager>(WelcomeActivityManager());
  sl.registerSingleton<DeviceConfigManager>(DeviceConfigManager());
}
