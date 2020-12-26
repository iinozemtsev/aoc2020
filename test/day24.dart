import 'dart:convert';
import 'dart:math' as math;

import 'package:aoc_2020/fields.dart';
import 'package:test/test.dart';

var debug = false;
void log(String text) {
  if (!debug) {
    return;
  }
  print(text);
}

enum Direction {
  east,
  southEast,
  southWest,
  west,
  northWest,
  northEast,
}

const directionToOffset = {
  Direction.east: Offset(1, 0),
  Direction.west: Offset(-1, 0),
  Direction.southWest: Offset(0, -1),
  Direction.northEast: Offset(0, 1),
  Direction.southEast: Offset(1, -1),
  Direction.northWest: Offset(-1, 1),
};

List<Direction> parsePath(String input) {
  var result = <Direction>[];
  while (input.isNotEmpty) {
    if (input.startsWith('ne')) {
      result.add(Direction.northEast);
      input = input.substring(2);
    } else if (input.startsWith('nw')) {
      result.add(Direction.northWest);
      input = input.substring(2);
    } else if (input.startsWith('se')) {
      result.add(Direction.southEast);
      input = input.substring(2);
    } else if (input.startsWith('sw')) {
      result.add(Direction.southWest);
      input = input.substring(2);
    } else if (input.startsWith('e')) {
      result.add(Direction.east);
      input = input.substring(1);
    } else if (input.startsWith('w')) {
      result.add(Direction.west);
      input = input.substring(1);
    } else {
      throw ArgumentError('cannot parse path "$input"');
    }
  }
  return result;
}

Position pathToPosition(Position start, List<Direction> path) =>
    path.fold(start, (r, e) => r + directionToOffset[e]!);

class Floor {
  // X is west-east
  // Y  is southWest-northEast
  final tiles = <int, Map<int, bool>>{};

  // false is white.
  bool getTile(int x, int y) => (tiles[x] ?? <int, bool>{})[y] ?? false;
  void setTile(int x, int y, bool value) {
    tiles.putIfAbsent(x, () => <int, bool>{})[y] = value;
    minX = math.min(x, minX);
    minY = math.min(y, minY);
    maxX = math.max(x, maxX);
    maxY = math.max(y, maxY);
  }

  int minX = 0;
  int maxX = 0;
  int minY = 0;
  int maxY = 0;

  void flip(Position p) => setTile(p.x, p.y, !getTile(p.x, p.y));

  int get blackCount =>
      tiles.values.expand((v) => v.values).where((v) => v).length;

  Floor nextDay() {
    var result = Floor();
    for (var x = minX - 1; x <= maxX + 1; x++) {
      for (var y = minY - 1; y <= maxY + 1; y++) {
        var value = getTile(x, y);
        var neighbors = countNeighbors(x, y);
        if (value /*black*/ && (neighbors == 0 || neighbors > 2)) {
          result.setTile(x, y, false);
        } else if (!value /*white*/ && neighbors == 2) {
          result.setTile(x, y, true);
        } else {
          result.setTile(x, y, value);
        }
      }
    }
    return result;
  }

  Floor after(int days) {
    var result = this;
    for (var i = 0; i < days; i++) {
      result = result.nextDay();
      log('Day ${i + 1}: ${result.blackCount}');
    }
    return result;
  }

  int countNeighbors(int x, int y) {
    var result = 0;
    for (var dto in directionToOffset.values) {
      if (getTile(x + dto.dx, y + dto.dy)) {
        result++;
      }
    }

    return result;
  }
}

int part1(String input) {
  var paths = LineSplitter.split(input).map(parsePath).toList();
  var floor = Floor();
  for (var path in paths) {
    floor.flip(pathToPosition(Position(0, 0), path));
  }
  return floor.blackCount;
}

int part2(String input) {
  var paths = LineSplitter.split(input).map(parsePath).toList();
  var floor = Floor();
  for (var path in paths) {
    floor.flip(pathToPosition(Position(0, 0), path));
  }
  floor = floor.after(100);
  return floor.blackCount;
}

void main() {
  test('sample', () {
    expect(part1(sampleInput), 10);
    expect(part2(sampleInput), 2208);
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

const input = '''wswwwwwwwnenewswnewswwswswww
wsenenwswnwwnenwswwsenwwwnenwwnww
eenwenewwswsweeneswswseeeeneee
nweenesenwnenenwnenenwnwnwnwnwnwswswnwnw
swwnwwwwwwewnwewwswswswswe
nwnenwnenenenwnwneenenenwnwswswnwnenwesenw
seneswwswseswseseseseenwsenesesenewnw
nwnwwnwnwnwenwnwnenwnwnwnw
swnwnenweswwswnwsenwnewnweswseneeesesw
eenesewnwswwnweswneswseenwswsw
neeseswsesesweseseeseseeeseeenwe
wneswnenweseseswwwwesenwnwnenwwe
senenwneneneswneneneenwneneeeneenene
neneswwseneneneneeeneneneenenenene
eeseeenwnwseeneneswneeeeewewe
eeeeeesweeseeswnweeeeeenwse
nwnwnwnwneeswneswswwwsewswnenwnwwwnw
nwswneswswsenewnewswwswwswswwswswesesw
eneseneeneswwwneeseneneenweneneee
neneneenenenwenewnenwnwnenesenewnene
wnwwnwnwnwwwnwnwnwswenwnewnwenwnwnw
nwwseneenenenwneswnenenw
seeseneneeneseewneenewnwsenwwnee
seswseswseseseseswseswseseswsenwsenwseswnw
eeweswneeeeneeswnwnweneeenesenee
swswswswswswnwwswseswnwswwseswne
eneeeeesenesewnwwenweseenenee
nenwnenwseewnenwnenenenenene
seswseseneseswnwswseeenwseswwswsesesese
nwenwsenwwsenwsenwnwnwnewnwnw
nwnweswnwnwnwnwnwnwnwnwnwwnwnwsenwwnwe
wneneeneneeeeeeeeeeswwesenee
nwnwewswnwnwsenewnweseseenesenewnenww
swswswswswswswswswwsweeenweswwnwswnwsw
neneswswwweswswsewwwswwswwswswswnw
wneswwwseenwewnwwnwswwwswwswwsew
nwenwswnwnwneswnenenwsewswnwnwnwsenwnwnw
eseswsesesesenwseenwseseee
swseswswsweseswswswwneswseswswnwswsesewse
nenenenwwneenenenenenenenenenwne
nenenwnenwnenenesenenewnwnenw
nenwswseswseeswswswswseseww
swswwswswswwswswswswswswswsewswnewe
weneswnenwnwsenenenewnenenweswwnenenw
neweswseneseswswswswswswsww
wsewsewswwnwnewnwnwswswewswwwwsew
wneseswneswenwwewnenwneneneneesenw
nwnwneeeswnwnenwwswnwnwnenwnwenwnwewsw
swneseseenewneneneewnenesenewesewnw
sesesesenwsenwseseswwseseneeeenwsewe
seenwesweeeesweeseenwese
wwnwnwnewwenwwnwswwwwnwnwseww
esweswswswneenenwnenesw
wswwwwswwsweswwwwwwwnewnwsw
eeeseeeesenwseswseeeeseenweesw
enwsewnweeeeenwseswenwenweseswe
wswswswswwswseswneswswwneswswswwswne
seneseneseswwsesesenesewswswsesesesese
eeseeseeneenweseneswneewswwsese
swswsewwneswswwnww
seseseeseneesesewsesesewseseseseese
seseneseswseswsesewseseseswsese
weeswnwseseswenewseenenenwewwesw
nwswswswswsesweswswswswswseweswswswsw
swseswsenwnwseseseeesesenwnwseseseesese
nwwswwswswswswswnwwwwseswseseneswsw
enwswnwseeeeeenwswnwnwseneswewsw
wwswswwswwwswsenwwwswswswsw
swswsewnwnwseswwswswwnewwwswwseww
wwnwnenwwwsenwnwwewwsewwww
swnwsenenwnenwnesewneneneneneswsw
nwnwwwwneswsenenwnwnwsewwwnwenwnww
seseseseeeewseeenese
seseswnwwseseseswswseseseseneseseseneswse
nwnenwnwnenwnenenewenenwwsenwnenwnese
nwnwwnwewnewnwnweenwswnwnw
nwnwsewwnwnwsenwwwwwnwwnw
eeeeneneeeenew
wwswwwswwnwneswse
wswswswswwswnewwwneswwwwseswwsw
eseesenwsenweseeesewsesenwseesesw
eseswenweeenwswsenweseneeswweeene
nwnwnenesenwwenwnwsweneneenwswsenwnwswe
swsenwsenwenewnewsesewwnwenwwsenwnw
wswwseswsenwswswsweseswsesweswswseeswse
eneswnenwwswneswneneneneeeneenenenene
enwnwnwnwwnwnwwnwenwnwnwnwwsenwnwnwnw
nwnwsewnwnwnwnwnwnwnwnwnenwnwnw
nenesewwswswneewswswneneseswsenwseswsw
nwnwnwswnwenesenwnwnenwnwwnwnwnwnwneeww
swnwnwnenenwenwnwnenenwnenwnenwnwswnenw
nenenenenenenwnenwneneneseswsw
nwenwneswnenenenwnwnwnw
swneeswswnwsewnwwswswswswswswwwsesw
wwenwnwwsenwwwwnenwswwnwwnwnenww
sweswswswwswswswwswwewnwswwsww
nenwnwnwnwnenwswnenenwnwnwnwnw
nwnenwnesenewneenwnwsenenwnwswwnesenwne
nenwwwwwwwwswwwwnw
nwsenwswseseseseseseeswnewseswseesesesese
newwneneneseeneeeeeeneeswenenw
sweeeeeeeeenwsweeneneeenwesw
swwwnenwenenwswnwswseesesenwwsewnese
seswwswswnwseseswseseseeneseswnenweswwse
nwnwesenenwnenwsesweswnwnwnesenwsww
sesesewneenenwnwnwneeenwenesenee
nwswneenwnwsenesenwwnenwnwnenewnwnwnenwnw
wneneswnwneeneeneneneeweneeeeene
wwewnwwwwwwnw
wnenwnwsewwnesenwnwnwsewswenwwwse
swwswsesenwswswseeswseswswswnenwsw
seewwsesewseswseneseswswseswseseswnwe
nenwnwswweweseesewesewseeeeee
sweeneseesweeneesenwsweewneeese
nwneeeswswwnenenenenesenwnwnenwnwnene
wwwswsewwwwswewwneswwwwswsw
nwnwnewsweneneseswnwnwnwnwnenw
sweseneswwswseseseswseswseswseswnwsese
sweswswnwswnwseswwswnwswewsweswneswsw
swneswwwsweswswneseswwwwswnewwwwsw
esweewweweeeeeeneeeeeee
wwnwnwswenwnwnenwnenwsenwnwnwnwsenwnw
nwnwnwnwnwenenwnwnwwnwnwnwswnwnwnwe
wnwwwweweswwswnwswwwwswesww
seseseseseseeseeeeeneseswnwewse
seswswswswwsewswene
nwwwwnewswwwnww
eseeneseeenwswnenesweeenweenwnwene
newwnwwnwswsewswswnwnenwwwnewwenw
seeeweseswwswsenwnenweeenwsesewne
newwseeeswneeene
neneneneneneneneneswnenenenenewnenenese
wnwswenwswnwnwnwnwnenwnwnwnw
swseseesenwwseswseweswseswnwsesweswsw
sesenwseseseseeweeseesesesweseese
sewswnesenwseswnwseseenese
wwnewewswseswenweewwwnew
wswnenenwswswswswnesenwseneseswnwswswse
nwsesenenenweseneneseswwwnewwswewsenw
swnewwneswewwwswweenwswwnwwnw
nenwswnwseseswswsweswswnewwsenwswesesese
newseeneneneenewneswnesewnwenwneeswne
nwswwesewwwneswswswwwwwswwwew
wwewwwwwswnewwwnwewwwwww
eseeeeeeneseeeewseseneswseesew
nwnweeswseneenenwwseesewewsweee
seewwwswnwnwswseswweswwwneswwswnw
nwnwwswenwswnwenweswnwswnenwnenwnwne
wswswswwwnewswwwwwseewswwwsw
enwweneeneneneneeenewnesweseneee
senewnesweneneeeeeeeeewnwenese
neeswneseeeeeswneneneswenwwww
eeseseeswseeeseneeeeesewenee
senwseneseseseseseeswsenwsesesesesesw
swswswnwswswsesweswswswswenwnw
eswswswswswwwswswsweseswswswnesenwsw
wwnwwnwnwwneneesewnwwwnwwsesww
swswswswswswweswseswswwswnew
neeeneeeeseeeeeswnwsweeesenwne
wnenwnwneswnwnewweswnwnwseswnwnwnwe
nwnwnwneswswenwenenwnenenenenwnwnenenenw
senenenwsesesewseswnenwswseswweesesw
swswneseseswnwsenwseswseseswswseswswsese
neenwswseswneeneneneneeenenwneswneenene
nwnenenwnesewnwnwswnwnwnenwnwnwneenenwnw
swsewsewwwwwwnenww
nwneswnenwnwnewnenwnwnwenwnwswnwneenwse
seseeweneswnwwwsenwsweeeenenwnww
eswwwwweswwsewnwnwnwenwswwwwnww
wwneeswwnwwwwwswswewwwwwsesw
wwswneswweswnwsweewsenenw
nwnesenwswnwswseweswseseswwswnww
eneeneenewseeneee
sweeeneeeeeneneeeweneeeeesw
wnewnwnwwsenwnwwnwewwwwnwnwnww
eeewnweeeseswee
nenwswseseneseswnwseeseswseneswnenwnwsesw
wswwswwwwwwwwnwnewnwnwenwnww
wswswnwswsweswwsww
eswswswwseweneswseswwneseswswswsesesw
swswwwnwnesenwsesesw
swseswswnwswwswswswswnweswweneswneswnw
sewseswsewseeseseseseseseswsesesesene
wesewwwwswwnwwwwenewwwww
neenwneneswnenenenenenene
nwnenwnwnenenenesweswneneneswnenenenese
eneenwseeeseswsesesweeeeseeese
swswnwesenwsenweseenwsesenwswenwneswsw
swswswsweswswswswnesenwswnwswswswswesw
seseswnwsweswswseswswswswswswsw
seseewnenwswnwsesenenweswse
wwnwwnwwwwsenwwnwswwwwnenwwne
newwsenwnwnwswnwwnwsewne
eswneswnewneseeeeeeeneeeneene
wenweswnesenwwneneenwneswnenewnenwse
nesenenwwneneewnenwnwnenwnwnenwenwnwne
sewswswesewnwswnewnewswwneswnwsesw
eseswswseseseseseseswswnwswnwseeswswwsesw
nenesesenwnesenenwswneneswewnwsenweewsw
eeeseseseeneesesw
nwsenwneseneeewe
nwwneswwnwnwwwwwesenwnwnenwnw
eseeseeseneseseseseseseswse
nwswswswwnwswseswswswnwsesweneseseewnw
nenwneeswewswswnwseneswseneeesenwwnwne
swneseeswnwnwsenwwwewnwwswnewwwew
swnenesenenenwnenenewnenenwwneneneeneene
swnwswswwnewnwswwswswswswswswswsweseew
seseseenwswswseneswsewnesewswseswnee
nwnwnenwsenwnenwseesenewnwnwnwwwwswse
nesenenesewwwsenwnenwnwnewnesenesesenesw
wnwneneseswswnwnenenwnenenwnwnwnwsenenw
nwwswwnwnwnwsewwwwenwnwnwne
wwwnwseneneeswnwnwneswwseswnwnwnenese
esesesenwseseeseseeneswseseesee
nwnenwnwnwneseneneneswwnwwnwsenenwnwnwne
seeeewseeseeneswenwneeewnenee
seswneesenewswwnwswseseswsesesesese
neswseseseseewsesesesesesesenwsesenew
sweswseseneseseseseseesenwsewsesewsw
neweseneneeenwsweeneneneenenenee
nenwnesesweenenenewsweneswneneeneseee
nenwwseswwseseneseneseseseseewswese
wwnwnewnwnewnwwwsewnwwwswnw
nwwwwwnewnwewsewnwnwwnwwnwwnw
wnewwwwwwnwwwwwnwwsewwnese
neeesenewswwenwseswnesweneenewnwnw
swsenewnwnwswneeneneneneesenwwswnenee
weenwswseeweeeenwseseseseeswnw
nenwsenesweeneneeneeenwswneeeene
eseswwenesweeneeenwwenwnenwseene
eeneneeseeseenwswenwsewenwnw
swnenweseneneeeneswnwseneenwswswenesw
swsesewwwswnewnewswswswswwwswswsw
wneweeswseewseneseewswnewnwswswse
wwsenenwnwwswnwwwnwwnwwwnwwnwnwe
neenwneneneneneneneseene
wseswnewneswwwnewnwwwenwwwnwsew
esweswwsewseswnewsesweswswswswnwsesw
swseswswswswswsenweswneswswse
nwwwwswnwswnwwwwwnwnenwenwwwse
nwenwswnenwnwnwnwswnwwnwnwnwnwenwnwnw
nwnwnwsenwnwnwnwnwnwwnwnwnwnwnwnwe
swswswswswswswswswswwswswseswneswnwsw
seseswswswseseseneseswwseseseneswwnese
nweeenwsesesweenwnwsweeeweswe
nwesewwswnewewnewnwsese
wnwnewwwsewsenwnwnwsewwnwwwnwww
wswswnwwwwswswwswwwewewswnww
nwnwnwenwneeswnwnenwwnwnwsenewnwnwnwne
nwewwswnwnwnwswenenwwseseenwseesww
nwnenewneeeneneeseweneeneeswnene
neneneeeswnenwnewneneneeswseneenwse
nwnwwwesenwwwwewsewwwwnwwew
wswwwwwwswnewwnwenwwnwww
seseseseneseseswenwsenwseseseseseseswenw
swnwneswwswenwneenwnwnenwenwswwsenwse
senweseswswwesenesenee
wswnesenewwwwwwwwsewwnewwwsew
swnwswwswswseswswnwnwswwsweswweenw
enweseneneswnenwne
esweeeeeeeneweenweeenesee
wneseseseseseseswnwseseswseswswswswsesene
nenwwsenwwswwnwnewnwwnwswnwwenwnww
swswnwswseswswswswswswswswsenwwswnwswe
swnwseswswseseseswwseseswseseneseswswne
neneswwswswseswwwswswnesesenweswsweswse
eneseeneeneweeeneene
seseseseseseseesesesenwwseseseswnesesese
neseenwnenwswswwwwnwewswsenewnwswwne
seswesenwsenesesesewseeseswneenwswne
swnwnwnwnwnwnenwnwnwneswswewwnwenwnwnwnw
eeswswnwnwneswnewneseneewnweneeneene
seneseseeswnewwsenw
neeswseeneenweenweseseeenwewnenee
swswseseswswsesenwswnwseseseswsesw
sesesesenesesesenwswseseeeeenweeesesw
eswwswnwseweewwswwnewnwwwwwnw
enwnwnenwswnwwnesweenwwnwsenwnwnene
esenwnewweswsewneeewseewswese
eswwwenewseene
seswneswwswswswswswswneswswswswswswswsew
eewnwswwwwwnwesewwnesenwwnwese
seneeeswewneenwnenenenenewneenwe
enenwnesenwnwsenwnwnwnwwnwwnwnenwnwnw
seswwseseneswseseseswsesenesesenwse
eneeseneneewenesewwewwsewsenew
swsenwseeswswswswnwswseswswseswswswese
eeeeneeeseneenweneeene
swswneswswwwswenwwsweswswswswswswnw
wwnesewwnwwwwnwwsewneswwnewsww
swneeswwnenwseenenwwnwnwnwsenenwnene
nesewneseneeeneeeneeeeneneenew
wneewwnwwswnwswneew
eeeneneneeeeweeneeenene
eeesweeeenweswwnweee
nenwnewwnewswnwnwnesenwseswnwnwsewww
wseeswnenwnenenenwnwnwnwswnwswwnwnee
enweeeseswweneeseeewnweeesesee
nwnwwnewwwenwwesewwwewnwswnw
swseweeeneneeneswnwnenene
nenwnwnesewnwsewnwnwwwwnwwnwnwnwsww
eeeweeenweeseeenweswnenee
senesesewwnesenesweweneeewsewee
seneswnwnenewseneseseswsenweseswseseswese
swwswwwnenenwwwwwswswsweswwswsese
esweenweneweeeseeeeweeee
eseseeseseseseseseseneswseswsenwse
wenwwnwsewwwwswsewwwwwnwnwnwnw
wnwwwewwenwww
swswseseseswnwswswsenwseswseseswseseswnw
wnwswswswswwswswswwswswwsesw
nesenenewneswewnenwnwnwsenesenenenenwne
sesesenwseswseswseseese
swseseseseeenwnweseesewenesw
ewneswnenenenenenenesenenenenenenewe
swswswswwwsweseswswnwswwnwseswswwsw
esweeeeenweeeeneswe
wwwsewwwnewwwnwnewwwwwsenww
wnwseseneseswsenwswseswneseeswnwswwnee
swswswswnwswneswseswseswswswseswswnwswsw
neeswnewnesenenewenwewneeneenene
swewswnweewswswswnwswweeenwswne
sesenwnwnwnwwnesenwswwnwnwnewnwnwwnwe
wwswwswnesenewwnwwwwwsweswww
nenewnwsweneswswenwweenwsenwnesesww
seneesesesenwswswnwseseswseesenwswwnwsw
nweneeseswweeeneeeseeeweswe
swnenwneenenwwneneenwnesenewnenwnenwsw
wnwnwnesenwnwnwnwwsenwnenwwswnwnwnwnw
nwswnwnwseeeswwsenwwsewe
nwnweenenwneseswnwnwsewwewwsenwnwnw
nwneneneswneneneenenenenwnenwswnwnwswne
nenenwswnenwnenwnwneenenenwnenwnenesese
nwsesesesenwsesesesewseseseseseseseneesw
wnweeeswseneeenenwseewwswsewsee
ewneeeneeeeswnesenweswswnweene
eenweswwnweseeenwseeenenwswswne
swnwwswswseeswsewwwwsewneneewne
neeneswsenwwnwneswwsweewnenweswswnee
nenenenwswswewswnenwenesenwnwneenwnenw
swwsweewwwwswnesw
sweeeeeeenenesweeeeenenwe
seswwseseeeswnwneneswswswewwswswsw
eseesweeesenweeesewsweseewnwe
swswsewewwweenenwnwswneswsw
swswsesenesesenesese
eeeneeeeneswneswenenwenwneenenene
swneneewwsenenenwneeseewsenenenee
wwswwseswwswnwneeenewseswnew
neswwwenwnwswwwwenwneswswweeswnw
wwwwwwewwwwnwswwwwneseww
nwnesenenenwnwnwnwwnwnenwnwnwwenwnwnw
nenenenenwneneewsenwnwneswnwnenenwnene
senwnwnenenenwnwwnwenenenwnenwnwnenww
nenesenenewneneneneneswnenenenenenwnene
eeswnwnwswseswnweswneswnweseswsesewswse
swnesenenwnenewnenenenwnenenwnenwnwnwe
swswnwenwnwnwwswnwnenwnwneswsenwenwww
nwnwnwnesewnenwnenenwnwnwnwenenwnwwnw
swswwwneswswsweswswswswswew
nenwnwseewnwwenwnwsenenwsewnww
nesewnesenenwnewsenewneneeneseneeneesw
nwswnwwswswwnwewswswesweswweww
neneswnenenenenenenenene
neswneneeeneeeeseneeneenew
eneeweneneneeeeeenesewweeeese
sesweseneswnwswnewswnewneswseswne
seneseeswsesewseseseswnwsesesenwsweswsese
swnweneseweeswnwseeewseeeesesesw
swneseseswswswsewswswswswseseswswnesww
nwswseseswseeseswswswswswseswneseseswsw
swswswnewswwnwnwswnwswseweneswswsee
swswseswswswseswswnwswswnesweseswseswsw
nenesenenesenwnenwwnenewsenenesenenenene
nwnwnwswnwnenwnwnwnwnwnwnenwnwnwnwwnwsee
newnewnenewesewswnenesweenwnenenene
seseseseewenwseenwneseesesewnwsesese
seeeeseweeesewseeeeeeenwene
wwswesweswnewsewswnwswweeswswswnw
wswewwwwwwwwwsww
swwewnwnwnwnenewswneseseenenwsenese
swnenwnweewnweesenewneswseeswsene
eseeeseswwnwseneseeseseseseseeseese
swnwnwneeneseneswwneneeneeneeswwse
nwnwnenweswnwswnwnwnwnwnenwnwnwnwenwnw
swsesenwnwswswnwesesesenwnwswsweneswnw
nesenwneenwnenenenwneneswwnwnwnwnwew
nwnwnwsenwnwnwneswnenwnwnwnwnenwsenwnwnwnw
nenwewsewsenwnwnwwnwnwnwnwwswnwnwnw
nenenenesewnenweneeneseneenenenwnesw
neeeseneeeewweeneneeeneweene
sewwswswswswswnwswneeswseeswsweswnw
wswswswneswswswsweseswswswswswswswswnesew
eswwseseneeneeeeneeeeeewwee
swsewswsenwsesenesesesesesesesesesesesw
eeewswseeeseeweeeeeeeneenwe
esesewenweeweeseneeseswseeeee
neseeneeweneeneneneneenenewnenene
wwnwnenwnwnweswnewswnwwnwnw
nwswenwnenwnwnwnwnwnenwnwswwenwenwnw
swnwnwswnwnweswenwewnw
wwneseseneseneswswnesenewwsesweswsese
ewneseneneswenwnwnenwneneenewesesw
nwsewswnwswseswwenwseneswseeneneene
enenenwnenwsenwnwnenwnenewnenwnenwwswnw
eseeesweeswnweneseeeeeeeese
neneswswnwwswneneneneneseenenwswee
wwwwwewwwwswwnewewwwwnw
nenesenwwnenenenenenwnwnenene
eeseeeeswsesewenenwenweewsee
neseneneneneneeneswenenenwneswnw
newswneseewnwwwnenwsenweenweswsw
nenwenwneeeswnweneneneeneswswswnenesw
neseseeneewneswseeswnwswwswenwnwswsw
esenenweneswswnwsewnwneneneeswnwnwswne
wwnewnewsewwwwnwwwswwwwsenew
neswsewsewswwwwenwwswwwswnwnwnese
wnwswwewewnwewwsweswwnwswsesww
nwsweseneseenwswwseseswswwseeneswswsw
nenesweweneeseneneneeneneewenene
nwnwwenwnewwswwwnwnewwwwnwwsww
wenesewsweeeseenenweenwseeee
swswsenenwwswwwswwswswewsww
seseseseswseeneeseneenwseeswweseenw
esewenwwnenwewenenwswseesesewsew
wenenwseneseneswseswsewewseswesenenenw
neswswesenwswswneeswneswswswswewswnww
wswswswswswswwneeswwswswswwswneswsw
swswswneswnwnwseswswswswseswswseseswswsw
nwswseeeeweeweeeeeeeeee
nwswnwnwnwwnwwwnwnwwnwwsenenwnenwe
eneseneeeeesweeeeweenew
wnwwnewnwnwsewnwwwnesenwwnwwswnw
eswewseswsweswnwseseswesewswwwwe
swwswswsesesenwseswesweswseseswnw''';

const sampleInput = '''sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew''';
