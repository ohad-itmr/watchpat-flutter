// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S();
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  String get acc_registers_description {
    return Intl.message(
      'ACC registers',
      name: 'acc_registers_description',
      desc: '',
      args: [],
    );
  }

  String get afe_registers_description {
    return Intl.message(
      'AFE registers',
      name: 'afe_registers_description',
      desc: '',
      args: [],
    );
  }

  String get all_data_transmitted_successfully {
    return Intl.message(
      'All data transmitted successfully',
      name: 'all_data_transmitted_successfully',
      desc: '',
      args: [],
    );
  }

  String get auth_fail {
    return Intl.message(
      'Authentication failed',
      name: 'auth_fail',
      desc: '',
      args: [],
    );
  }

  String get batteryTitle {
    return Intl.message(
      'INSERT BATTERY ',
      name: 'batteryTitle',
      desc: '',
      args: [],
    );
  }

  String get batteryContent_1 {
    return Intl.message(
      'Open the battery compartment\'s cover, located on the back of the WatchPAT™ONE, and insert the battery. \nThe flat side of the battery faces the MINUS sign.',
      name: 'batteryContent_1',
      desc: '',
      args: [],
    );
  }

  String get batteryContent_2 {
    return Intl.message(
      'The flat side of the battery faces the MINUS sign.',
      name: 'batteryContent_2',
      desc: '',
      args: [],
    );
  }

  String get batteryContent_success {
    return Intl.message(
      'WatchPAT™ONE connected successfully. Press \'NEXT\' to continue.',
      name: 'batteryContent_success',
      desc: '',
      args: [],
    );
  }

  String get batteryContent_many_1 {
    return Intl.message(
      'Multiple devices are identified in this surrounding.\nPlease remove the battery from all irrelevant devices and try again.',
      name: 'batteryContent_many_1',
      desc: '',
      args: [],
    );
  }

  String get insert_battery_desc1 {
    return Intl.message(
      'Open the battery compartment\'s cover, located on the back of the WatchPAT™ONE, and insert the provided battery',
      name: 'insert_battery_desc1',
      desc: '',
      args: [],
    );
  }

  String get batteryContent_many_2 {
    return Intl.message(
      'Remove the battery from non-used WatchPAT™ ONE in the surrounding.',
      name: 'batteryContent_many_2',
      desc: '',
      args: [],
    );
  }

  String get btnCloseApp {
    return Intl.message(
      'CLOSE APP',
      name: 'btnCloseApp',
      desc: '',
      args: [],
    );
  }

  String get btnChangeAndRestart {
    return Intl.message(
      'Change and exit app',
      name: 'btnChangeAndRestart',
      desc: '',
      args: [],
    );
  }

  String get btnEndRecording {
    return Intl.message(
      'END RECORDING',
      name: 'btnEndRecording',
      desc: '',
      args: [],
    );
  }

  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  String get select_language {
    return Intl.message(
      'Select language',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  String get french {
    return Intl.message(
      'French',
      name: 'french',
      desc: '',
      args: [],
    );
  }

  String get german {
    return Intl.message(
      'German',
      name: 'german',
      desc: '',
      args: [],
    );
  }

  String get italian {
    return Intl.message(
      'Italian',
      name: 'italian',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      'CANCEL',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get btnEnter {
    return Intl.message(
      'ENTER',
      name: 'btnEnter',
      desc: '',
      args: [],
    );
  }

  String get btnMore {
    return Intl.message(
      'MORE',
      name: 'btnMore',
      desc: '',
      args: [],
    );
  }

  String get btnNext {
    return Intl.message(
      'NEXT',
      name: 'btnNext',
      desc: '',
      args: [],
    );
  }

  String get btnFinish {
    return Intl.message(
      'Finish',
      name: 'btnFinish',
      desc: '',
      args: [],
    );
  }

  String get btnPrevious {
    return Intl.message(
      'PREVIOUS',
      name: 'btnPrevious',
      desc: '',
      args: [],
    );
  }

  String get btnPreview {
    return Intl.message(
      'PREVIEW',
      name: 'btnPreview',
      desc: '',
      args: [],
    );
  }

  String get btnReady {
    return Intl.message(
      'READY',
      name: 'btnReady',
      desc: '',
      args: [],
    );
  }

  String get btnReturnToApp {
    return Intl.message(
      'Return To App',
      name: 'btnReturnToApp',
      desc: '',
      args: [],
    );
  }

  String get btnStartRecording {
    return Intl.message(
      'START',
      name: 'btnStartRecording',
      desc: '',
      args: [],
    );
  }

  String get bt_initiation_error {
    return Intl.message(
      'Bluetooth initiation error',
      name: 'bt_initiation_error',
      desc: '',
      args: [],
    );
  }

  String get inet_initiation_error {
    return Intl.message(
      'Internet initiation error',
      name: 'inet_initiation_error',
      desc: '',
      args: [],
    );
  }

  String get bt_must_be_enabled {
    return Intl.message(
      'Bluetooth must be enabled for the test procedure.\nPlease activate bluetooth in Control Center.',
      name: 'bt_must_be_enabled',
      desc: '',
      args: [],
    );
  }

  String get bt_not_available_shutdown {
    return Intl.message(
      'Bluetooth is not available on this device',
      name: 'bt_not_available_shutdown',
      desc: '',
      args: [],
    );
  }

  String get chestSensorTitle {
    return Intl.message(
      'Attach Chest Sensor',
      name: 'chestSensorTitle',
      desc: '',
      args: [],
    );
  }

  String get chestSensorContent {
    return Intl.message(
      'If you wear a shirt at night, feed the chest sensor through your sleeve and up to the neck opening. Peel the white paper from the back of the sensor. Attach the sensor to the center of your upper chest bone, just under the sternal notch.',
      name: 'chestSensorContent',
      desc: '',
      args: [],
    );
  }

  String get close_app {
    return Intl.message(
      'CLOSE APP',
      name: 'close_app',
      desc: '',
      args: [],
    );
  }

  String get close_mypat_app_q {
    return Intl.message(
      'Close WatchPAT™ Application?',
      name: 'close_mypat_app_q',
      desc: '',
      args: [],
    );
  }

  String get connected {
    return Intl.message(
      'Connected',
      name: 'connected',
      desc: '',
      args: [],
    );
  }

  String get connect_to_charger {
    return Intl.message(
      'Connect the phone to a charger',
      name: 'connect_to_charger',
      desc: '',
      args: [],
    );
  }

  String get connected_to_device {
    return Intl.message(
      'Connected to device',
      name: 'connected_to_device',
      desc: '',
      args: [],
    );
  }

  String get connecting_to_device {
    return Intl.message(
      'Connecting to a device',
      name: 'connecting_to_device',
      desc: '',
      args: [],
    );
  }

  String get connection_to_main_device_lost {
    return Intl.message(
      'Connection to Main Device is lost',
      name: 'connection_to_main_device_lost',
      desc: '',
      args: [],
    );
  }

  String get connected_to_used_device {
    return Intl.message(
      'Connected to a used device',
      name: 'connected_to_used_device',
      desc: '',
      args: [],
    );
  }

  String get critical_hw_failure {
    return Intl.message(
      'Critical hardware failure',
      name: 'critical_hw_failure',
      desc: '',
      args: [],
    );
  }

  String get customer_service_mode {
    return Intl.message(
      'Customer service mode',
      name: 'customer_service_mode',
      desc: '',
      args: [],
    );
  }

  String get device_log_file_description {
    return Intl.message(
      'Device log file',
      name: 'device_log_file_description',
      desc: '',
      args: [],
    );
  }

  String get device_not_found {
    return Intl.message(
      'Device is not found',
      name: 'device_not_found',
      desc: '',
      args: [],
    );
  }

  String get device_sn {
    return Intl.message(
      'Device serial number \$sn',
      name: 'device_sn',
      desc: '',
      args: [],
    );
  }

  String get device_ver_name {
    return Intl.message(
      'DeviceFWVersion',
      name: 'device_ver_name',
      desc: '',
      args: [],
    );
  }

  String get digits {
    return Intl.message(
      'digits',
      name: 'digits',
      desc: '',
      args: [],
    );
  }

  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  String get disconnect_all_irr_devices {
    return Intl.message(
      'Disconnect all irrelevant devices',
      name: 'disconnect_all_irr_devices',
      desc: '',
      args: [],
    );
  }

  String get enter_id {
    return Intl.message(
      'ID:',
      name: 'enter_id',
      desc: '',
      args: [],
    );
  }

  String get enter_new_serial {
    return Intl.message(
      'Enter device’s new serial number',
      name: 'enter_new_serial',
      desc: '',
      args: [],
    );
  }

  String get err_actigraph_test {
    return Intl.message(
      'Actigraph test',
      name: 'err_actigraph_test',
      desc: '',
      args: [],
    );
  }

  String get err_battery_low {
    return Intl.message(
      'Battery low voltage',
      name: 'err_battery_low',
      desc: '',
      args: [],
    );
  }

  String get err_flash_test {
    return Intl.message(
      'Flash test',
      name: 'err_flash_test',
      desc: '',
      args: [],
    );
  }

  String get err_probe_leds {
    return Intl.message(
      'Probe LEDs',
      name: 'err_probe_leds',
      desc: '',
      args: [],
    );
  }

  String get err_probe_photo {
    return Intl.message(
      'Probe photo',
      name: 'err_probe_photo',
      desc: '',
      args: [],
    );
  }

  String get err_sbp {
    return Intl.message(
      'SBP',
      name: 'err_sbp',
      desc: '',
      args: [],
    );
  }

  String get err_used_device {
    return Intl.message(
      'Used main device',
      name: 'err_used_device',
      desc: '',
      args: [],
    );
  }

  String get error_state {
    return Intl.message(
      'ERROR STATE',
      name: 'error_state',
      desc: '',
      args: [],
    );
  }

  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  String get exit_service_mode {
    return Intl.message(
      'Exit service mode',
      name: 'exit_service_mode',
      desc: '',
      args: [],
    );
  }

  String get fingerProbeTitle {
    return Intl.message(
      ' ATTACH FINGER PROBE',
      name: 'fingerProbeTitle',
      desc: '',
      args: [],
    );
  }

  String get fingerProbeContent {
    return Intl.message(
      'Insert any finger of your non-dominant hand, except your thumb, all the way into the probe. The sticker marked TOP should be on the top of your finger. Hold the probe against a hard surface (such as a table) and pull the TOP tab toward you to remove it from the probe.',
      name: 'fingerProbeContent',
      desc: '',
      args: [],
    );
  }

  String get finger_not_detected {
    return Intl.message(
      'Finger not detected alert',
      name: 'finger_not_detected',
      desc: '',
      args: [],
    );
  }

  String get firmware_alert_title {
    return Intl.message(
      'Device firmware upgrade',
      name: 'firmware_alert_title',
      desc: '',
      args: [],
    );
  }

  String get flash_full {
    return Intl.message(
      'Device flash is full',
      name: 'flash_full',
      desc: '',
      args: [],
    );
  }

  String get fw_check_version {
    return Intl.message(
      'Please wait while we check device firmware version',
      name: 'fw_check_version',
      desc: '',
      args: [],
    );
  }

  String get fw_connection_failed {
    return Intl.message(
      'Connection with device failed. Test will be terminated.\n\nPlease contact Itamar Medical support.',
      name: 'fw_connection_failed',
      desc: '',
      args: [],
    );
  }

  String get fw_need_upgrade {
    return Intl.message(
      'Device’s new firmware version is available. It will not take long.\n\nPlease wait while we upgrade it&#8230;',
      name: 'fw_need_upgrade',
      desc: '',
      args: [],
    );
  }

  String get fw_upgrade_failed {
    return Intl.message(
      'Device firmware upgrade failed.\n\nPlease contact Itamar Medical support.',
      name: 'fw_upgrade_failed',
      desc: '',
      args: [],
    );
  }

  String get fw_upgrade_succeed {
    return Intl.message(
      'Device firmware upgraded successfully',
      name: 'fw_upgrade_succeed',
      desc: '',
      args: [],
    );
  }

  String get green {
    return Intl.message(
      'green',
      name: 'green',
      desc: '',
      args: [],
    );
  }

  String get id_in {
    return Intl.message(
      'ID in',
      name: 'id_in',
      desc: '',
      args: [],
    );
  }

  String get incorrect_pin {
    return Intl.message(
      'Incorrect PIN, please try again',
      name: 'incorrect_pin',
      desc: '',
      args: [],
    );
  }

  String get invalid_id {
    return Intl.message(
      'Invalid ID',
      name: 'invalid_id',
      desc: '',
      args: [],
    );
  }

  String get invalid_technician_password {
    return Intl.message(
      'Invalid technician password',
      name: 'invalid_technician_password',
      desc: '',
      args: [],
    );
  }

  String get inet_unavailable {
    return Intl.message(
      'Internet access unavailable',
      name: 'inet_unavailable',
      desc: '',
      args: [],
    );
  }

  String get insufficient_storage_space_on_smartphone {
    return Intl.message(
      'Insufficient free memory on your phone',
      name: 'insufficient_storage_space_on_smartphone',
      desc: '',
      args: [],
    );
  }

  String get files_creating_failed {
    return Intl.message(
      'Failed to create initial files',
      name: 'files_creating_failed',
      desc: '',
      args: [],
    );
  }

  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  String get log_email_subject {
    return Intl.message(
      'WatchPAT™ device log file',
      name: 'log_email_subject',
      desc: '',
      args: [],
    );
  }

  String get app_log_file_title {
    return Intl.message(
      'Application log file',
      name: 'app_log_file_title',
      desc: '',
      args: [],
    );
  }

  String get app_log_file_text {
    return Intl.message(
      'Are you sure you want to send application log file to',
      name: 'app_log_file_text',
      desc: '',
      args: [],
    );
  }

  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  String get low_power {
    return Intl.message(
      'Low power alert',
      name: 'low_power',
      desc: '',
      args: [],
    );
  }

  String get myPAT_connect_to_server_fail {
    return Intl.message(
      'WatchPAT™ connection to SFTP server failure',
      name: 'myPAT_connect_to_server_fail',
      desc: '',
      args: [],
    );
  }

  String get mypat_device {
    return Intl.message(
      'WatchPAT™ Device',
      name: 'mypat_device',
      desc: '',
      args: [],
    );
  }

  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  String get no_inet_connection {
    return Intl.message(
      'Internet must be enabled to start test procedure.\nPlease turn Internet ON.',
      name: 'no_inet_connection',
      desc: '',
      args: [],
    );
  }

  String get parameters_file_title {
    return Intl.message(
      'Parameters file',
      name: 'parameters_file_title',
      desc: '',
      args: [],
    );
  }

  String get getting_param_file {
    return Intl.message(
      'Getting parameter file',
      name: 'getting_param_file',
      desc: '',
      args: [],
    );
  }

  String get get {
    return Intl.message(
      'get',
      name: 'get',
      desc: '',
      args: [],
    );
  }

  String get set {
    return Intl.message(
      'set',
      name: 'set',
      desc: '',
      args: [],
    );
  }

  String get set_and_close {
    return Intl.message(
      'Set and close',
      name: 'set_and_close',
      desc: '',
      args: [],
    );
  }

  String get parameters_file_written_successfully {
    return Intl.message(
      'Parameters file written successfully',
      name: 'parameters_file_written_successfully',
      desc: '',
      args: [],
    );
  }

  String get parameters_file_write_failed {
    return Intl.message(
      'Parameters file write failed',
      name: 'parameters_file_write_failed',
      desc: '',
      args: [],
    );
  }

  String get parameters_file_description {
    return Intl.message(
      'Parameters file',
      name: 'parameters_file_description',
      desc: '',
      args: [],
    );
  }

  String get getting_param_file_success {
    return Intl.message(
      'Getting parameter file: success',
      name: 'getting_param_file_success',
      desc: '',
      args: [],
    );
  }

  String get getting_param_file_fail {
    return Intl.message(
      'Getting parameter file: failed',
      name: 'getting_param_file_fail',
      desc: '',
      args: [],
    );
  }

  String get not_enough_test_data {
    return Intl.message(
      'The Application has not collected enough test data. You can stop test in:',
      name: 'not_enough_test_data',
      desc: '',
      args: [],
    );
  }

  String get patient_msg1 {
    return Intl.message(
      'Please plug your phone into a charger. Leave the charger plugged in during the entire test procedure. Close unused phone applications before starting test procedure. \n\nPlease don\'t close the WatchPAT™ONE application during the test procedure.',
      name: 'patient_msg1',
      desc: '',
      args: [],
    );
  }

  String get patient_msg2 {
    return Intl.message(
      'Please don\'t close WatchPAT™ application during test procedure',
      name: 'patient_msg2',
      desc: '',
      args: [],
    );
  }

  String get pinTitle {
    return Intl.message(
      'Enter PIN',
      name: 'pinTitle',
      desc: '',
      args: [],
    );
  }

  String pinContent(Object pin) {
    return Intl.message(
      'Enter your assigned four digits PIN ($pin) and tap ENTER',
      name: 'pinContent',
      desc: '',
      args: [pin],
    );
  }

  String get please_insert_finger {
    return Intl.message(
      'Please insert the finger and press OK',
      name: 'please_insert_finger',
      desc: '',
      args: [],
    );
  }

  String get please_plug_charger {
    return Intl.message(
      'Please plug in a charger',
      name: 'please_plug_charger',
      desc: '',
      args: [],
    );
  }

  String get please_replace_battery {
    return Intl.message(
      'Please replace the battery in the device',
      name: 'please_replace_battery',
      desc: '',
      args: [],
    );
  }

  String get pleaseWait {
    return Intl.message(
      'Please Wait',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  String get product_reuse {
    return Intl.message(
      'Product reuse attempt',
      name: 'product_reuse',
      desc: '',
      args: [],
    );
  }

  String get ready {
    return Intl.message(
      'READY',
      name: 'ready',
      desc: '',
      args: [],
    );
  }

  String get recordingTitle {
    return Intl.message(
      'GOOD NIGHT',
      name: 'recordingTitle',
      desc: '',
      args: [],
    );
  }

  String get red {
    return Intl.message(
      'Red',
      name: 'red',
      desc: '',
      args: [],
    );
  }

  String get remote_server {
    return Intl.message(
      'Remote Server',
      name: 'remote_server',
      desc: '',
      args: [],
    );
  }

  String get removeJewelryTitle {
    return Intl.message(
      'PREPARATION',
      name: 'removeJewelryTitle',
      desc: '',
      args: [],
    );
  }

  String get removeJewelryContent {
    return Intl.message(
      'Remove tight clothing, watches and jewelry.\nEnsure that the fingernail on the non-dominant hand is trimmed.\nRemove artificial nail or colored nail polish from the monitored finger.\nUse the MORE button to see more details.',
      name: 'removeJewelryContent',
      desc: '',
      args: [],
    );
  }

  String get scanning_device {
    return Intl.message(
      'Scanning for device',
      name: 'scanning_device',
      desc: '',
      args: [],
    );
  }

  String get scan_again {
    return Intl.message(
      'Scan again',
      name: 'scan_again',
      desc: '',
      args: [],
    );
  }

  String get firmware_version {
    return Intl.message(
      'Firmware version',
      name: 'firmware_version',
      desc: '',
      args: [],
    );
  }

  String get select_bit_type {
    return Intl.message(
      'Select BIT mode',
      name: 'select_bit_type',
      desc: '',
      args: [],
    );
  }

  String get retrieve_stored_data {
    return Intl.message(
      'Retrieve stored data',
      name: 'retrieve_stored_data',
      desc: '',
      args: [],
    );
  }

  String get retrieve_stored_data_from_device {
    return Intl.message(
      'Retrieve stored data from the device?',
      name: 'retrieve_stored_data_from_device',
      desc: '',
      args: [],
    );
  }

  String get retrieving_stored_test_data {
    return Intl.message(
      'Retrieving stored test data',
      name: 'retrieving_stored_test_data',
      desc: '',
      args: [],
    );
  }

  String get retrieve_stored_test_data_failed {
    return Intl.message(
      'Retrieve stored test data failed',
      name: 'retrieve_stored_test_data_failed',
      desc: '',
      args: [],
    );
  }

  String get server_comm_error {
    return Intl.message(
      'Server communication error, please contact support',
      name: 'server_comm_error',
      desc: '',
      args: [],
    );
  }

  String get sftp_server_no_access {
    return Intl.message(
      'SFTP Server is not accessible. Error code returned',
      name: 'sftp_server_no_access',
      desc: '',
      args: [],
    );
  }

  String get startRecordingTitle {
    return Intl.message(
      'START RECORDING',
      name: 'startRecordingTitle',
      desc: '',
      args: [],
    );
  }

  String get startRecordingContent {
    return Intl.message(
      'Once the WatchPAT™ONE has been properly put on, it is ready to start recording. Press the START button and have a good night sleep. \n\nIf you need to get up during the night, do not remove the device or sensors. Leave the phone behind, connected to the charger.',
      name: 'startRecordingContent',
      desc: '',
      args: [],
    );
  }

  String get start_test {
    return Intl.message(
      'START TEST',
      name: 'start_test',
      desc: '',
      args: [],
    );
  }

  String get status {
    return Intl.message(
      'Status: \$status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  String get stepperOf {
    return Intl.message(
      'of',
      name: 'stepperOf',
      desc: '',
      args: [],
    );
  }

  String get stepperStep {
    return Intl.message(
      'Step',
      name: 'stepperStep',
      desc: '',
      args: [],
    );
  }

  String stepper(Object step, Object total) {
    return Intl.message(
      'Step $step of $total',
      name: 'stepper',
      desc: '',
      args: [step, total],
    );
  }

  String get stop_test {
    return Intl.message(
      'STOP TEST',
      name: 'stop_test',
      desc: '',
      args: [],
    );
  }

  String get confirm_stop_test {
    return Intl.message(
      'Are you sure you want to end recording?',
      name: 'confirm_stop_test',
      desc: '',
      args: [],
    );
  }

  String get strapWristTitle {
    return Intl.message(
      'ATTACH WRIST DEVICE',
      name: 'strapWristTitle',
      desc: '',
      args: [],
    );
  }

  String get strapWristContent {
    return Intl.message(
      'Attach the WatchPAT™ONE on your non-dominant hand. \nSecure the WatchPAT™ONE to your wrist ensuring it is snug but not too tight.',
      name: 'strapWristContent',
      desc: '',
      args: [],
    );
  }

  String get technician_mode {
    return Intl.message(
      'Technician mode',
      name: 'technician_mode',
      desc: '',
      args: [],
    );
  }

  String get test_data_transmit_in_progress {
    return Intl.message(
      'Test data transmit in progress',
      name: 'test_data_transmit_in_progress',
      desc: '',
      args: [],
    );
  }

  String get test_data_still_transmitting_close_anyway {
    return Intl.message(
      'Test data still transmitting Please don\'t close WatchPAT™ application  Close anyway?',
      name: 'test_data_still_transmitting_close_anyway',
      desc: '',
      args: [],
    );
  }

  String get test_in_progress {
    return Intl.message(
      'Test in progress',
      name: 'test_in_progress',
      desc: '',
      args: [],
    );
  }

  String get test_length {
    return Intl.message(
      'Test Time: \$time',
      name: 'test_length',
      desc: '',
      args: [],
    );
  }

  String get test_status {
    return Intl.message(
      'Test Status: \$status',
      name: 'test_status',
      desc: '',
      args: [],
    );
  }

  String get thankYouTitle {
    return Intl.message(
      'THANK YOU',
      name: 'thankYouTitle',
      desc: '',
      args: [],
    );
  }

  String get thankYouContent {
    return Intl.message(
      'Congratulations, your study has been successfully uploaded to your doctor.\nPlease dispose of the product according to local regulations.',
      name: 'thankYouContent',
      desc: '',
      args: [],
    );
  }

  String get thankYouStillUploading {
    return Intl.message(
      'Your study is still uploading to your doctor.\nPlease don\'t close the application and leave the display ON until all the data is uploaded.\n\nUploading progress: ',
      name: 'thankYouStillUploading',
      desc: '',
      args: [],
    );
  }

  String get thankYouNoInet {
    return Intl.message(
      'Your study currently can\'t be uploaded to your doctor because of internet connection is unavailable.\nPlease make sure you have active internet connection and open application to finish uploading.',
      name: 'thankYouNoInet',
      desc: '',
      args: [],
    );
  }

  String get title_led_color_alert {
    return Intl.message(
      'Choose LED color',
      name: 'title_led_color_alert',
      desc: '',
      args: [],
    );
  }

  String get select_dispatcher_title {
    return Intl.message(
      'Choose dispatcher URL',
      name: 'select_dispatcher_title',
      desc: '',
      args: [],
    );
  }

  String get select_dispatcher_text {
    return Intl.message(
      'You will need to start the application again',
      name: 'select_dispatcher_text',
      desc: '',
      args: [],
    );
  }

  String get unknown_error {
    return Intl.message(
      'Unknown error occurred during the authentication, please contact support',
      name: 'unknown_error',
      desc: '',
      args: [],
    );
  }

  String get uploadingTitle {
    return Intl.message(
      'GOOD MORNING',
      name: 'uploadingTitle',
      desc: '',
      args: [],
    );
  }

  String get attention {
    return Intl.message(
      'ATTENTION',
      name: 'attention',
      desc: '',
      args: [],
    );
  }

  String get uploadingContent {
    return Intl.message(
      'Please do not close the application while the data is being uploaded.\nThe data transmission will be over in several minutes.',
      name: 'uploadingContent',
      desc: '',
      args: [],
    );
  }

  String get uploadingDeviceDisconnected {
    return Intl.message(
      'The WatchPAT™ device cannot be communicated. Please bring it closer to the Application.',
      name: 'uploadingDeviceDisconnected',
      desc: '',
      args: [],
    );
  }

  String get used_device_please_replace {
    return Intl.message(
      'This device is already used, please replace it and relaunch application',
      name: 'used_device_please_replace',
      desc: '',
      args: [],
    );
  }

  String get user_mode {
    return Intl.message(
      'User mode',
      name: 'user_mode',
      desc: '',
      args: [],
    );
  }

  String get welcomeTitle {
    return Intl.message(
      'WELCOME',
      name: 'welcomeTitle',
      desc: '',
      args: [],
    );
  }

  String get welcome_to_mypat {
    return Intl.message(
      'Welcome to WatchPAT™',
      name: 'welcome_to_mypat',
      desc: '',
      args: [],
    );
  }

  String get welcomeContent {
    return Intl.message(
      'Welcome to WatchPAT™ONE. This application sends your sleep data to your doctor. First we need to do a few things to ensure everything is set up properly. \nPlease turn off all other electronic devices in the room (i.e. smart watch, smart phones, headphones) , as it may interfere with the test. \nIf you wish to start the setup right away, hit the READY button. The PREVIEW button will take you on a quick tour through the setup.',
      name: 'welcomeContent',
      desc: '',
      args: [],
    );
  }

  String get for_help_video {
    return Intl.message(
      'For help video press this link',
      name: 'for_help_video',
      desc: '',
      args: [],
    );
  }

  String get instructions_video {
    return Intl.message(
      'Instructions video',
      name: 'instructions_video',
      desc: '',
      args: [],
    );
  }

  String get fatal_error {
    return Intl.message(
      'Fatal error',
      name: 'fatal_error',
      desc: '',
      args: [],
    );
  }

  String get device_connection_failed {
    return Intl.message(
      'Connection with the device failed. \n\nPlease contact Itamar Medical support for assistance.',
      name: 'device_connection_failed',
      desc: '',
      args: [],
    );
  }

  String get device_not_located {
    return Intl.message(
      'Device is not located. Please check if WatchPAT™ ONE LED blinks. If it does, place your phone closer to the device. If not, verify that you placed a new battery and check it is properly positioned.',
      name: 'device_not_located',
      desc: '',
      args: [],
    );
  }

  String get writing_param_file {
    return Intl.message(
      'Writing parameter file',
      name: 'writing_param_file',
      desc: '',
      args: [],
    );
  }

  String get param_file_written_successfully {
    return Intl.message(
      'Parameter file written successfully',
      name: 'param_file_written_successfully',
      desc: '',
      args: [],
    );
  }

  String get upgrade_file_ver_name {
    return Intl.message(
      'UpgradeFileVersion',
      name: 'upgrade_file_ver_name',
      desc: '',
      args: [],
    );
  }

  String get afe_registers_get_success {
    return Intl.message(
      'AFE registers retrieved successfully',
      name: 'afe_registers_get_success',
      desc: '',
      args: [],
    );
  }

  String get afe_registers_get_fail {
    return Intl.message(
      'AFE registers retrieve failed',
      name: 'afe_registers_get_fail',
      desc: '',
      args: [],
    );
  }

  String get afe_registers_written_successfully {
    return Intl.message(
      'AFE registers written successfully',
      name: 'afe_registers_written_successfully',
      desc: '',
      args: [],
    );
  }

  String get afe_registers_write_failed {
    return Intl.message(
      'AFE registers write failed',
      name: 'afe_registers_write_failed',
      desc: '',
      args: [],
    );
  }

  String get acc_registers {
    return Intl.message(
      'ACC registers',
      name: 'acc_registers',
      desc: '',
      args: [],
    );
  }

  String get acc_registers_get_success {
    return Intl.message(
      'ACC registers retrieved successfully',
      name: 'acc_registers_get_success',
      desc: '',
      args: [],
    );
  }

  String get acc_registers_get_fail {
    return Intl.message(
      'ACC registers retrieve failed',
      name: 'acc_registers_get_fail',
      desc: '',
      args: [],
    );
  }

  String get acc_registers_written_successfully {
    return Intl.message(
      'ACC registers written successfully',
      name: 'acc_registers_written_successfully',
      desc: '',
      args: [],
    );
  }

  String get acc_registers_write_failed {
    return Intl.message(
      'ACC registers write failed',
      name: 'acc_registers_write_failed',
      desc: '',
      args: [],
    );
  }

  String get upat_eeprom {
    return Intl.message(
      'UPAT EEPROM',
      name: 'upat_eeprom',
      desc: '',
      args: [],
    );
  }

  String get eeprom_get_success {
    return Intl.message(
      'EEPROM data retrieved successfully',
      name: 'eeprom_get_success',
      desc: '',
      args: [],
    );
  }

  String get eeprom_get_fail {
    return Intl.message(
      'EEPROM data retrieve failed',
      name: 'eeprom_get_fail',
      desc: '',
      args: [],
    );
  }

  String get eeprom_written_successfully {
    return Intl.message(
      'Device EEPROM written successfully',
      name: 'eeprom_written_successfully',
      desc: '',
      args: [],
    );
  }

  String get eeprom_write_failed {
    return Intl.message(
      'Device EEPROM write failed',
      name: 'eeprom_write_failed',
      desc: '',
      args: [],
    );
  }

  String get set_serial {
    return Intl.message(
      'Set device serial',
      name: 'set_serial',
      desc: '',
      args: [],
    );
  }

  String get set_device_serial_success {
    return Intl.message(
      'Set device serial: success',
      name: 'set_device_serial_success',
      desc: '',
      args: [],
    );
  }

  String get set_device_serial_timeout {
    return Intl.message(
      'Set device serial: timeout',
      name: 'set_device_serial_timeout',
      desc: '',
      args: [],
    );
  }

  String get select_led_color {
    return Intl.message(
      'Select LED color',
      name: 'select_led_color',
      desc: '',
      args: [],
    );
  }

  String get set_led_color_success {
    return Intl.message(
      'Set LED color: success',
      name: 'set_led_color_success',
      desc: '',
      args: [],
    );
  }

  String get set_led_color_timeout {
    return Intl.message(
      'Set LED color: timeout',
      name: 'set_led_color_timeout',
      desc: '',
      args: [],
    );
  }

  String get requesting_technical_status {
    return Intl.message(
      'Requesting technical status',
      name: 'requesting_technical_status',
      desc: '',
      args: [],
    );
  }

  String get get_tech_status_timeout {
    return Intl.message(
      'Get tech status: timeout',
      name: 'get_tech_status_timeout',
      desc: '',
      args: [],
    );
  }

  String get battery_voltage {
    return Intl.message(
      'Battery voltage: ',
      name: 'battery_voltage',
      desc: '',
      args: [],
    );
  }

  String get battery_depleted {
    return Intl.message(
      'The device\'s battery is depleted or damaged. Please replace battery and try again',
      name: 'battery_depleted',
      desc: '',
      args: [],
    );
  }

  String get vdd_voltage {
    return Intl.message(
      'VDD voltage: ',
      name: 'vdd_voltage',
      desc: '',
      args: [],
    );
  }

  String get ir_led_status {
    return Intl.message(
      'IR LED status: ',
      name: 'ir_led_status',
      desc: '',
      args: [],
    );
  }

  String get red_led_status {
    return Intl.message(
      'Red LED status: ',
      name: 'red_led_status',
      desc: '',
      args: [],
    );
  }

  String get pat_led_status {
    return Intl.message(
      'PAT LED status: ',
      name: 'pat_led_status',
      desc: '',
      args: [],
    );
  }

  String get getting_log_file {
    return Intl.message(
      'Getting device log file',
      name: 'getting_log_file',
      desc: '',
      args: [],
    );
  }

  String get getting_log_file_fail {
    return Intl.message(
      'Getting device log file failed',
      name: 'getting_log_file_fail',
      desc: '',
      args: [],
    );
  }

  String get getting_log_file_success {
    return Intl.message(
      'Getting device log file success',
      name: 'getting_log_file_success',
      desc: '',
      args: [],
    );
  }

  String get select_reset_type {
    return Intl.message(
      'Select reset type',
      name: 'select_reset_type',
      desc: '',
      args: [],
    );
  }

  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  String get ignore_device_errors {
    return Intl.message(
      'Ignore all device generated errors?',
      name: 'ignore_device_errors',
      desc: '',
      args: [],
    );
  }

  String get make_sure_watchpat_bin_is_placed_in_watchpat_dir {
    return Intl.message(
      'Make sure watchpat.bin is placed to internal directory',
      name: 'make_sure_watchpat_bin_is_placed_in_watchpat_dir',
      desc: '',
      args: [],
    );
  }

  String get upgrade {
    return Intl.message(
      'Upgrade',
      name: 'upgrade',
      desc: '',
      args: [],
    );
  }

  String get firmware_upgrading {
    return Intl.message(
      'Upgrading main device firmware, please don\'t close the application',
      name: 'firmware_upgrading',
      desc: '',
      args: [],
    );
  }

  String get firmware_upgrade_success {
    return Intl.message(
      'Firmware update completed successfully',
      name: 'firmware_upgrade_success',
      desc: '',
      args: [],
    );
  }

  String get firmware_upgrade_failed {
    return Intl.message(
      'Firmware update failed',
      name: 'firmware_upgrade_failed',
      desc: '',
      args: [],
    );
  }

  String get reset_application_title {
    return Intl.message(
      'Reset application',
      name: 'reset_application_title',
      desc: '',
      args: [],
    );
  }

  String get reset_application_prompt {
    return Intl.message(
      'Are you sure you want to delete all application stored preferences and files? You will need to launch application again.',
      name: 'reset_application_prompt',
      desc: '',
      args: [],
    );
  }

  String get reset_main_device {
    return Intl.message(
      'Resetting main device',
      name: 'reset_main_device',
      desc: '',
      args: [],
    );
  }

  String get test_is_complete {
    return Intl.message(
      'Application was successfully used to perform the test. Please reset application to use it again.',
      name: 'test_is_complete',
      desc: '',
      args: [],
    );
  }

  String get battery_level_error {
    return Intl.message(
      'Your phone isn\'t connected to a charger. Please connect a charger to start test.',
      name: 'battery_level_error',
      desc: '',
      args: [],
    );
  }

  String get test_data_from_previous_session_still_uploading {
    return Intl.message(
      'Test data from previous session still uploading to server',
      name: 'test_data_from_previous_session_still_uploading',
      desc: '',
      args: [],
    );
  }

  String get device_is_paired_error {
    return Intl.message(
      'Device was already paired, please reset device and start the process again',
      name: 'device_is_paired_error',
      desc: '',
      args: [],
    );
  }

  String get elapsed_time {
    return Intl.message(
      'Elapsed time',
      name: 'elapsed_time',
      desc: '',
      args: [],
    );
  }

  String get device_is_not_paired_error {
    return Intl.message(
      'Main device pairing error. Please reset device and try again.',
      name: 'device_is_not_paired_error',
      desc: '',
      args: [],
    );
  }

  String get pin_number_assigned_to_you {
    return Intl.message(
      'The PIN number assigned to you can be \$pin. If you are not sure, you will have to call doctor\'s office.',
      name: 'pin_number_assigned_to_you',
      desc: '',
      args: [],
    );
  }

  String get pin_type_pn {
    return Intl.message(
      'that was provided to you by the doctor’s staff',
      name: 'pin_type_pn',
      desc: '',
      args: [],
    );
  }

  String get pin_type_ss {
    return Intl.message(
      'last digits of your Social Security number',
      name: 'pin_type_ss',
      desc: '',
      args: [],
    );
  }

  String get pin_type_cc {
    return Intl.message(
      'last digits of your credit card',
      name: 'pin_type_cc',
      desc: '',
      args: [],
    );
  }

  String get pin_type_mn {
    return Intl.message(
      'last digits of your mobile phone number',
      name: 'pin_type_mn',
      desc: '',
      args: [],
    );
  }

  String get pin_type_hic {
    return Intl.message(
      'last digits of your health insurer card',
      name: 'pin_type_hic',
      desc: '',
      args: [],
    );
  }

  String get pin_type_plain {
    return Intl.message(
      'that was provided to you by the doctor’s staff',
      name: 'pin_type_plain',
      desc: '',
      args: [],
    );
  }

  String get pin_type_dob {
    return Intl.message(
      'your date of birth in the form MMYY',
      name: 'pin_type_dob',
      desc: '',
      args: [],
    );
  }

  String get system_encountered_problem {
    return Intl.message(
      'The system encountered a problem. Try downloading again the Application. If the problem resumes, call customer support, and report error',
      name: 'system_encountered_problem',
      desc: '',
      args: [],
    );
  }

  String get device_disconnected {
    return Intl.message(
      'The WatchPAT™ device is disconnected. Can\'t start testing',
      name: 'device_disconnected',
      desc: '',
      args: [],
    );
  }

  String get preparing_test {
    return Intl.message(
      'Preparing test. Please wait...',
      name: 'preparing_test',
      desc: '',
      args: [],
    );
  }

  String get restart_test {
    return Intl.message(
      'A problem has occurred. Please restart application, remove the battery from the device, reinsert it and start from the beginning.',
      name: 'restart_test',
      desc: '',
      args: [],
    );
  }

  String get you_can_end_recording {
    return Intl.message(
      'You can end recording only in',
      name: 'you_can_end_recording',
      desc: '',
      args: [],
    );
  }

  String get open_at_morning {
    return Intl.message(
      'For a successful completion of the test please make sure the App is open in the morning',
      name: 'open_at_morning',
      desc: '',
      args: [],
    );
  }

  String get carousel_welcome {
    return Intl.message(
      'Open the package, making sure you have a AAA battery along with the device and its sensors',
      name: 'carousel_welcome',
      desc: '',
      args: [],
    );
  }

  String get carousel_battery_1 {
    return Intl.message(
      'Insert the battery into the device',
      name: 'carousel_battery_1',
      desc: '',
      args: [],
    );
  }

  String get carousel_battery_2 {
    return Intl.message(
      'Make sure you follow the + and - marking, and with flat side against the spring',
      name: 'carousel_battery_2',
      desc: '',
      args: [],
    );
  }

  String get carousel_prepare_1 {
    return Intl.message(
      'Remove all jewelry and hand cream. Make sure the fingernails are trimmed.',
      name: 'carousel_prepare_1',
      desc: '',
      args: [],
    );
  }

  String get carousel_prepare_2 {
    return Intl.message(
      'Take off the watch. Do not apply any hand cream.',
      name: 'carousel_prepare_2',
      desc: '',
      args: [],
    );
  }

  String get carousel_identfy {
    return Intl.message(
      'Enter your assigned four digits PIN (personal identification number).',
      name: 'carousel_identfy',
      desc: '',
      args: [],
    );
  }

  String get carousel_strap_1 {
    return Intl.message(
      'You will be putting the WatchPAT on your non-dominant hand.',
      name: 'carousel_strap_1',
      desc: '',
      args: [],
    );
  }

  String get carousel_strap_2 {
    return Intl.message(
      'Place the WatchPAT on a flat surface.',
      name: 'carousel_strap_2',
      desc: '',
      args: [],
    );
  }

  String get carousel_strap_3 {
    return Intl.message(
      'Insert your hand and close the strap, making sure it\'s snug but not too tight.',
      name: 'carousel_strap_3',
      desc: '',
      args: [],
    );
  }

  String get carousel_chest_1 {
    return Intl.message(
      'Thread the sensor through your sleeve …\n\n* For specific device configurations only.',
      name: 'carousel_chest_1',
      desc: '',
      args: [],
    );
  }

  String get carousel_chest_2 {
    return Intl.message(
      '… up to the neck opening.\n\n* For specific device configurations only.',
      name: 'carousel_chest_2',
      desc: '',
      args: [],
    );
  }

  String get carousel_chest_3 {
    return Intl.message(
      'Peel the sticker off the back end of the sensor.\n\n* For specific device configurations only.',
      name: 'carousel_chest_3',
      desc: '',
      args: [],
    );
  }

  String get carousel_chest_4 {
    return Intl.message(
      'Attach the sensor just below the sternum notch. Trim or shave here if needed.\n\n* For specific device configurations only.',
      name: 'carousel_chest_4',
      desc: '',
      args: [],
    );
  }

  String get carousel_chest_5 {
    return Intl.message(
      'You may also secure the sensor with a medical tape.\n\n* For specific device configurations only.',
      name: 'carousel_chest_5',
      desc: '',
      args: [],
    );
  }

  String get carousel_finger_1 {
    return Intl.message(
      'Place the finger probe on your index finger. Once placed, the probe can not be removed and put on another finger.',
      name: 'carousel_finger_1',
      desc: '',
      args: [],
    );
  }

  String get carousel_finger_2 {
    return Intl.message(
      'If your index finger is too large for the probe, choose another finger that fits better.',
      name: 'carousel_finger_2',
      desc: '',
      args: [],
    );
  }

  String get carousel_finger_3 {
    return Intl.message(
      'Insert your index finger all the way into the probe.',
      name: 'carousel_finger_3',
      desc: '',
      args: [],
    );
  }

  String get carousel_finger_4 {
    return Intl.message(
      'The tab on top of the probe should be situated on the top side of your finger.',
      name: 'carousel_finger_4',
      desc: '',
      args: [],
    );
  }

  String get carousel_finger_5 {
    return Intl.message(
      'While pushing against the surface …',
      name: 'carousel_finger_5',
      desc: '',
      args: [],
    );
  }

  String get carousel_finger_6 {
    return Intl.message(
      'Gently but firmly remove the tab by pulling upward its tip …',
      name: 'carousel_finger_6',
      desc: '',
      args: [],
    );
  }

  String get carousel_finger_7 {
    return Intl.message(
      '… until fully removed.',
      name: 'carousel_finger_7',
      desc: '',
      args: [],
    );
  }

  String get carousel_sleep {
    return Intl.message(
      'WatchPAT is working properly and it is time to go to sleep.',
      name: 'carousel_sleep',
      desc: '',
      args: [],
    );
  }

  String get carousel_end_1_chest {
    return Intl.message(
      'In the morning remove the Chest sensor.\n\n* For specific device configurations only.',
      name: 'carousel_end_1_chest',
      desc: '',
      args: [],
    );
  }

  String get carousel_end_2 {
    return Intl.message(
      'Remove the device from your hand.',
      name: 'carousel_end_2',
      desc: '',
      args: [],
    );
  }

  String get carousel_end_3 {
    return Intl.message(
      'Remove the probe from your finger.',
      name: 'carousel_end_3',
      desc: '',
      args: [],
    );
  }

  String get carousel_end_4 {
    return Intl.message(
      'Remove the battery from device and keep for other uses.',
      name: 'carousel_end_4',
      desc: '',
      args: [],
    );
  }

  String get carousel_end_5 {
    return Intl.message(
      'Follow the local recycling instructions regarding disposal or recycling of the device and device components.',
      name: 'carousel_end_5',
      desc: '',
      args: [],
    );
  }

  String get send_logs {
    return Intl.message(
      'Send logs',
      name: 'send_logs',
      desc: '',
      args: [],
    );
  }

  String get forget_device {
    return Intl.message(
      'Forget device',
      name: 'forget_device',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'it'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}