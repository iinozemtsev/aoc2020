import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:charcode/charcode.dart';

var debug = true;
void log(String text) {
  if (!debug) {
    return;
  }
  print(text);
}

class Game {
  final List<int> cups;
  final int totalCupCount;
  int currentCupIndex = 0;
  Game(this.cups) : totalCupCount = cups.length;

  String get state =>
      cups.mapIndexed((i, e) => i == currentCupIndex ? '($e)' : '$e').join(' ');
  void turn() {
    /* The crab picks up the three cups that are immediately clockwise of the
    current cup. They are removed from the circle; cup spacing is adjusted as
    necessary to maintain the circle. */
    var currentCupValue = cups[currentCupIndex];
    log('cups: $state');
    var picked = <int>[];
    for (var i = 0; i < 3; i++) {
      var removeIndex = currentCupIndex + 1;
      if (removeIndex < cups.length) {
        picked.add(cups.removeAt(removeIndex));
      } else {
        picked.add(cups.removeAt(0));
        currentCupIndex--;
      }
    }
    log('pick up: ${picked.join(' ')}');

    /* The crab selects a destination cup: the cup with a label equal to the
    current cup's label minus one. */
    var destinationLabel = cups[currentCupIndex] - 1;
    if (destinationLabel == 0) {
      destinationLabel = totalCupCount;
    }

    /*If this would select one of the cups that was just picked up, the crab
    will keep subtracting one until it finds a cup that wasn't just picked up.
    If at any point in this process the value goes below the lowest value on any
    cup's label, it wraps around to the highest value on any cup's label
    instead.*/
    while (picked.contains(destinationLabel)) {
      destinationLabel--;
      if (destinationLabel == 0) {
        destinationLabel = totalCupCount;
      }
    }
    log('destination: $destinationLabel');

    /* The crab places the cups it just picked up so that they are immediately
    clockwise of the destination cup. They keep the same order as when they were
    picked up.*/
    var destinationIndex = cups.indexOf(destinationLabel);
    cups.insertAll(destinationIndex + 1, picked);

    /* The crab selects a new current cup: the cup which is immediately
    clockwise of the current cup.*/

    currentCupIndex = cups.indexOf(currentCupValue) + 1;
    if (currentCupIndex == totalCupCount) {
      currentCupIndex = 0;
    }
  }

  void turns(int count) {
    for (var i = 0; i < count; i++) {
      log('-- move ${i + 1} --');
      turn();
    }
    log('-- final --');
    log('cups: $state');
  }

  String get labelsAfterOne {
    var oneIndex = cups.indexOf(1);
    var shifted = <int>[];
    if (oneIndex < cups.length - 1) {
      shifted.addAll(cups.getRange(oneIndex + 1, cups.length));
    }
    if (oneIndex > 0) {
      shifted.addAll(cups.getRange(0, oneIndex));
    }
    return shifted.join('');
  }
}

int part2(String input, [int iterations = 10 * 1000 * 1000]) {
  var cups = [
    ...input.codeUnits.map((u) => u - $0),
    ...List.generate(1000000 - 9, (i) => i + 10)
  ];
  var loop = <int, int>{};
  for (var i = 1; i < cups.length; i++) {
    loop[cups[i - 1]] = cups[i];
  }
  loop[cups[cups.length - 1]] = cups[0];
  print(cups.length);
  print(loop.length);

  var current = cups.first;
  for (var iter = 0; iter < iterations; iter++) {
    var picked = <int>[];
    var next = current;
    for (var i = 0; i < 3; i++) {
      next = loop[next]!;
      picked.add(next);
    }

    var destination = current;
    while (true) {
      destination--;
      if (destination < 1) {
        destination = loop.length;
      }
      if (!picked.contains(destination)) {
        break;
      }
    }
    var tmp = loop[picked.last]!;
    loop[picked.last] = loop[destination]!;
    loop[destination] = picked.first;
    loop[current] = tmp;
    current = loop[current]!;
  }
  var a = loop[1]!;
  var b = loop[a]!;
  return a * b;
}

String part1(String input, int turns) {
  var cups = <int>[];
  for (var i = 0; i < input.length; i++) {
    cups.add(int.parse(input[i]));
  }
  var game = Game(cups);
  game.turns(turns);
  return game.labelsAfterOne;
}

void main() {
  test('sample', () {
    expect(part1('389125467', 10), '92658374');
  });

  test('part1', () {
    debug = false;
    print(part1('538914762', 100));
  });

  test('part2', () {
    print(part2('538914762'));
  });
}
