import 'dart:async';
import 'dart:collection';
import 'package:my_pat/domain_model/command_task.dart';
import 'package:my_pat/utils/log/log.dart';

import 'package:my_pat/services/ble_service.dart';
import 'package:my_pat/managers/manager_base.dart';

import 'package:date_format/date_format.dart';

abstract class OnAckListener {
  void onAckReceived();
}

enum ThreadState { ACTIVE, NON_ACTIVE }

class CommandTaskerManager extends ManagerBase {
  static const String TAG = 'CommandTaskerManager';

  CommandTaskerManager({
    int sendCommandsDelay,
    int sendAckDelay,
    int maxCommandTimeout,
    int ackOpCode,
  }) {
    _sendCommandsDelay =
        sendCommandsDelay != null ? sendCommandsDelay : BleService.SEND_COMMANDS_DELAY;

    _sendAckDelay = sendAckDelay != null ? sendAckDelay : BleService.SEND_ACK_DELAY;

    _maxCommandTimeout =
        maxCommandTimeout != null ? maxCommandTimeout : BleService.MAX_COMMAND_TIMEOUT;
    _ackOpCode = ackOpCode;
  }

  List<CommandTaskerItem> _lstCommandQueue = [];
  List<CommandTaskerItem> _lstAckQueue = [];
  List<int> _lstReceivedAcks = [];

  int _sendCommandsDelay;
  int _sendAckDelay;
  int _maxCommandTimeout;
  int _ackOpCode;
  ThreadState _sndCmdHandlerState = ThreadState.NON_ACTIVE;
  ThreadState _ackHandlerState = ThreadState.NON_ACTIVE;

  Function _sendCmdCallback;
  Function _timeoutCallback;
  Map<int, OnAckListener> _mapAckListeners = HashMap();

  set sendCmdCallback(Function cb) => _sendCmdCallback = cb;

  set timeoutCallback(Function cb) => _timeoutCallback = cb;

  set ackOpCode(int code) => _ackOpCode = code;

  void removeCallbacks() {
    _sendCmdCallback = null;
    _timeoutCallback = null;
  }

  void clearCommands() {
    _lstCommandQueue = [];
    _lstAckQueue = [];
  }

  void setDelays(int afterCommandDelay, int stdAckDelay, int maxCommandTimeout) {
    _sendCommandsDelay = afterCommandDelay;
    _sendAckDelay = stdAckDelay;
    _maxCommandTimeout = maxCommandTimeout;
  }

  void addCommandWithNoCb(CommandTask commandTask) {
    addCommandWithCb(commandTask, listener: null);
  }

  void _sendCommandQueueHandler() async {
    _sndCmdHandlerState = ThreadState.ACTIVE;
    while (_lstCommandQueue.isNotEmpty) {
      CommandTaskerItem nextItem = _lstCommandQueue.removeLast();
      await _sendCommand(nextItem);
//      await Future.delayed(Duration(milliseconds: _sendCommandsDelay));
      await Future.delayed(Duration(milliseconds: _sendAckDelay), _synchronizeLists);
    }
    _sndCmdHandlerState = ThreadState.NON_ACTIVE;
  }

  void _sendAckQueueHandler() async {
    _ackHandlerState = ThreadState.ACTIVE;
    while (_lstAckQueue.isNotEmpty) {
      CommandTaskerItem nextAck = _lstAckQueue.removeLast();
      await _sendCommand(nextAck);
    }
    _ackHandlerState = ThreadState.NON_ACTIVE;
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
    Log.info(TAG,"adding command: $name (id: ${id.toString()})");

    // if command the same id exists
    if (_getCommandByID(id) != null) {
      Log.shout(TAG,">>> command with same id exists, $this");
      return false;
    }

    CommandTaskerItem newCommand = new CommandTaskerItem(id, opCode, data, name);
    _lstCommandQueue.insert(0, newCommand);
    if (_sndCmdHandlerState == ThreadState.NON_ACTIVE) {
      _sendCommandQueueHandler();
    }
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
    _lstAckQueue.insert(0, newCommand);
    if (_ackHandlerState == ThreadState.NON_ACTIVE) {
      _sendAckQueueHandler();
    }
  }

  void sendDirectCommand(CommandTask commandTask) {
    Log.info(TAG,"sending DIRECT command, $this");
    CommandTaskerItem item = CommandTaskerItem(commandTask.packetIdentifier,
        commandTask.opCode, commandTask.byteList, commandTask.name);
//    _sendCmdCallback._sendCommand(item);
    _sendCmdCallback(item);
  }

  Future<void> _sendCommand(CommandTaskerItem item) async {
    if ((_sendCmdCallback != null) && (item != null)) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (item.firstSendTime == 0) {
        item.firstSendTime = currentTime;
      }
      item.lastAttemptToSendTime = currentTime;
//      _sendCmdCallback._sendCommand(item);
      await _sendCmdCallback(item);
    }
  }

  CommandTaskerItem _getCommandByID(final int id) {
    return _lstCommandQueue.firstWhere((CommandTaskerItem item) => item._id == id,
        orElse: ()=>null);
  }

  void ackCommandReceived(int id) {
    _lstReceivedAcks.add(id);

    if (_mapAckListeners[id] != null) {
      _mapAckListeners[id].onAckReceived();
      _mapAckListeners.remove(id);
    }
  }

  void _synchronizeLists() {
    // copy _lstReceivedAcks to avoid nested synchronized block
    List<int> lstTmpAcks;

    lstTmpAcks = List.from(_lstReceivedAcks);
    _lstReceivedAcks.clear();

    // if ACK list is empty, maybe device is not connected anymore?
    if (lstTmpAcks.length == 0) {
      // check how long commands wait for ACK
      for (CommandTaskerItem item in _lstCommandQueue) {
        if ((item.firstSendTime > 0) &&
            (DateTime.now().millisecondsSinceEpoch - item.lastAttemptToSendTime >
                _maxCommandTimeout)) {
          _timeoutCallback();
        }
      }
    }

    // removing commands that received ACK
    for (int id in lstTmpAcks) {
      _lstCommandQueue.removeWhere((item) => item._id == id);
    }
  }

  void _addOnAckListener(int id, OnAckListener listener) {
    _mapAckListeners[id] = listener;
  }

  @override
  void dispose() {
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
