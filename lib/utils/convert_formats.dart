import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:my_pat/utils/log/log.dart';

class ConvertFormats {
  static const TAG = "ConvertFormats";

  static Uint8List intListToBinList(List<int> arr) {
    return Uint8List.fromList(arr.map((i) => int.parse(i.toRadixString(16))));
  }

  static List<int> longToByteList(int long, {int size = 8, bool reversed = true}) {
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

  static int fourBytesToInt(List<int> bytes) {
    if (bytes.length != 4) {
      Log.shout(
          TAG, "Error in converting bytes to int. Received ${bytes.length} bytes instead of 4");
      return 0;
    }
    var buffer = new Uint8List.fromList(bytes.reversed.toList()).buffer;
    var bdata = new ByteData.view(buffer);
    return bdata.getInt32(0);
  }

  static int threeBytesToInt({@required int byte1, @required int byte2, @required int byte3}) {
    List<int> bytes = List.filled(4, 0, growable: false);
    bytes[1] = byte3;
    bytes[2] = byte2;
    bytes[3] = byte1;
    var buffer = new Uint8List.fromList(bytes).buffer;
    var bdata = new ByteData.view(buffer);
    return bdata.getInt32(0);
  }

  static int twoBytesToInt({@required int byte1, @required int byte2}) {
    List<int> bytes = List.filled(4, 0, growable: false);
    bytes[2] = byte2;
    bytes[3] = byte1;
    var buffer = new Uint8List.fromList(bytes).buffer;
    var bdata = new ByteData.view(buffer);
    return bdata.getInt32(0);
  }
}
