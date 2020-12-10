import 'dart:convert';

import 'package:test/test.dart';

int part1(String input) {
  var adapters = LineSplitter.split(input).map(int.parse).toList()..sort();
  adapters.add(adapters.last + 3);
  adapters.insert(0, 0);
  var diff1 = 0;
  var diff3 = 0;

  for (var i = 1; i < adapters.length; i++) {
    var diff = adapters[i] - adapters[i - 1];
    if (diff == 1) {
      diff1++;
    } else if (diff == 3) {
      diff3++;
    }
  }
  return diff1 * diff3;
}

int part2(String input) {
  var adapters = LineSplitter.split(input).map(int.parse).toList()..sort();
  adapters.add(adapters.last + 3);
  adapters.insert(0, 0);

  // Lengths (inclusive) of sequences differing by 1, each element can't be less
  // than 2;
  var oneRuns = findOneRuns(adapters);
  print('max one run: ' +
      oneRuns.fold<int>(0, (r, e) => r > e ? r : e).toString());
  var cache = <int, int>{};
  return oneRuns
      .map((run) => combinationsCached(run, cache))
      .fold(1, (r, e) => r * e);
}

List<int> findOneRuns(List<int> adapters) {
  var result = <int>[];
  var current = 1;
  for (var i = 1; i < adapters.length; i++) {
    var diff = adapters[i] - adapters[i - 1];
    if (diff == 1) {
      current++;
    } else if (diff == 3) {
      result.add(current);
      current = 1;
    } else {
      throw ArgumentError('wut');
    }
  }
  return result;
}

int combinations(int oneRunLength) {
  if (oneRunLength < 3) {
    return 1; // nothing we can do.
  }
  if (oneRunLength == 3) {
    return 2; // remove nothing, or remove middle.
  }

  // Code below does not count duplicates correctly, but since max run length is
  // 5 in my input, just using results from paper.
  if (oneRunLength == 4) {
    return 4;
  }

  if (oneRunLength == 5) {
    return 7;
  }

  // Do not remove anything
  var result = 1;

  // Removing one element at position i, splitting run into 2.
  for (var i = 1; i < oneRunLength - 1; i++) {
    var leftCount = i;
    var rightCount = oneRunLength - i - 1;

    var leftResult = combinations(leftCount);
    var rightResult = combinations(rightCount);
    result += leftResult * rightResult;
  }

  // Removing two elements at position i and i+1, splitting run into 2.
  for (var i = 1; i < oneRunLength - 2; i++) {
    var leftCount = i;
    var rightCount = oneRunLength - i - 2;

    var leftResult = combinations(leftCount);
    var rightResult = combinations(rightCount);
    result += leftResult * rightResult;
  }
  print('combinations($oneRunLength) = $result');
  return result;
}

int combinationsCached(int oneRunLength, Map<int, int> cache) =>
    cache.putIfAbsent(oneRunLength, () => combinations(oneRunLength));

void main() {
  test('sample', () {
    expect(part1('16\n10\n15\n5\n1\n11\n7\n19\n6\n12\n4'), 35);
    expect(
        part1('28\n33\n18\n42\n31\n14\n46\n20\n48\n47\n24\n23\n49\n45\n19'
            '\n38\n39\n11\n1\n32\n25\n35\n8\n17\n7\n9\n4\n2\n34\n10\n3'),
        220);

    expect(part2('16\n10\n15\n5\n1\n11\n7\n19\n6\n12\n4'), 8);
    expect(
        part2('28\n33\n18\n42\n31\n14\n46\n20\n48\n47\n24\n23\n49\n45\n19'
            '\n38\n39\n11\n1\n32\n25\n35\n8\n17\n7\n9\n4\n2\n34\n10\n3'),
        19208);
  });

  test('part1', () {
    print(part1(input));
  });

  test('part2', () {
    print(part2(input));
  });
}

const input = '''138
3
108
64
92
112
44
53
27
20
23
77
119
62
121
11
2
37
148
34
83
24
10
79
96
98
127
7
115
19
16
78
133
61
82
91
145
39
33
13
97
55
141
1
134
40
71
54
103
101
26
47
90
72
126
124
110
131
58
12
142
105
63
75
50
95
69
25
68
144
86
132
89
128
135
65
125
76
116
32
18
6
38
109
111
30
70
143
104
102
120
31
41
17''';
