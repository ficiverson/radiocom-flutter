class SafeMap {
  static String safe(Map<String, dynamic> receiver, List<String> keys) {
    try {
      var tempMap = Map.identity();
      var result = "";
      keys.forEach((key) {
        if (receiver.containsKey(key) &&
            receiver[key] != null &&
            !(receiver[key] is String)) {
          tempMap = receiver[key];
        } else if ((tempMap.isNotEmpty &&
            tempMap.containsKey(key) &&
            tempMap[key] != null &&
            tempMap[key] is String)) {
          result = tempMap[key];
        } else if (receiver.containsKey(key) &&
            receiver[key] != null &&
            receiver[key] is String) {
          result = receiver[key];
        } else {
          result = "";
        }
      });
      return result;
    } catch (exception) {
      return "";
    }
  }
}
