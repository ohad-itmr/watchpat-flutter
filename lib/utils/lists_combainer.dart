class ListCombainer {
  static List<int> combain(List<List<int>> list, {int requiredLength}) {
    List<int> result = list.expand((f) => f).toList();
    if (requiredLength != null && requiredLength - result.length > 0) {
      List<int> tempList = List.filled(requiredLength, 0,growable: true);
      tempList.replaceRange(0, result.length, result);
      return tempList;
    }
    return result;
  }
}
