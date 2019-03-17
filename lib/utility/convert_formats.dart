import 'dart:typed_data';

class ConvertFormats {
  static Uint8List intListToBinList(List<int> arr) {
    return Uint8List.fromList(arr.map((i) => int.parse(i.toRadixString(16))));
  }

  static List<int> longToByteList(int long, {int size = 8}) {
    List byteList = List(size);
    for (var i = 0; i < size; i++) {
      byteList[i] = 0;
    }

    for (var index = 0; index < byteList.length; index++) {
      var byte = long & 0xff;
      byteList[index] = byte;
      long = (long - byte) ~/ 256;
    }

    return byteList;
  }

  static String byteToHex(int number) => number.toRadixString(16);

  static String bytesToHex(final List<int> bytes) {
    String result = '';
    bytes.forEach((byte) => result = result + byte.toRadixString(16));
    return result;
  }


  

}
