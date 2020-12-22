import 'dart:collection';

import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:test/test.dart';

const intListEquality = ListEquality<int>();
var debug = true;
void log(String text) {
  if (!debug) {
    return;
  }
  print(text);
}

var nextGameId = 0;

class Game {
  final Player p1;
  final Player p2;
  late int gameIndex;
  var roundIndex = 1;
  Game(this.p1, this.p2) {
    gameIndex = nextGameId++;
  }

  static Game parse(String input) {
    nextGameId = 1;
    var players = input.split('\n\n').map(Player.parse).toList();
    return Game(players.first, players.last);
  }

  /// Returns `true` if game is over.
  bool turn() {
    if (p1.cards.isEmpty || p2.cards.isEmpty) {
      return true;
    }
    log('Player 1\'s desk: ${p1.cards.join(', ')}');
    log('Player 2\'s desk: ${p2.cards.join(', ')}');
    var c1 = p1.cards.removeFirst();
    var c2 = p2.cards.removeFirst();

    log('Player 1 plays: $c1');
    log('Player 2 plays: $c2');
    if (c1 > c2) {
      log('Player 1 wins the round!');
      p1.cards.addLast(c1);
      p1.cards.addLast(c2);
    } else {
      log('Player 2 wins the round!');
      p2.cards.addLast(c2);
      p2.cards.addLast(c1);
    }
    return false;
  }

  var visitedStates = EqualitySet<List<int>>(intListEquality);

  /// Returns a winner if game is over.
  Player? recursiveTurn() {
    log('-- Round ${roundIndex++} (Game $gameIndex)');
    var state = [...p1.cards, -1, ...p2.cards];
    if (!visitedStates.add(state)) {
      return p1;
    }
    log('Player 1\'s desk: ${p1.cards.join(', ')}');
    log('Player 2\'s desk: ${p2.cards.join(', ')}');
    var c1 = p1.cards.removeFirst();
    var c2 = p2.cards.removeFirst();

    log('Player 1 plays: $c1');
    log('Player 2 plays: $c2');

    late Player winner;
    if (p1.cards.length >= c1 && p2.cards.length >= c2) {
      // Recursive combat!
      var p1copy = Player(p1.name)..cards.addAll(p1.cards.take(c1));
      var p2copy = Player(p2.name)..cards.addAll(p2.cards.take(c2));
      var w = Game(p1copy, p2copy).recursiveGame();
      winner = w == p1copy ? p1 : p2;
    } else {
      if (c1 > c2) {
        winner = p1;
      } else {
        winner = p2;
      }
    }

    if (winner == p1) {
      log('Player 1 wins the round!');
      p1.cards.addLast(c1);
      p1.cards.addLast(c2);
    } else {
      log('Player 2 wins the round!');
      p2.cards.addLast(c2);
      p2.cards.addLast(c1);
    }
    if (p1.cards.isEmpty) {
      return p2;
    }
    if (p2.cards.isEmpty) {
      return p1;
    }
  }

  Player recursiveGame() {
    Player? result;
    while (result == null) {
      result = recursiveTurn();
    }
    return result;
  }

  void play() {
    while (!turn()) {}
  }
}

int part1(String input) {
  var game = Game.parse(input);
  game.play();
  return math.max(game.p1.getScore(), game.p2.getScore());
}

int part2(String input) => Game.parse(input).recursiveGame().getScore();

class Player {
  final String name;
  final cards = Queue<int>();

  Player(this.name);

  static Player parse(String input) {
    var lines = LineSplitter.split(input);
    var name = lines.first.substring(0, lines.first.length - 1);
    var player = Player(name);
    for (var line in lines.skip(1)) {
      player.cards.addLast(int.parse(line));
    }
    return player;
  }

  int getScore() {
    var result = 0;
    while (cards.isNotEmpty) {
      result += cards.length * cards.removeFirst();
    }
    return result;
  }
}

void main() {
  test('sample', () {
    expect(part1('Player 1:\n9\n2\n6\n3\n1\n\nPlayer 2:\n5\n8\n4\n7\n10'), 306);
    expect(part2('Player 1:\n9\n2\n6\n3\n1\n\nPlayer 2:\n5\n8\n4\n7\n10'), 291);
  });

  test('part1', () {
    debug = false;
    print(part1(input));
  });

  test('part2', () {
    debug = false;
    print(part2(input));
  });
}

const input = '''Player 1:
50
14
10
17
38
40
3
46
39
25
18
2
41
45
7
47
36
1
30
32
8
31
12
5
28

Player 2:
9
6
37
42
22
4
21
15
44
16
29
43
19
11
13
24
48
35
26
23
27
33
20
49
34''';

