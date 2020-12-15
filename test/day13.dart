import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

class Problem {
  int arrival;
  List<int> buses;

  Problem(this.arrival, this.buses);
  static Problem parse(String input) {
    var lines = LineSplitter.split(input);
    var arrival = int.parse(lines.first);
    var buses = lines.last.split(',').map(int.tryParse).whereNotNull().toList();
    return Problem(arrival, buses);
  }
}

int nextDeparture(int from, int interval) {
  var cycles = from.toDouble() / interval;
  return cycles.ceil() * interval;
}

int part1(String input) {
  var p = Problem.parse(input);
  var earliestDeparture = 9223372036854775807;
  var bus = -1;
  for (var id in p.buses) {
    var d = nextDeparture(p.arrival, id);
    if (d < earliestDeparture) {
      earliestDeparture = d;
      bus = id;
    }
  }
  return (earliestDeparture - p.arrival) * bus;
}

class Bus {
  int? id;
  int offset;
  Bus(this.id, this.offset);
}

int part2(String input) {
  var strs = LineSplitter.split(input).last.split(',').toList();
  var buses = <Bus>[];
  for (var i = 0; i < strs.length; i++) {
    buses.add(Bus(int.tryParse(strs[i]), i));
  }

  // Find x, where:
  // x % input[0] == 0
  // x % input[1] == 1

  // Find the biggest bus id.
  Bus? maxBus;
  for (var i = 0; i < buses.length; i++) {
    maxBus ??= buses[i];
    if (buses[i].id != null && buses[i].id! > maxBus.id!) {
      maxBus = buses[i];
    }
  }

  // var nums = <int>[];
  // for (var bus in buses) {
  //   if (bus.id != null) {
  //     nums.add(bus.id! + bus.offset);
  //   }
  // }
  // var result = lcm(nums);
  // return result;
  var candidate = maxBus!.id!;
  // print('${maxBus.id!} ${maxBus.offset}');
  while (true) {
    if (matchesPart2(candidate - maxBus.offset, buses)) {
      return candidate - maxBus.offset;
    }
    candidate += maxBus.id!;
  }
}

int lcm(List<int> nums) => nums.fold(1, (r,e) =>  lcm2(r,e));

int lcm2(int num1, int num2) {
  return num1 ~/ num2.gcd(num1) *  num2;
}

bool matchesPart2(int candidate, List<Bus> buses) {
  for (var bus in buses) {
    if (bus.id == null) {
      continue;
    }
    if ((candidate + bus.offset) % bus.id! != 0) {
      return false;
    }
  }
  return true;
}

void main() {
  test('sample', () {
    expect(part1('939\n7,13,x,x,59,x,31,19'), 295);
    expect(part2('17,x,13,19'), 3417);
  });

  test('part1', () {
    print(part1(input));
  });

  test('part2', () {
    print(part2(input));
  });
}

const input = '''1015292
19,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,743,x,x,x,x,x,x,x,x,x,x,x,x,13,17,x,x,x,x,x,x,x,x,x,x,x,x,x,x,29,x,643,x,x,x,x,x,37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,23''';
