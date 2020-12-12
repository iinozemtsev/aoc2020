import 'dart:convert';
import 'dart:math';

import 'package:test/test.dart';

class Ship {
  int x = 0;
  int y = 0;
  // direction of a ship, counterclockwise
  int direction = 0;

  void run(String command) {
    var cmd = command.substring(0, 1);
    var value = int.parse(command.substring(1));
    switch (cmd) {
      case 'N':
        y += value;
        break;
      case 'S':
        y -= value;
        break;
      case 'E':
        x += value;
        break;
      case 'W':
        x -= value;
        break;
      case 'L':
        direction += value;
        break;
      case 'R':
        direction -= value;
        break;
      case 'F':
        forward(value);
        break;
      default:
        throw ArgumentError('unsupported command $command');
    }
  }

  void runAll(String commands) {
    for (var command in LineSplitter.split(commands)) run(command);
  }

  void forward(int value) {
    direction %= 360;
    // For now, support only straight directions.
    var angle = direction.toDouble() / 360 * 2 * pi;
    var dx = cos(angle).round().toInt();
    var dy = sin(angle).round().toInt();
    if (dx.abs() + dy.abs() != 1) {
      throw StateError('Unsupported direction $direction');
    }
    x += dx * value;
    y += dy * value;
  }
}

class Ship2 {
  int x = 0;
  int y = 0;
  int wx = 10;
  int wy = 1;
  // direction of a ship, counterclockwise
  int direction = 0;

  void run(String command) {
    var cmd = command.substring(0, 1);
    var value = int.parse(command.substring(1));
    switch (cmd) {
      case 'N':
        wy += value;
        break;
      case 'S':
        wy -= value;
        break;
      case 'E':
        wx += value;
        break;
      case 'W':
        wx -= value;
        break;
      case 'L':
        rotate(value);
        break;
      case 'R':
        rotate(-value);
        break;
      case 'F':
        forward(value);
        break;
      default:
        throw ArgumentError('unsupported command $command');
    }
  }

  void runAll(String commands) {
    for (var command in LineSplitter.split(commands)) run(command);
  }

  void rotate(int value) {
    // Move ship to the center of coordinates.
    var wx0 = wx - x;
    var wy0 = wy - y;
    var length = sqrt(wx0 * wx0 + wy0 * wy0);
    // Calculate an angle
    var angle = atan2(wy0, wx0);
    angle += value.toDouble() / 360 * 2 * pi;

    // Calculate new coords
    var wx1 = cos(angle) * length;
    var wy1 = sin(angle) * length;

    // Back to real coords
    wx = x + wx1.round().toInt();
    wy = y + wy1.round().toInt();
  }

  void forward(int value) {
    var dx = wx - x;
    var dy = wy - y;
    x += dx * value;
    y += dy * value;
    wx = x + dx;
    wy = y + dy;
  }
}

int part1(String input) {
  var ship = Ship();
  ship.runAll(input);
  return ship.x.abs() + ship.y.abs();
}

int part2(String input) {
  var ship = Ship2();
  ship.runAll(input);
  return ship.x.abs() + ship.y.abs();
}

void main() {
  test('sample', () {
    expect(part1('''F10
N3
F7
R90
F11'''), 25);
    expect(part2('''F10
N3
F7
R90
F11'''), 286);
  });
  test('part1', () {
    print(part1(input));
  });
  test('part2', () {
    print(part2(input));
  });
}

const input = '''F36
L90
S5
F67
W3
R90
F67
R90
E1
S5
W2
N1
E1
F21
S4
E2
S5
R90
N1
F69
R180
N3
F40
E1
S3
R90
S1
R90
F100
W3
F82
N2
W2
F47
W5
F77
W5
R90
N2
W2
F34
N3
E3
F54
L90
S1
E3
R90
F9
R90
E1
N1
F91
L90
S4
W5
S3
L90
W3
F6
L180
N5
F34
E2
L90
F84
L90
W5
L90
W2
N2
E4
L270
F31
N1
R90
N1
W4
L90
F72
S4
F2
L90
F92
N4
E5
F88
R180
E1
S4
E1
S1
F9
N2
W2
L90
F61
R90
F93
S3
L90
W3
F26
E1
L90
E4
S3
R270
N2
F39
R180
S4
E4
F65
S4
R180
S2
F46
W5
R90
E4
L90
F98
W4
R90
E2
R180
F14
L90
S1
F8
S3
L90
N3
F11
S2
L90
W3
S3
L90
W1
L90
F64
S2
E2
N4
W3
F38
E3
N2
F19
S2
L90
E2
F94
E1
R90
E2
S5
L90
F6
E3
S4
L180
W5
R90
N3
W3
S5
F24
L90
F1
W4
F47
W2
S1
E1
S2
E1
N4
L180
F61
W2
F20
E5
S3
F37
F6
L90
E1
R90
W5
S2
L90
E2
N2
L90
F50
W2
F49
R90
S1
R180
S5
R90
S1
E4
R90
F65
L90
S5
E1
F61
S2
F40
L90
E5
R90
E5
L90
S1
F67
S2
F48
R270
E4
F35
S5
F14
L180
E3
L90
F64
W3
R90
E2
R90
S3
L90
S2
W4
F94
R180
N1
W1
R90
F41
R90
N1
L90
W2
N2
R90
F43
N1
L180
F6
E4
F99
N1
F54
N3
R90
F57
W5
F16
S5
L90
E5
R90
S4
L90
F68
L180
S1
E4
R90
F88
S2
F19
R90
W2
W1
F62
S2
R90
N3
R180
S5
E4
F41
W2
S5
W1
R90
W2
W4
L90
S4
R90
F1
W5
F44
W3
N2
F41
W5
L90
N5
W1
F13
E2
R90
N3
W3
F8
W1
R90
F51
R90
E1
S5
F18
S2
E3
F23
L180
F26
N2
F25
E4
F24
E5
N1
L90
S1
E5
R90
F88
S2
W3
R90
F30
L90
E4
L270
S1
E2
F87
W4
N1
R180
N1
F2
L90
S3
F29
S4
L90
N2
F59
L90
W2
N5
F45
N2
W4
N4
F27
W5
F4
S2
F56
L180
S2
R90
W4
F95
L90
R90
F68
L90
S4
W5
F46
N1
W2
F80
R270
F35
L90
E3
S5
R90
S1
W2
F53
S3
R180
F38
F57
W1
R90
N1
W4
S3
R180
E1
F24
S5
F96
W4
F53
S4
F59
F7
E5
S2
L90
E2
L90
N5
L90
N3
F75
S2
R180
N1
W3
N3
R90
F71
L180
S4
L90
F53
S5
L90
N5
S5
F14
L90
E3
F40
N1
E3
N2
F69
W1
N5
W3
S3
R90
N3
F3
S5
E1
R90
E5
F16
R90
F94
E2
L180
F16
E2
F71
W1
F4
L90
W4
F45
L90
S3
W3
S5
R90
E3
N1
W1
S3
L90
W2
W1
S5
F1
L90
E3
L180
S5
F5
W1
L90
N5
E5
R90
E2
R90
W5
R90
F11
W5
S2
E5
R90
F29
W5
S5
F14
S4
L90
F48
R180
F63
E4
N4
E5
W5
S4
W5
S5
F9
L270
W3
F78
W2
F100
W2
N4
F44
F11
E2
F17
E4
F80
S5
F36
L90
W2
F12
L90
N4
E3
S5
F90
F73
W1
S3
W4
F50
N4
N3
F79
W5
F38
L90
W5
S3
F50
R90
L270
R180
F84
L180
E2
R180
N3
N3
W5
S3
L180
N3
E1
N4
N5
F23
N2
E1
N1
E3
F64
E4
F4
R90
S4
E5
S2
L90
E3
F32
W1
N2
F20
E4
W5
F93
E5
N1
W4
F18
E1
N1
F7
N3
F55
E3
F91
W4
F86
N5
W1
F38
N4
R180
W4
S5
F95
R180
F22
R90
F58
W3
F62
L90
F17
S2
R90
N5
L90
N4
E1
N1
E2
E4
R180
F72
N4
E4
R180
F74
W5
N5
W5
N5
W2
F26
S2
E4
N4
F23
E2
F95
E1
N4
E1
L270
S3
E3
R90
S2
E5
R180
F73
S5
W1
F61
F60
E2
F97
S2
L90
W5
R180
F99
R180
F52
N1
L180
S4
W4
R180
F70
S4
L90
S5
W2
L90
N2
W5
F31
L90
E3
F87
L90
S2
W4
F25
L180
F50
S5
E1
F75
N2
F30
S4
F100
E3
L180
F57
L90
W5
R90
W2
F65
L90
F29
E4
L270
E3
L90
N4
E2
E5
F36
N4
E4
N4
F41
E2
S3
F72
W4
F26
L90
E5
R90
N4
F97
L90
W1
F31
N2
L90
E3
N5
L90
F5
R180
F97
S1
E5
N4
R90
F77
N2
F92
S5
F84
E3
S3
L270
N3
R180
N4
F63
N4
E5
F62
S3
F54
N2
E5
F89
R90
S4
F95
F56
L90
S4
L90
S4
R180
F93''';