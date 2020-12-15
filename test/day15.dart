import 'package:test/test.dart';

class History {
  final history = <int>[];
  final indexByValue = <int, List<int>>{};
  History(List<int> init) {
    history.addAll(init);
    var i = -1;
    for (var v in history) {
      i++;
      indexByValue[v] = [i];
    }
  }

  void next() {
    var prev = history.last;
    var indices = indexByValue.putIfAbsent(prev, () => <int>[]);
    late int next;
    if (indices.length <= 1) {
      next = 0;
    } else {
      next = indices.last - indices[indices.length - 2];
    }
    history.add(next);
    indexByValue.putIfAbsent(next, () => <int>[]).add(history.length - 1);
    // var prevIndex = history.reversed.skip(1).indexWhere((e) => e == prev);
    // history.add(prevIndex + 1);
  }
}

int part1(List<int> input) {
  var h = History(input);
  while (h.history.length < 2020) {
    h.next();
  }
  return h.history.last;
}

int part2(List<int> input) {
  var h = History(input);
  while (h.history.length < 30000000) {
    h.next();
  }
  return h.history.last;
}

extension IndexWhere<T> on Iterable<T> {
  int indexWhere(bool Function(T) test) {
    var i = this.iterator;
    var index = -1;
    while (i.moveNext()) {
      index++;
      if (test(i.current)) {
        return index;
      }
    }
    return -1;
  }
}

void main() {
  test('sample', () {
    var h = History([0, 3, 6]);
    h.next();
    expect(h.history.last, 0);
    h.next();
    expect(h.history.last, 3);

    expect(part1([1, 3, 2]), 1);
    expect(part1([2, 1, 3]), 10);
    expect(part2([0, 3, 6]), 175594);
  });

  test('part1', () {
    print(part1(input));
  });

  test('part2', () {
    print(part2(input));
  });
}

const input = [6, 4, 12, 1, 20, 0, 16];
