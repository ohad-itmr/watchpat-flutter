import 'dart:typed_data';

class ConvertFormats {
  static Uint8List intListToBinList(List<int> arr) {
    return Uint8List.fromList(arr.map((i) => int.parse(i.toRadixString(16))));
  }

  static List<int> longToByteList(int long,
      {int size = 8, bool reversed = true}) {
    List<int> byteList = List(size);
    for (var i = 0; i < size; i++) {
      byteList[i] = 0;
    }

    for (var index = 0; index < byteList.length; index++) {
      var byte = long & 0xff;
      byteList[index] = byte;
      long = (long - byte) ~/ 256;
    }

    return reversed ? byteList.reversed.toList() : byteList;
  }

  static String byteToHex(int number) => number.toRadixString(16);

  static int byteArrayToHex(List<int> byteArray) {
    List<String> res = byteArray.map((i) => i.toRadixString(16)).toList();
    return int.parse('0x${res.join()}');
  }

  static String bytesToHex(final List<int> bytes) {
    String result = '';
    bytes.forEach((byte) => result = result + byte.toRadixString(16));
    return result;
  }

  static int intFromBytes(List<int> bytes) {
    var buffer = new Uint8List.fromList(bytes.reversed.toList()).buffer;
    var bdata = new ByteData.view(buffer);
    return bdata.getInt32(0);
  }
}
