T getOrNull<T>(List<T> list, int index) =>
    index < 0 || index >= list.length ? null : list[index];

Iterable<int> range(int end, {int start = 0, int step = 1}) sync* {
  for (int i = start; i < end; i += step) yield i;
}

/// Average two signed ints while avoiding possible overflow.
int average2(int a, int b) =>
    (a ~/ 2) + (b ~/ 2) + ((a < 0 == b < 0) ? (a & b & 1) : (a & b ^ 1));
