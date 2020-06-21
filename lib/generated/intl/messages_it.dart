// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'it';

  static m0(pin) => "Inserire il PIN a quattro cifre che vi è stato assegnato (\$pin) e premere INVIO";

  static m1(step, total) => "Step ${step} di ${total}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "acc_registers" : MessageLookupByLibrary.simpleMessage("ACC registers"),
    "acc_registers_description" : MessageLookupByLibrary.simpleMessage("ACC registers"),
    "acc_registers_get_fail" : MessageLookupByLibrary.simpleMessage("ACC registers retrieve failed"),
    "acc_registers_get_success" : MessageLookupByLibrary.simpleMessage("ACC registers retrieved successfully"),
    "acc_registers_write_failed" : MessageLookupByLibrary.simpleMessage("ACC registers write failed"),
    "acc_registers_written_successfully" : MessageLookupByLibrary.simpleMessage("ACC registers written successfully"),
    "afe_registers_description" : MessageLookupByLibrary.simpleMessage("AFE registers"),
    "afe_registers_get_fail" : MessageLookupByLibrary.simpleMessage("AFE registers retrieve failed"),
    "afe_registers_get_success" : MessageLookupByLibrary.simpleMessage("AFE registers retrieved successfully"),
    "afe_registers_write_failed" : MessageLookupByLibrary.simpleMessage("AFE registers write failed"),
    "afe_registers_written_successfully" : MessageLookupByLibrary.simpleMessage("AFE registers written successfully"),
    "all_data_transmitted_successfully" : MessageLookupByLibrary.simpleMessage(" Tutti i dati trasmessi con successo"),
    "app_log_file_text" : MessageLookupByLibrary.simpleMessage(" Sei sicuro di voler inviare il file di log dell\'applicazione a"),
    "app_log_file_title" : MessageLookupByLibrary.simpleMessage(" File di log dell\'applicazione"),
    "attention" : MessageLookupByLibrary.simpleMessage(" ATTENZIONE"),
    "auth_fail" : MessageLookupByLibrary.simpleMessage(" Autenticazione fallita"),
    "batteryContent_1" : MessageLookupByLibrary.simpleMessage(" Aprire il coperchio del vano batteria, situato sul retro del WatchPAT™ONE, e inserire la batteria in dotazione. \nIl lato piatto della batteria deve essere rivolto verso il segno MENO."),
    "batteryContent_2" : MessageLookupByLibrary.simpleMessage("Il lato piatto della batteria è rivolto verso il segno MENO."),
    "batteryContent_many_1" : MessageLookupByLibrary.simpleMessage(" Nell\'ambiente sono presenti più dispositivi. \nSi prega di rimuovere la batteria da tutti i dispositivi non rilevanti e riprovare."),
    "batteryContent_many_2" : MessageLookupByLibrary.simpleMessage("Rimuovere la batteria del WatchPAT™ ONE non utilizzato nella zona circostante."),
    "batteryContent_success" : MessageLookupByLibrary.simpleMessage(" WatchPAT ONE si è collegato con successo. Premere \'SUCCESSIVO\' per continuare."),
    "batteryTitle" : MessageLookupByLibrary.simpleMessage(" INSERIRE LA BATTERIA"),
    "battery_depleted" : MessageLookupByLibrary.simpleMessage("The device\'s battery is depleted or damaged. Please replace battery and try again"),
    "battery_level_error" : MessageLookupByLibrary.simpleMessage(" Il telefono non è collegato a un caricabatterie. Si prega di collegare un caricabatterie per iniziare l’esame."),
    "battery_voltage" : MessageLookupByLibrary.simpleMessage("Battery voltage: "),
    "bt_initiation_error" : MessageLookupByLibrary.simpleMessage(" Errore di avvio Bluetooth"),
    "bt_must_be_enabled" : MessageLookupByLibrary.simpleMessage(" Il Bluetooth deve essere abilitato per la procedura.\nSi prega di attivare il Bluetooth nel centro di controllo."),
    "bt_not_available_shutdown" : MessageLookupByLibrary.simpleMessage("Impossibile abilitare il Bluetooth, spegnimento."),
    "btnChangeAndRestart" : MessageLookupByLibrary.simpleMessage(" Modifica ed esci dall\'applicazione"),
    "btnCloseApp" : MessageLookupByLibrary.simpleMessage(" CHIUDERE L’APP"),
    "btnEndRecording" : MessageLookupByLibrary.simpleMessage("TERMINA REGISTRAZIONE"),
    "btnEnter" : MessageLookupByLibrary.simpleMessage(" INVIO"),
    "btnFinish" : MessageLookupByLibrary.simpleMessage(" Fine"),
    "btnMore" : MessageLookupByLibrary.simpleMessage(" ALTRO"),
    "btnNext" : MessageLookupByLibrary.simpleMessage("SUCCESSIVO"),
    "btnPreview" : MessageLookupByLibrary.simpleMessage(" ANTEPRIMA"),
    "btnPrevious" : MessageLookupByLibrary.simpleMessage(" PRECEDENTE"),
    "btnReady" : MessageLookupByLibrary.simpleMessage(" PRONTO"),
    "btnReturnToApp" : MessageLookupByLibrary.simpleMessage(" Ritorna all’App"),
    "btnStartRecording" : MessageLookupByLibrary.simpleMessage(" INIZIA"),
    "cancel" : MessageLookupByLibrary.simpleMessage(" ANNULLA"),
    "carousel_battery_1" : MessageLookupByLibrary.simpleMessage("Inserire la batteria nel dispositivo"),
    "carousel_battery_2" : MessageLookupByLibrary.simpleMessage("Seguire i segni + e -  e inserire l’estremità piatta verso la molla "),
    "carousel_chest_1" : MessageLookupByLibrary.simpleMessage("Infilare il sensore nella manica...\n\n* Solo per configurazioni specifiche del dispositivo."),
    "carousel_chest_2" : MessageLookupByLibrary.simpleMessage("...fino all’apertura del collo.\n\n* Solo per configurazioni specifiche del dispositivo."),
    "carousel_chest_3" : MessageLookupByLibrary.simpleMessage("Staccare l\'adesivo dal retro del sensore.\n \n* Solo per configurazioni specifiche del dispositivo."),
    "carousel_chest_4" : MessageLookupByLibrary.simpleMessage("Attaccare il sensore appena sotto l\'incavo sovrasternale. Radersi se necessario.\n \n* Solo per configurazioni specifiche del dispositivo."),
    "carousel_chest_5" : MessageLookupByLibrary.simpleMessage("È anche possibile fissare il sensore con un nastro medicale.\n \n* Solo per configurazioni specifiche del dispositivo."),
    "carousel_end_1_chest" : MessageLookupByLibrary.simpleMessage("Al mattino rimuovere il sensore toracico.\n\n* Solo per configurazioni specifiche dell\'apparecchio."),
    "carousel_end_2" : MessageLookupByLibrary.simpleMessage("Togliere il dispositivo dalla mano."),
    "carousel_end_3" : MessageLookupByLibrary.simpleMessage("Togliere la sonda dal ditto"),
    "carousel_end_4" : MessageLookupByLibrary.simpleMessage("Rimuovere la batteria dal dispositivo e tenerla per altri usi"),
    "carousel_end_5" : MessageLookupByLibrary.simpleMessage("Seguire le istruzioni locali relative allo smaltimento o al riciclo del dispositivo e dei suoi componenti."),
    "carousel_finger_1" : MessageLookupByLibrary.simpleMessage("Posizionare la sonda sul dito indice. Una volta posizionata, la sonda non può essere tolta per essere messa su un altro dito."),
    "carousel_finger_2" : MessageLookupByLibrary.simpleMessage("Se l\'indice è troppo grande per la sonda, scegliere un dito che si adatti meglio."),
    "carousel_finger_3" : MessageLookupByLibrary.simpleMessage("Inserire il dito indice fino in fondo alla sonda."),
    "carousel_finger_4" : MessageLookupByLibrary.simpleMessage("La linguetta posta sulla parte superiore della sonda deve essere situata sul lato superiore del dito."),
    "carousel_finger_5" : MessageLookupByLibrary.simpleMessage("Mentre si preme contro una superficie piatta"),
    "carousel_finger_6" : MessageLookupByLibrary.simpleMessage("Staccare la linguetta tirando l\'estremità verso l\'alto in modo delicato ma fermo..."),
    "carousel_finger_7" : MessageLookupByLibrary.simpleMessage("fino a rimuoverla completamente."),
    "carousel_identfy" : MessageLookupByLibrary.simpleMessage("Inserire il PIN (numero di identificazione personale) a quattro cifre assegnato."),
    "carousel_prepare_1" : MessageLookupByLibrary.simpleMessage("Rimuovere tutti i gioielli e la crema per le mani. Assicurarsi che le unghie siano tagliate."),
    "carousel_prepare_2" : MessageLookupByLibrary.simpleMessage("Togliersi l’orologio. Non applicare crema per le mani."),
    "carousel_sleep" : MessageLookupByLibrary.simpleMessage("WatchPAT funziona correttamente ed è ora di andare a dormire."),
    "carousel_strap_1" : MessageLookupByLibrary.simpleMessage("Applicare WatchPAT alla mano non dominante."),
    "carousel_strap_2" : MessageLookupByLibrary.simpleMessage("Posizionare WatchPAT su una superficie piana."),
    "carousel_strap_3" : MessageLookupByLibrary.simpleMessage("Infilare la mano e regolare il cinturino, assicurandosi che sia aderente ma non troppo stretto."),
    "carousel_welcome" : MessageLookupByLibrary.simpleMessage("Aprire la confezione, assicurandosi di avere a disposizione una batteria AAA insieme al dispositivo e ai suoi sensori"),
    "chestSensorContent" : MessageLookupByLibrary.simpleMessage("Se si indossa una maglia, far passare il sensore per il torace attraverso la manica fino a raggiungere l\'apertura del collo. Staccare la pellicola bianca dal retro del sensore. Attaccare il sensore sulla parte superiore dello sterno, appena al di sotto dell’incavo sovrasternale"),
    "chestSensorTitle" : MessageLookupByLibrary.simpleMessage(" Attaccare il sensore per il torace"),
    "close_app" : MessageLookupByLibrary.simpleMessage(" CHIUDERE L’APP"),
    "close_mypat_app_q" : MessageLookupByLibrary.simpleMessage(" Chiudere l\'applicazione WatchPAT™?"),
    "confirm_stop_test" : MessageLookupByLibrary.simpleMessage("Sei sicuro di voler terminare la registrazione? "),
    "connect_to_charger" : MessageLookupByLibrary.simpleMessage(" Collegare l’Iphone ad un caricabatterie"),
    "connected" : MessageLookupByLibrary.simpleMessage(" Connesso"),
    "connected_to_device" : MessageLookupByLibrary.simpleMessage(" Collegato al dispositivo"),
    "connected_to_used_device" : MessageLookupByLibrary.simpleMessage(" Collegato ad un dispositivo usato"),
    "connecting_to_device" : MessageLookupByLibrary.simpleMessage(" Connessione ad un dispositivo in corso"),
    "connection_to_main_device_lost" : MessageLookupByLibrary.simpleMessage(" La connessione al dispositivo principale si è interrotta"),
    "critical_hw_failure" : MessageLookupByLibrary.simpleMessage(" Errore critico dell\'hardware"),
    "customer_service_mode" : MessageLookupByLibrary.simpleMessage(" Modalità di assistenza clienti"),
    "device_connection_failed" : MessageLookupByLibrary.simpleMessage(" Impossibile connettersi al dispositivo. \\n\\nContattare Itamar Medical per l’assistenza"),
    "device_disconnected" : MessageLookupByLibrary.simpleMessage("Il dispositivo WatchPATג\'¢ è scollegato. Non è possibile avviare il test"),
    "device_is_not_paired_error" : MessageLookupByLibrary.simpleMessage(" Errore di abbinamento del dispositivo principale. Resettare il dispositivo e riprovare."),
    "device_is_paired_error" : MessageLookupByLibrary.simpleMessage(" L\'apparecchio è già stato associato, si prega di resettare l\'apparecchio e di avviare nuovamente il processo"),
    "device_log_file_description" : MessageLookupByLibrary.simpleMessage(" File di log del dispositivo "),
    "device_not_found" : MessageLookupByLibrary.simpleMessage(" Impossibile trovare il dispositivo"),
    "device_not_located" : MessageLookupByLibrary.simpleMessage(" Il dispositivo non è localizzato. Controllare se il LED WatchPAT™ ONE lampeggia. Se sì, posizionare il telefono più vicino al dispositivo. Altrimenti verificare di aver inserito una batteria nuova e che sia stata posizionata nel modo corretto."),
    "device_sn" : MessageLookupByLibrary.simpleMessage(" Numero di serie del dispositivo \$sn"),
    "device_ver_name" : MessageLookupByLibrary.simpleMessage(" Versione dispositivo FW"),
    "digits" : MessageLookupByLibrary.simpleMessage(" cifre"),
    "disconnect_all_irr_devices" : MessageLookupByLibrary.simpleMessage(" Scollegare tutti i dispositivi non rilevanti"),
    "disconnected" : MessageLookupByLibrary.simpleMessage(" Scollegato"),
    "dispatcher_connection_failed" : MessageLookupByLibrary.simpleMessage("Connessione al server non riuscita"),
    "dutch" : MessageLookupByLibrary.simpleMessage("Olandese"),
    "eeprom_get_fail" : MessageLookupByLibrary.simpleMessage("EEPROM data retrieve failed"),
    "eeprom_get_success" : MessageLookupByLibrary.simpleMessage("EEPROM data retrieved successfully"),
    "eeprom_write_failed" : MessageLookupByLibrary.simpleMessage("Device EEPROM write failed"),
    "eeprom_written_successfully" : MessageLookupByLibrary.simpleMessage("Device EEPROM written successfully"),
    "elapsed_time" : MessageLookupByLibrary.simpleMessage(" Tempo trascorso "),
    "english" : MessageLookupByLibrary.simpleMessage(" Inglese"),
    "enter_id" : MessageLookupByLibrary.simpleMessage(" ID:"),
    "enter_new_serial" : MessageLookupByLibrary.simpleMessage(" Inserire il numero seriale del dispositivo"),
    "err_actigraph_test" : MessageLookupByLibrary.simpleMessage(" Test dell\'actigrafo"),
    "err_battery_low" : MessageLookupByLibrary.simpleMessage(" Basso voltaggio della batteria"),
    "err_flash_test" : MessageLookupByLibrary.simpleMessage(" Test della memoria flash"),
    "err_probe_leds" : MessageLookupByLibrary.simpleMessage(" Sonda LED"),
    "err_probe_photo" : MessageLookupByLibrary.simpleMessage(" Foto sonda"),
    "err_sbp" : MessageLookupByLibrary.simpleMessage(" SBP"),
    "err_used_device" : MessageLookupByLibrary.simpleMessage(" Dispositivo principale usato"),
    "error" : MessageLookupByLibrary.simpleMessage(" Errore"),
    "error_state" : MessageLookupByLibrary.simpleMessage(" STATO DI ERRORE"),
    "exit_service_mode" : MessageLookupByLibrary.simpleMessage(" Esci dalla modalità di assistenza"),
    "fatal_error" : MessageLookupByLibrary.simpleMessage(" Errore irreversibile"),
    "files_creating_failed" : MessageLookupByLibrary.simpleMessage(" Impossibile creare i file iniziali"),
    "fingerProbeContent" : MessageLookupByLibrary.simpleMessage("Inserire un dito qualsiasi della mano non dominante, tranne il pollice, fino a toccare il fondo della sonda. L\'adesivo con la scritta TOP deve trovarsi sempre sulla parte superiore del dito. Appoggiare la sonda su una superficie dura (ad esempio un tavolo) e tirare la linguetta TOP verso di sé per rimuoverla dalla sonda."),
    "fingerProbeTitle" : MessageLookupByLibrary.simpleMessage("ATTACCARE LA SONDA PER DITO"),
    "finger_not_detected" : MessageLookupByLibrary.simpleMessage(" Allarme \'dito non rilevato\'"),
    "firmware_alert_title" : MessageLookupByLibrary.simpleMessage("  Aggiornamento del firmware del dispositivo"),
    "firmware_upgrade_failed" : MessageLookupByLibrary.simpleMessage("Firmware update failed"),
    "firmware_upgrade_success" : MessageLookupByLibrary.simpleMessage("Firmware update completed successfully"),
    "firmware_upgrading" : MessageLookupByLibrary.simpleMessage("Upgrading main device firmware, please don\'t close the application"),
    "firmware_version" : MessageLookupByLibrary.simpleMessage("Firmware version"),
    "flash_full" : MessageLookupByLibrary.simpleMessage(" Memoria flash del dispositivo piena"),
    "for_help_video" : MessageLookupByLibrary.simpleMessage(" Per il video tutorial accedere a questo link"),
    "forget_device" : MessageLookupByLibrary.simpleMessage("Dimentica dispositivo"),
    "french" : MessageLookupByLibrary.simpleMessage(" Francese"),
    "fw_check_version" : MessageLookupByLibrary.simpleMessage("Attendere la verifica della versione del firmware del dispositivo"),
    "fw_connection_failed" : MessageLookupByLibrary.simpleMessage(" Collegamento con il dispositivo non riuscito. Il test sarà terminato.\n \n Contattare il supporto medico Itamar."),
    "fw_need_upgrade" : MessageLookupByLibrary.simpleMessage(" È disponibile la nuova versione del firmware del dispositivo. Non ci vorrà molto tempo.\n \n Attendere mentre lo aggiorniamo&#8230;"),
    "fw_upgrade_failed" : MessageLookupByLibrary.simpleMessage(" Aggiornamento del firmware del dispositivo non riuscito.\n \n Contattare l\'assistenza medica Itamar."),
    "fw_upgrade_succeed" : MessageLookupByLibrary.simpleMessage(" Firmware del dispositivo aggiornato con successo"),
    "german" : MessageLookupByLibrary.simpleMessage("Allemand"),
    "get" : MessageLookupByLibrary.simpleMessage("get"),
    "get_tech_status_timeout" : MessageLookupByLibrary.simpleMessage("Get tech status: timeout"),
    "getting_log_file" : MessageLookupByLibrary.simpleMessage("Getting device log file"),
    "getting_log_file_fail" : MessageLookupByLibrary.simpleMessage("Getting device log file failed"),
    "getting_log_file_success" : MessageLookupByLibrary.simpleMessage("Getting device log file success"),
    "getting_param_file" : MessageLookupByLibrary.simpleMessage("Getting parameter file"),
    "getting_param_file_fail" : MessageLookupByLibrary.simpleMessage("Getting parameter file: failed"),
    "getting_param_file_success" : MessageLookupByLibrary.simpleMessage("Getting parameter file: success"),
    "green" : MessageLookupByLibrary.simpleMessage(" verde"),
    "id_in" : MessageLookupByLibrary.simpleMessage(" ID in"),
    "ignore_device_errors" : MessageLookupByLibrary.simpleMessage("Ignore all device generated errors?"),
    "incorrect_pin" : MessageLookupByLibrary.simpleMessage(" PIN errato, riprovare"),
    "inet_initiation_error" : MessageLookupByLibrary.simpleMessage(" Errore di avvio di Internet"),
    "inet_unavailable" : MessageLookupByLibrary.simpleMessage(" Impossibile connettersi ad internet"),
    "insert_battery_desc1" : MessageLookupByLibrary.simpleMessage(" Aprire il coperchio del vano batteria, situato sul retro di WatchPAT™ ONE, e cambiare la batteria."),
    "instructions_video" : MessageLookupByLibrary.simpleMessage(" Video di istruzioni"),
    "insufficient_storage_space_on_smartphone" : MessageLookupByLibrary.simpleMessage(" Memoria libera insufficiente sul telefono"),
    "invalid_id" : MessageLookupByLibrary.simpleMessage(" ID non valido"),
    "invalid_technician_password" : MessageLookupByLibrary.simpleMessage(" Password tecnico non valida"),
    "ir_led_status" : MessageLookupByLibrary.simpleMessage("IR LED status: "),
    "italian" : MessageLookupByLibrary.simpleMessage("Italia"),
    "loading" : MessageLookupByLibrary.simpleMessage(" Caricamento"),
    "log_email_subject" : MessageLookupByLibrary.simpleMessage(" File di log del dispositivo WatchPAT™"),
    "low_power" : MessageLookupByLibrary.simpleMessage(" Allarme di bassa alimentazione"),
    "make_sure_watchpat_bin_is_placed_in_watchpat_dir" : MessageLookupByLibrary.simpleMessage("Make sure watchpat.bin is placed to internal directory"),
    "myPAT_connect_to_server_fail" : MessageLookupByLibrary.simpleMessage(" Impossibile per WatchPAT™ connettersi al server SFTP"),
    "mypat_device" : MessageLookupByLibrary.simpleMessage(" Dispositivo WatchPAT™"),
    "no_inet_connection" : MessageLookupByLibrary.simpleMessage(" Internet deve essere abilitato per avviare la procedura.\nPrego, attivare Internet"),
    "none" : MessageLookupByLibrary.simpleMessage(" Nessuno"),
    "not_enough_test_data" : MessageLookupByLibrary.simpleMessage(" L\'applicazione non ha raccolto abbastanza dati di prova. È possibile interrompere il test in:"),
    "ok" : MessageLookupByLibrary.simpleMessage(" OK"),
    "open_at_morning" : MessageLookupByLibrary.simpleMessage("Per completare con successo l’esame, assicurarsi che al mattina l\'App sia aperta "),
    "param_file_written_successfully" : MessageLookupByLibrary.simpleMessage("Parameter file written successfully"),
    "parameters_file_description" : MessageLookupByLibrary.simpleMessage("Parameters file"),
    "parameters_file_title" : MessageLookupByLibrary.simpleMessage("Parameters file"),
    "parameters_file_write_failed" : MessageLookupByLibrary.simpleMessage("Parameters file write failed"),
    "parameters_file_written_successfully" : MessageLookupByLibrary.simpleMessage("Parameters file written successfully"),
    "pat_led_status" : MessageLookupByLibrary.simpleMessage("PAT LED status: "),
    "patient_msg1" : MessageLookupByLibrary.simpleMessage("Collegare il telefono ad un caricabatterie. Lasciare il caricabatterie collegato durante l\'intera procedura. \nChiudere le applicazioni inutilizzate prima di iniziare l’esame. Si prega di non chiudere l\'applicazione WatchPAT™ONE durante l’esame."),
    "patient_msg2" : MessageLookupByLibrary.simpleMessage(" Non chiudere l’applicazione WatchPAT™ durante la procedura dell’esame."),
    "pinContent" : m0,
    "pinTitle" : MessageLookupByLibrary.simpleMessage(" Inserire il PIN"),
    "pin_number_assigned_to_you" : MessageLookupByLibrary.simpleMessage(" Il numero PIN assegnato può essere \$pin. Se non siete sicuri, dovrete chiamare lo studio medico."),
    "pin_retries_exceeded" : MessageLookupByLibrary.simpleMessage("Numero massimo di tentativi di inserimento del PIN superato"),
    "pin_type_cc" : MessageLookupByLibrary.simpleMessage("ultime cifre della vostra carta di credito"),
    "pin_type_dob" : MessageLookupByLibrary.simpleMessage("la vostra data di nascita nel formato MMAA"),
    "pin_type_hic" : MessageLookupByLibrary.simpleMessage("ultime cifre della vostra tessera dell\'assicurazione"),
    "pin_type_mn" : MessageLookupByLibrary.simpleMessage("ultime cifre del vostro numero di cellulare"),
    "pin_type_plain" : MessageLookupByLibrary.simpleMessage("fornito dallo staff medico"),
    "pin_type_pn" : MessageLookupByLibrary.simpleMessage("fornito dallo staff medico"),
    "pin_type_ss" : MessageLookupByLibrary.simpleMessage("ultime cifre della polizza sanitaria"),
    "pleaseWait" : MessageLookupByLibrary.simpleMessage("Si prega di attendere"),
    "please_insert_finger" : MessageLookupByLibrary.simpleMessage(" Inserire il dito e premere OK"),
    "please_plug_charger" : MessageLookupByLibrary.simpleMessage(" Collegare un caricabatterie"),
    "please_replace_battery" : MessageLookupByLibrary.simpleMessage(" Sostituire le batterie del dispositivo"),
    "preparing_test" : MessageLookupByLibrary.simpleMessage(" Preparazione del test. Si prega di attendere..."),
    "product_reuse" : MessageLookupByLibrary.simpleMessage(" Tentativo di riutilizzare il dispositivo"),
    "ready" : MessageLookupByLibrary.simpleMessage(" PRONTO"),
    "recordingTitle" : MessageLookupByLibrary.simpleMessage(" BUONANOTTE "),
    "red" : MessageLookupByLibrary.simpleMessage(" Rosso"),
    "red_led_status" : MessageLookupByLibrary.simpleMessage("Red LED status: "),
    "remote_server" : MessageLookupByLibrary.simpleMessage(" Server remoto"),
    "removeJewelryContent" : MessageLookupByLibrary.simpleMessage(" Togliersi vestiti stretti, orologi e gioielli.\nAssicurarsi che l\'unghia della mano non dominante sia tagliata.\nRimuovere unghie artificiali o smalto dal dito monitorato. \n Utilizzare il pulsante ALTRO per vedere maggiori dettagli."),
    "removeJewelryTitle" : MessageLookupByLibrary.simpleMessage(" PREPARAZIONE"),
    "requesting_technical_status" : MessageLookupByLibrary.simpleMessage("Requesting technical status"),
    "reset" : MessageLookupByLibrary.simpleMessage("Reset"),
    "reset_application_prompt" : MessageLookupByLibrary.simpleMessage("Are you sure you want to delete all application stored preferences and files? You will need to launch application again."),
    "reset_application_title" : MessageLookupByLibrary.simpleMessage("Reset application"),
    "reset_main_device" : MessageLookupByLibrary.simpleMessage("Resetting main device"),
    "restart_test" : MessageLookupByLibrary.simpleMessage(" Si è verificato un problema. Si prega di riavviare l\'applicazione, rimuovere la batteria dal dispositivo, reinserirla e ricominciare dall\'inizio."),
    "retrieve_stored_data" : MessageLookupByLibrary.simpleMessage("Retrieve stored data"),
    "retrieve_stored_data_from_device" : MessageLookupByLibrary.simpleMessage("Retrieve stored data from the device?"),
    "retrieve_stored_test_data_failed" : MessageLookupByLibrary.simpleMessage("Retrieve stored test data failed"),
    "retrieving_stored_test_data" : MessageLookupByLibrary.simpleMessage("Retrieving stored test data"),
    "scan_again" : MessageLookupByLibrary.simpleMessage(" Ricerca di nuovo"),
    "scanning_device" : MessageLookupByLibrary.simpleMessage(" Ricerca dispositivi"),
    "select_bit_type" : MessageLookupByLibrary.simpleMessage("Select BIT mode"),
    "select_dispatcher_text" : MessageLookupByLibrary.simpleMessage(" Sarà necessario avviare nuovamente l\'applicazione"),
    "select_dispatcher_title" : MessageLookupByLibrary.simpleMessage(" Scegliere l’URL del mittente"),
    "select_language" : MessageLookupByLibrary.simpleMessage(" Seleziona la lingua"),
    "select_led_color" : MessageLookupByLibrary.simpleMessage("Select LED color"),
    "select_reset_type" : MessageLookupByLibrary.simpleMessage("Select reset type"),
    "send" : MessageLookupByLibrary.simpleMessage(" Invia"),
    "send_logs" : MessageLookupByLibrary.simpleMessage("Invia registri"),
    "server_comm_error" : MessageLookupByLibrary.simpleMessage(" Errore di comunicazione col server. Contattare l’assistenza"),
    "set" : MessageLookupByLibrary.simpleMessage("set"),
    "set_and_close" : MessageLookupByLibrary.simpleMessage("Set and close"),
    "set_device_serial_success" : MessageLookupByLibrary.simpleMessage("Set device serial: success"),
    "set_device_serial_timeout" : MessageLookupByLibrary.simpleMessage("Set device serial: timeout"),
    "set_led_color_success" : MessageLookupByLibrary.simpleMessage("Set LED color: success"),
    "set_led_color_timeout" : MessageLookupByLibrary.simpleMessage("Set LED color: timeout"),
    "set_serial" : MessageLookupByLibrary.simpleMessage("Set device serial"),
    "sftp_server_no_access" : MessageLookupByLibrary.simpleMessage("Il server SFTP non è accessibile. Codice di errore riportato."),
    "sn_not_registered" : MessageLookupByLibrary.simpleMessage("Utente non registrato"),
    "startRecordingContent" : MessageLookupByLibrary.simpleMessage(" Una volta che il WatchPAT ONE è stato indossato correttamente, è pronto per iniziare la registrazione. Premere il pulsante INIZIO e fare una bella dormita. \n\nSe avete bisogno di alzarvi durante la notte, non rimuovete il dispositivo o i sensori. Lasciare il telefono collegato al caricabatterie."),
    "startRecordingTitle" : MessageLookupByLibrary.simpleMessage(" INIZIO REGISTRAZIONE"),
    "start_test" : MessageLookupByLibrary.simpleMessage(" INIZIO ESAME"),
    "status" : MessageLookupByLibrary.simpleMessage("Status: \$status"),
    "stepper" : m1,
    "stepperOf" : MessageLookupByLibrary.simpleMessage("di"),
    "stepperStep" : MessageLookupByLibrary.simpleMessage(" Step"),
    "stop_test" : MessageLookupByLibrary.simpleMessage("FINE ESAME"),
    "strapWristContent" : MessageLookupByLibrary.simpleMessage("Allacciare il WatchPAT™ONE sulla mano non dominante. \nAssicurarsi che il WatchPAT ™ONE  sia aderente ma non troppo stretto."),
    "strapWristTitle" : MessageLookupByLibrary.simpleMessage(" ALLACCIARE IL DISPOSITIVO DA POLSO"),
    "system_encountered_problem" : MessageLookupByLibrary.simpleMessage(" Il sistema ha riscontrato un problema. Provare a scaricare di nuovo l\'applicazione. Se il problema si ripresenta, chiamare l\'assistenza clienti e segnalare l\'errore"),
    "technician_mode" : MessageLookupByLibrary.simpleMessage(" Modalità tecnico"),
    "test_data_from_previous_session_still_uploading" : MessageLookupByLibrary.simpleMessage(" Dati della sessione precedente ancora in caricamento sul server"),
    "test_data_still_transmitting_close_anyway" : MessageLookupByLibrary.simpleMessage(" Trasmissione dei dati ancora in corso. Si prega di non chiudere l\'applicazione WatchPAT™.  Chiudere comunque?"),
    "test_data_transmit_in_progress" : MessageLookupByLibrary.simpleMessage(" Trasmissione dati dell’esame in corso"),
    "test_in_progress" : MessageLookupByLibrary.simpleMessage(" Esame in corso"),
    "test_is_complete" : MessageLookupByLibrary.simpleMessage("Application was successfully used to perform the test. Please reset application to use it again."),
    "test_length" : MessageLookupByLibrary.simpleMessage("Test Time: \$time"),
    "test_status" : MessageLookupByLibrary.simpleMessage("Test Status: \$status"),
    "thankYouContent" : MessageLookupByLibrary.simpleMessage("Congratulazioni, i risultati dell\'esame sono stati inviati correttamente al medico.\nSi prega di smaltire il prodotto secondo le normative locali."),
    "thankYouNoInet" : MessageLookupByLibrary.simpleMessage("Al momento non è possibile inviare i risultati dell\'esame al medico in quanto la connessione a internet non è disponibile.\nVerificare che la connessione internet sia attiva e aprire l\'applicazione per completare il caricamento."),
    "thankYouStillUploading" : MessageLookupByLibrary.simpleMessage("L\'invio dei risultati dell\'esame al medico è ancora in corso.\nNon chiudete l\'applicazione e lasciate il display acceso fino a quando tutti i dati non sono stati caricati.\nAvanzamento del caricamento:"),
    "thankYouTitle" : MessageLookupByLibrary.simpleMessage(" GRAZIE"),
    "title_led_color_alert" : MessageLookupByLibrary.simpleMessage(" Scegliere il colore del LED"),
    "unknown_error" : MessageLookupByLibrary.simpleMessage(" Si è verificato un errore sconosciuto durante l\'autenticazione, si prega di contattare il supporto"),
    "upat_eeprom" : MessageLookupByLibrary.simpleMessage("UPAT EEPROM"),
    "upgrade" : MessageLookupByLibrary.simpleMessage("Upgrade"),
    "upgrade_file_ver_name" : MessageLookupByLibrary.simpleMessage("UpgradeFileVersion"),
    "uploadingContent" : MessageLookupByLibrary.simpleMessage(" Si prega di non chiudere l\'applicazione durante il caricamento dei dati.\n La trasmissione dei dati terminerà tra qualche minuto."),
    "uploadingDeviceDisconnected" : MessageLookupByLibrary.simpleMessage("Comunicazione assente con il dispositivo WatchPAT. Avvicinare il dispositivo all\'applicazione."),
    "uploadingTitle" : MessageLookupByLibrary.simpleMessage(" BUONGIORNO"),
    "used_device_please_replace" : MessageLookupByLibrary.simpleMessage(" Questo dispositivo è già utilizzato, si prega di sostituirlo e rilanciare l\'applicazione."),
    "user_mode" : MessageLookupByLibrary.simpleMessage(" Modalità utente"),
    "vdd_voltage" : MessageLookupByLibrary.simpleMessage("VDD voltage: "),
    "welcomeContent" : MessageLookupByLibrary.simpleMessage("Benvenuti in WatchPAT™ONE. Con questa applicazione sarà possibile inviare i dati sul proprio sonno al medico. Per prima cosa occorre verificare che tutto sia impostato correttamente.\nSpegnere tutti gli altri dispositivi elettronici presenti nella stanza (ad es. smart watch, smartphone, cuffie), in quanto potrebbero interferire con l\'esame.\nSe si desidera avviare subito la configurazione, premere il pulsante PRONTO. Premendo il pulsante ANTEPRIMA si avrà una rapida panoramica della configurazione."),
    "welcomeTitle" : MessageLookupByLibrary.simpleMessage(" BENVENUTO"),
    "welcome_to_mypat" : MessageLookupByLibrary.simpleMessage(" Benvenuto in WatchPAT™"),
    "writing_param_file" : MessageLookupByLibrary.simpleMessage("Writing parameter file"),
    "you_can_end_recording" : MessageLookupByLibrary.simpleMessage("È possibile terminare la registrazione solo in")
  };
}
