extension DateExtension on DateTime {
  String get monthAbbreviation {
    return switch (month) {
          1 => "JAN",
          2 => "FEB",
          3 => "MÄR",
          4 => "APR",
          5 => "MAI",
          6 => "JUN",
          7 => "JUL",
          8 => "AUG",
          9 => "SEP",
          10 => "OKT",
          11 => "NOV",
          12 => "DEZ",
          _ => "ERR",
        } +
        (year == DateTime.now().year ? "" : " ${year - 2000}");
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && other.day == day;
  }
}
