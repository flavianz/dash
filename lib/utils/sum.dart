extension Sum on Iterable<num> {
  num sum() {
    num val = 0;
    for (num value in this) {
      val += value;
    }
    return val;
  }
}
