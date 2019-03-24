class CommandTask {
  List<List<int>> _byteList;
  int _packetIdentifier;
  int _opCode;
  String _name;

  CommandTask(this._name, this._packetIdentifier, this._opCode, this._byteList);

  List<List<int>> get byteList => _byteList;

  int get packetIdentifier => _packetIdentifier;

  int get opCode => _opCode;

  String get name => _name;
}
