class Crc16 {
  static int convert(List<int> data) {
    int location = 0;
    bool bit;
    int c;
    int len = data.length;
    int crc = 0xFFFF;

    while ((len--) > 0) {
      c = data[location];
      location++;
      for (int i = 0x80; i > 0; i >>= 1) {
        bit = (crc & 0x8000) != 0;
        if ((c & i) != 0) {
          bit = !bit;
        }
        crc <<= 1;
        if (bit) {
          crc ^= 0x1021;
        }
      }
      crc &= 0xffff;
    }
    return (crc & 0xffff);
  }
}
