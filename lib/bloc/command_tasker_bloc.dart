import 'dart:collection';
import 'package:my_pat/utility/log/log.dart';

import 'package:my_pat/api/ble_provider.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:rxdart/rxdart.dart';

import 'package:date_format/date_format.dart';


abstract class OnAckListener {
  void onAckReceived();
}

class CommandTaskerBloc extends BlocBase {
  final BehaviorSubject<List<CommandTaskerItem>> _lastCommandQueueSubject =
      BehaviorSubject<List<CommandTaskerItem>>();

  final BehaviorSubject<List<CommandTaskerItem>> _lastAckQueueSubject =
      BehaviorSubject<List<CommandTaskerItem>>();

  final BehaviorSubject<List<int>> _lastReceivedAcksSubject =
      BehaviorSubject<List<int>>();

  Function(List<CommandTaskerItem> list) get setLastCommandQueue =>
      _lastCommandQueueSubject.sink.add;

  Function(List<CommandTaskerItem> list) get setLastAckQueue =>
      _lastAckQueueSubject.sink.add;

  Function(List<int> list) get setLastReceivedAcks => _lastReceivedAcksSubject.sink.add;

  List<CommandTaskerItem> get lastCommandQueueValue => _lastCommandQueueSubject.value;

  List<CommandTaskerItem> get lastAckQueueValue => _lastAckQueueSubject.value;

  List<int> get lastReceivedAcksValue => _lastReceivedAcksSubject.value;

  int _sendCommandsDelay;
  int _sendAckDelay;
  int _maxCommandTimeout;
  int _ackOpCode;
  Function _sendCmdCallback;
  Function _timeoutCallback;
  Map<int, OnAckListener> _mapAckListeners = HashMap();

  CommandTaskerBloc(
      {int sendCommandsDelay, int sendAckDelay, int maxCommandTimeout, int ackOpCode}) {
    _sendCommandsDelay =
        sendCommandsDelay != null ? sendCommandsDelay : BleProvider.SEND_COMMANDS_DELAY;
    _sendAckDelay = sendAckDelay != null ? sendAckDelay : BleProvider.SEND_ACK_DELAY;
    _maxCommandTimeout =
        maxCommandTimeout != null ? maxCommandTimeout : BleProvider.MAX_COMMAND_TIMEOUT;
    _ackOpCode = ackOpCode;

    _lastCommandQueueSubject.sink.add(List());
    _lastAckQueueSubject.sink.add(List());
    _lastReceivedAcksSubject.sink.add(List());
  }

  set sendCmdCallback(Function cb) => _sendCmdCallback = cb;

  set timeoutCallback(Function cb) => _timeoutCallback = cb;

  set ackOpCode(int code) => _ackOpCode = code;

  void removeCallbacks() {
    _sendCmdCallback = null;
    _timeoutCallback = null;
  }

  void clearCommands() {
    _lastCommandQueueSubject.sink.add(List());
    _lastAckQueueSubject.sink.add(List());
  }

  void setDelays(int afterCommandDelay, int stdAckDelay, int maxCommandTimeout) {
    _sendCommandsDelay = afterCommandDelay;
    _sendAckDelay = stdAckDelay;
    _maxCommandTimeout = maxCommandTimeout;
  }

  void addCommandWithNoCb(CommandTask commandTask) {
    addCommandWithCb(commandTask, listener: null);
  }

  bool addCommandWithCb(CommandTask commandTask, {OnAckListener listener}) {
    bool result = _addCommand(commandTask.packetIdentifier, commandTask.opCode,
        commandTask.byteList, commandTask.name);
    if (listener != null) {
      _addOnAckListener(commandTask.packetIdentifier, listener);
    }
    return result;
  }

  bool _addCommand(int id, int opCode, List<List<int>> data, String name) {
    Log.info("adding command: $name (id: ${id.toString()})");

    // if command the same id exists
    if (_getCommandByID(id) != null) {
      Log.shout(">>> command with same id exists, $this");
      return false;
    }

    CommandTaskerItem newCommand = new CommandTaskerItem(id, opCode, data, name);
    List<CommandTaskerItem> currentQueue = lastCommandQueueValue;
    currentQueue.add(newCommand);
    setLastCommandQueue(currentQueue);

    return true;
  }

  void addAck(CommandTask commandTask) {
    _addAck(commandTask.packetIdentifier, commandTask.byteList);
  }

  void _addAck(int id, List<List<int>> data) {
    if (_sendCmdCallback == null) {
      throw new Exception("Send command callback equals null.");
    }

    CommandTaskerItem newCommand = new CommandTaskerItem(id, _ackOpCode, data, "Ack");
    List<CommandTaskerItem> currentAckQueue = lastAckQueueValue;
    currentAckQueue.add(newCommand);
    setLastAckQueue(currentAckQueue);
  }

  void sendDirectCommand(CommandTask commandTask) {
    Log.info("sending DIRECT command, $this");
    CommandTaskerItem item = CommandTaskerItem(commandTask.packetIdentifier,
        commandTask.opCode, commandTask.byteList, commandTask.name);
//    _sendCmdCallback._sendCommand(item);
    _sendCmdCallback(item);
  }

  void _sendCommand(CommandTaskerItem item) {
    if ((_sendCmdCallback != null) && (item != null)) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (item.firstSendTime == 0) {
        item.firstSendTime = currentTime;
      }
      item.lastAttemptToSendTime = currentTime;
//      _sendCmdCallback._sendCommand(item);
      _sendCmdCallback(item);
    }
  }

  CommandTaskerItem _getCommandByID(final int id) {
    List<CommandTaskerItem> currentQueue = lastCommandQueueValue;

    for (CommandTaskerItem item in currentQueue) {
      if (item._id == id) {
        return item;
      }
    }
    return null;
  }

  void ackCommandReceived(int id) {
    List<int> lastReceivedAcks = lastReceivedAcksValue;
    lastReceivedAcks.add(id);
    setLastReceivedAcks(lastReceivedAcks);

    if (_mapAckListeners[id] != null) {
      _mapAckListeners[id].onAckReceived();
      _mapAckListeners.remove(id);
    }
  }

  void _synchronizeLists() {
    // copy _lstReceivedAcks to avoid nested synchronized block
    List<int> lstTmpAcks;
    List<int> lastReceivedAcks = lastReceivedAcksValue;

    lstTmpAcks = List.from(lastReceivedAcks);
    lastReceivedAcks.clear();
    setLastReceivedAcks(lastReceivedAcks);

    List<CommandTaskerItem> lastCommandQueue = lastCommandQueueValue;

    // if ACK list is empty, maybe device is not connected anymore?
    if (lstTmpAcks.length == 0) {
      // check how long commands wait for ACK
      for (CommandTaskerItem item in lastCommandQueue) {
        if ((item.firstSendTime > 0) &&
            (DateTime.now().millisecondsSinceEpoch - item.lastAttemptToSendTime >
                _maxCommandTimeout)) {
          _timeoutCallback();
        }
      }
    }

    // removing commands that received ACK
    for (int id in lstTmpAcks) {
      lastCommandQueue.remove(_getCommandByID(id));
    }
    setLastCommandQueue(lastCommandQueue);
  }

  void _addOnAckListener(int id, OnAckListener listener) {
    _mapAckListeners[id] = listener;
  }

  @override
  void dispose() {
    _lastCommandQueueSubject.close();
    _lastAckQueueSubject.close();
    _lastReceivedAcksSubject.close();
  }
}

class CommandTaskerItem {
  final int _id;
  final int _opCode;
  final List<List<int>> _data;
  int firstSendTime;
  int lastAttemptToSendTime;
  String name;

  // ignore: hash_and_equals
  int get hashCode => _id.hashCode;

  @override
  bool operator ==(Object obj) {
    if (this == obj) {
      return true;
    }
    if (obj == null) {
      return false;
    }
    if (runtimeType != obj.runtimeType) {
      return false;
    }
    final CommandTaskerItem other = obj;
    return this._id == (other._id);
  }

  CommandTaskerItem(this._id, this._opCode, this._data, this.name) {
    firstSendTime = 0;
  }

  int get id => _id;

  int get opCode => _opCode;

  List<List<int>> get data => _data;

  int compareTo(CommandTaskerItem item) {
    if (lastAttemptToSendTime > item.lastAttemptToSendTime) {
      return -1;
    } else if (lastAttemptToSendTime < item.lastAttemptToSendTime) {
      return 1;
    } else {
      return 0;
    }
  }

  String toString() {
    final timeFormatter = [HH, ':', mm, ':', ss, '.', SSS];
    return ('id: $_id | firstSend: ${formatDate(DateTime.fromMillisecondsSinceEpoch(firstSendTime), timeFormatter)} | lastSend: ${formatDate(DateTime.fromMillisecondsSinceEpoch(lastAttemptToSendTime), timeFormatter)} | msg: ${_data.toString()}');
  }
}

