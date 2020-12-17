import 'dart:convert';

import 'dart:math';

import 'package:test/test.dart';

class Grid {
  /// x -> y -> z
  var values = <int, Map<int, Map<int, bool>>>{};
  int minX = 9223372036854775807;
  int maxX = -9223372036854775808;
  int minY = 9223372036854775807;
  int maxY = -9223372036854775808;
  int minZ = 9223372036854775807;
  int maxZ = -9223372036854775808;

  bool getValue(int x, int y, int z) =>
      values
          .putIfAbsent(x, () => <int, Map<int, bool>>{})
          .putIfAbsent(y, () => <int, bool>{})[z] ??
      false;

  void setValue(bool value, int x, int y, int z) {
    minX = min(minX, x);
    minY = min(minY, y);
    minZ = min(minZ, z);
    maxX = max(maxX, x);
    maxY = max(maxY, y);
    maxZ = max(maxZ, z);

    values
        .putIfAbsent(x, () => <int, Map<int, bool>>{})
        .putIfAbsent(y, () => <int, bool>{})[z] = value;
  }

  Grid evolve() {
    var result = Grid();
    for (var x = minX - 1; x <= maxX + 1; x++) {
      for (var y = minY - 1; y <= maxY + 1; y++) {
        for (var z = minZ - 1; z <= maxZ + 1; z++) {
          var value = getValue(x, y, z);
          var neighbors = countNeighbors(x, y, z);
          if (value) {
            if (neighbors >= 2 && neighbors <= 3) {
              result.setValue(true, x, y, z);
            }
          } else {
            if (neighbors == 3) {
              result.setValue(true, x, y, z);
            }
          }
        }
      }
    }
    return result;
  }

  void printGrid() {
    // for (var z = Z; z <= maxZ; z++) {
    var z = 0;
    print('z = $z');
    for (var y = minY; y <= maxY; y++) {
      var line = [
        for (var x = minX; x <= maxX; x++) getValue(x, y, z) ? '#' : '.'
      ].join('');
      print(line);
    }
    //}
  }

  int countNeighbors(int x, int y, int z) {
    var result = 0;
    for (var nx = x - 1; nx <= x + 1; nx++) {
      for (var ny = y - 1; ny <= y + 1; ny++) {
        for (var nz = z - 1; nz <= z + 1; nz++) {
          if (nx == x && ny == y && nz == z) {
            continue;
          }
          if (getValue(nx, ny, nz)) {
            result++;
          }
        }
      }
    }
    return result;
  }

  static Grid parse(String input) {
    var result = Grid();
    var lines = LineSplitter.split(input).toList();
    for (var y = 0; y < lines.length; y++) {
      var line = lines[y];
      for (var x = 0; x < line.length; x++) {
        result.setValue(line[x] == '#', x, y, 0);
      }
    }
    return result;
  }
}

class Grid4d {
  /// x -> y -> z -> w
  var values = <int, Map<int, Map<int, Map<int, bool>>>>{};
  int minX = 9223372036854775807;
  int maxX = -9223372036854775808;
  int minY = 9223372036854775807;
  int maxY = -9223372036854775808;
  int minZ = 9223372036854775807;
  int maxZ = -9223372036854775808;
  int minW = 9223372036854775807;
  int maxW = -9223372036854775808;

  bool getValue(int x, int y, int z, int w) =>
      values
          .putIfAbsent(x, () => <int, Map<int, Map<int, bool>>>{})
          .putIfAbsent(y, () => <int, Map<int, bool>>{})
          .putIfAbsent(z, () => <int, bool>{})[w] ??
      false;

  void setValue(bool value, int x, int y, int z, int w) {
    minX = min(minX, x);
    minY = min(minY, y);
    minZ = min(minZ, z);
    minW = min(minW, w);
    maxX = max(maxX, x);
    maxY = max(maxY, y);
    maxZ = max(maxZ, z);
    maxW = max(maxW, w);

    values
        .putIfAbsent(x, () => <int, Map<int, Map<int, bool>>>{})
        .putIfAbsent(y, () => <int, Map<int, bool>>{})
        .putIfAbsent(z, () => <int, bool>{})[w] = value;
  }

  Grid4d evolve() {
    var result = Grid4d();
    for (var x = minX - 1; x <= maxX + 1; x++) {
      for (var y = minY - 1; y <= maxY + 1; y++) {
        for (var z = minZ - 1; z <= maxZ + 1; z++) {
          for (var w = minW - 1; w <= maxW + 1; w++) {
            var value = getValue(x, y, z, w);
            var neighbors = countNeighbors(x, y, z, w);
            if (value) {
              if (neighbors >= 2 && neighbors <= 3) {
                result.setValue(true, x, y, z, w);
              }
            } else {
              if (neighbors == 3) {
                result.setValue(true, x, y, z, w);
              }
            }
          }
        }
      }
    }
    return result;
  }

  int countNeighbors(int x, int y, int z, int w) {
    var result = 0;
    for (var nx = x - 1; nx <= x + 1; nx++) {
      for (var ny = y - 1; ny <= y + 1; ny++) {
        for (var nz = z - 1; nz <= z + 1; nz++) {
          for (var nw = w - 1; nw <= w + 1; nw++) {
            if (nx == x && ny == y && nz == z && nw == w) {
              continue;
            }
            if (getValue(nx, ny, nz, nw)) {
              result++;
            }
          }
        }
      }
    }
    return result;
  }

  static Grid4d parse(String input) {
    var result = Grid4d();
    var lines = LineSplitter.split(input).toList();
    for (var y = 0; y < lines.length; y++) {
      var line = lines[y];
      for (var x = 0; x < line.length; x++) {
        result.setValue(line[x] == '#', x, y, 0, 0);
      }
    }
    return result;
  }
}

int part1(String input) {
  var grid = Grid.parse(input);
  var cycles = 6;
  while (cycles > 0) {
    cycles--;
    grid = grid.evolve();
  }
  return grid.values.values
      .expand((yz) => yz.values.expand((z) => z.values))
      .where((v) => v)
      .length;
}

int part2(String input) {
  var grid = Grid4d.parse(input);
  var cycles = 6;
  while (cycles > 0) {
    cycles--;
    grid = grid.evolve();
  }
  return grid.values.values
      .expand((yzw) => yzw.values.expand((zw) => zw.values))
      .expand((w) => w.values)
      .where((v) => v)
      .length;
}

void main() {
  test('sample', () {
      expect(part1('.#.\n..#\n###'), 112);
      expect(part2('.#.\n..#\n###'), 848);
  });

  test('part1', () {
    print(part1(input));
  });

  test('part2', () {
    print(part2(input));
  });
}

const input = '''..#....#
##.#..##
.###....
#....#.#
#.######
##.#....
#.......
.#......''';
