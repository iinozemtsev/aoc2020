import 'dart:convert';

import 'package:test/test.dart';

abstract class Rule {
  /// If [input] matches at [position], return new position, or return -1.
  List<int> matches(String input, int position);
  bool completelyMatches(String input) =>
      matches(input, 0).where((m) => m == input.length).isNotEmpty;
}

class Exact extends Rule {
  final String str;
  Exact(this.str);
  List<int> matches(String input, int position) =>
      input.startsWith(str, position) ? [position + str.length] : [];
}

class Sequence extends Rule {
  final List<Rule> children;

  Sequence(this.children);

  List<int> matches(String input, int position) {
    var result = [position];
    for (var child in children) {
      result = result.expand((r) => child.matches(input, r)).toList();
      if (result.isEmpty) {
        return result;
      }
    }
    return result;
  }

  String toString() => children.join(' ');
}

class Choice extends Rule {
  final List<Rule> children;

  Choice(this.children);

  List<int> matches(String input, int position) =>
      children.expand((child) => child.matches(input, position)).toList();

  String toString() => children.join(' | ');
}

class RuleReference extends Rule {
  final Map<int, Rule> rules;
  final int id;
  RuleReference(this.rules, this.id);

  @override
  List<int> matches(String input, int position) =>
      rules[id]!.matches(input, position);

  String toString() => id.toString();
}

class Rules {
  final rules = <int, Rule>{};

  Rule ref(int id) => RuleReference(rules, id);

  static Rules parse(String input) {
    var result = Rules();
    for (var line in LineSplitter.split(input)) {
      var idAndDef = line.split(':');
      var id = int.parse(idAndDef.first);

      var def = idAndDef.last.trim();
      late Rule rule;
      // Parser hack based on input:
      if (def == '"a"' || def == '"b"') {
        rule = Exact(def.substring(1, 2));
      } else {
        var sequenceDefs = def.split('|');
        var sequenceRules = <Rule>[];
        for (var sequence in sequenceDefs) {
          sequence = sequence.trim();
          var sequencedRules = <Rule>[];
          for (var ref in sequence.split(' ')) {
            ref = ref.trim();
            var refId = int.parse(ref);
            sequencedRules.add(RuleReference(result.rules, refId));
          }
          sequenceRules.add(Sequence(sequencedRules));
        }
        rule = Choice(sequenceRules);
      }
      result.rules[id] = rule;
    }
    return result;
  }
}

int part1(String input) {
  var rulesAndMessages = input.split('\n\n');
  var rules = Rules.parse(rulesAndMessages.first.trim());
  var messages = LineSplitter.split(rulesAndMessages.last.trim());

  return messages.where((m) => rules.rules[0]!.completelyMatches(m)).length;
}

int part2(String input) {
  var rulesAndMessages = input.split('\n\n');
  var rules = Rules.parse(rulesAndMessages.first.trim());
  // Override rule 8:
  rules.rules[8] = Choice([
    rules.ref(42),
    Sequence([rules.ref(42), rules.ref(8)])
  ]);
  // 11: 42 31 | 42 11 31
  rules.rules[11] = Choice([
    Sequence([rules.ref(42), rules.ref(31)]),
    Sequence([rules.ref(42), rules.ref(11), rules.ref(31)])
  ]);

  var messages = LineSplitter.split(rulesAndMessages.last.trim());
  return messages.where((m) => rules.rules[0]!.completelyMatches(m)).length;
}

void main() {
  test('simple', () {
    expect(Exact('a').completelyMatches('a'), isTrue);
  });

  test('sample', () {
    expect(part1('''0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb'''), 2);
    expect(part2(part2input), 12);
  });

  test('part1', () {
    print(part1(input));
  });

  test('part2', () {
    print(part2(input));
  });
}

const input = '''25: 53 116
122: 116 92 | 53 53
100: 53 73 | 116 125
111: 67 116 | 91 53
71: 116 58 | 53 78
55: 116 54 | 53 21
123: 53 97 | 116 108
104: 56 116 | 125 53
19: 125 53
56: 116 116 | 116 53
60: 116 121 | 53 59
75: 53 20 | 116 124
6: 53 131 | 116 33
62: 53 53 | 116 116
101: 116 127 | 53 26
128: 116 125 | 53 93
34: 53 28 | 116 125
65: 63 116 | 135 53
50: 32 53 | 76 116
2: 53 10 | 116 132
133: 28 53 | 131 116
85: 53 131
125: 116 53
118: 87 116 | 3 53
135: 73 53 | 125 116
28: 53 53
110: 116 122 | 53 56
91: 5 53 | 74 116
73: 92 116 | 53 53
80: 15 116 | 109 53
124: 128 116 | 17 53
87: 92 53 | 53 116
43: 116 27 | 53 37
66: 46 53 | 93 116
106: 116 77 | 53 83
137: 72 116 | 104 53
93: 116 116 | 53 116
129: 92 103
12: 116 56 | 53 131
45: 53 132 | 116 12
102: 65 116 | 2 53
24: 116 101 | 53 95
14: 116 84 | 53 29
57: 93 116 | 56 53
70: 108 116 | 100 53
51: 116 1 | 53 68
26: 73 53
15: 116 93 | 53 125
42: 53 134 | 116 106
79: 116 33 | 53 122
5: 116 125 | 53 3
74: 53 122 | 116 73
18: 93 53 | 87 116
20: 47 53 | 17 116
114: 116 85 | 53 118
37: 53 73 | 116 87
47: 116 73 | 53 125
107: 116 3 | 53 46
69: 53 25 | 116 125
32: 53 28 | 116 93
76: 3 53 | 125 116
38: 92 33
119: 116 39 | 53 80
8: 42
21: 125 53 | 125 116
58: 75 116 | 119 53
64: 116 44 | 53 113
68: 90 53 | 45 116
1: 23 116 | 60 53
53: "a"
81: 73 53 | 33 116
86: 116 129 | 53 35
90: 110 116 | 13 53
82: 53 93 | 116 25
95: 99 116 | 66 53
27: 116 56 | 53 3
120: 116 51 | 53 40
126: 116 96 | 53 52
116: "b"
84: 116 123 | 53 49
134: 116 61 | 53 14
78: 116 102 | 53 86
96: 130 53 | 98 116
10: 87 116 | 33 53
88: 53 116 | 116 92
40: 126 53 | 24 116
127: 56 116
59: 87 53 | 3 116
11: 42 31
41: 116 137 | 53 16
44: 116 22 | 53 79
109: 88 53 | 87 116
49: 136 116 | 94 53
113: 107 116 | 81 53
77: 116 64 | 53 36
3: 53 116 | 53 53
9: 133 53 | 112 116
98: 92 93
117: 3 92
39: 53 19 | 116 21
16: 6 116 | 117 53
132: 131 116 | 125 53
63: 116 122 | 53 33
22: 131 116 | 56 53
89: 116 125 | 53 131
115: 55 53 | 50 116
99: 116 33 | 53 93
92: 116 | 53
121: 53 73 | 116 56
13: 73 92
103: 53 3 | 116 62
83: 111 116 | 41 53
61: 105 116 | 115 53
130: 56 92
136: 33 116 | 125 53
30: 53 76 | 116 7
94: 92 87
52: 97 116 | 18 53
7: 116 28 | 53 46
97: 25 53 | 33 116
35: 89 116 | 82 53
72: 53 131 | 116 87
48: 34 116 | 38 53
54: 116 46 | 53 131
131: 116 116
23: 116 4 | 53 57
31: 116 71 | 53 120
29: 116 30 | 53 114
108: 116 25 | 53 46
33: 92 92
4: 131 116 | 3 53
36: 70 116 | 9 53
67: 69 116 | 117 53
0: 8 11
105: 48 116 | 43 53
46: 116 53 | 53 116
17: 93 116 | 122 53
112: 122 53 | 3 116

babbbbabaabaaabbbbbaaabbbbababba
ababaaaaabbbabbbbbabbbba
aabbaabaabbababaababbaba
bbbbabaaabaaabbbbbbbbaab
babbbabababaabbaaaabbbba
bbaabbababbaaabaaaababbbabaaaaaaaaaaababbaabbbbaaaaaaabaabababbbbabbbaababbbaabbbbababab
babbabbabbaababbbbbbbaab
baababababbaababaaabaaab
aababaababbaaaabbbababbbbbbbbbaabbbbabbbbbabbababbababaabaabaaaabbabaaaaabbaaaaa
baabbbbaaabbabbbababbbba
baabbabaaaaababbaababbbbaababaaabbbbbaaabababaab
babbabbabaabbabbaabbabaa
baaabbbbabbaaabbaaaaaabbbbabaaba
abababbaaabaabbbabbbaaaa
ababababbbbaaaababaabaaa
baaababbbbbabababbbaaabaaaabaababaaabbbbaaabbbbaabbaabbbabbbaaab
babaaabaabbabaababbabaaaabbbaaaa
ababaaabaabaabaabbbbababbbaabababaababaaabaabbbb
abbaaaabaabababaabaabbaa
baaaaaabaaaaababbababaaa
aabaaabbababaabbbaaabbbbaabbbaaa
baaabbbaaaaaaaaaaabbbbba
abbbbbabbbbabaabaabbbbabbbaabaabaabbbbbb
baabbbababababbabbaaaaaaabbbaabbbababbbaababaaaaaabbbbaa
bbbbbbbbabababaabaaabbbabbaaabbbaaaaaabaabbaabbabbabbbba
abaabbabaabaaaaabaabaaaa
aabababbababaaaaabbbbbaa
bbbabbaaabaaaababababbbabbbaabab
aabababbaabbbababaabaaab
aabaaababaabbabaaabaaaab
abbbabaabbaabbabaaabbbba
baaabbbbaababbabbbbabbaabaabbbbbabbbbabbbabbaaba
bbaaababaabaaabbabbbbbabbabaaabbbbaabbbbaabbbaaabbabbabb
baabaabaaababbbbbbaabbaa
bbaaabbbbababbabaaaababa
bbabbbbabaaaaabbbaaaaababbbbbaaabaababbbbabbabaabaabbabaabbababbaaaaaaabbbabaaabbbbbbabb
abaabbbababaaaabaabbbbbbbbabbbab
ababaaaaabababbabbbaababbaaabbaaabbaaaba
bbabbaabababbabbbaaaaaabaaabaabb
baabaaaaababbbbabbabbabbbababbaa
aaaaaaaabaaabaabababaaba
baabbababaaabaaaaabaabaaaababbbbaaabbbbb
abaaaabaabbababaababbbab
bbaaabababbababbababbbbb
baababbaaaabababbaaaaaabbaaaabbb
bbbbbbbaabababbabbabbbba
bbaaaaaaaabaabbbabaabbaa
abbabababbaaaaababbbabbbbbaaaaaaababaaaababaaaba
abaababbaabaaaaaaabaaaab
abababaabbaaabbaabababbaaabbabaa
babbabbbbbbbbbbabbaabbaa
bbabbbaaaabaaababbaaababbaaabaabaabbbaababbaabaaaabbbaaaabbaabbbaabbbbba
abbbaabbababaaabbababbbaabbbbababababaaa
bbaaabbabbbaabaaabbbabaaaaababbbbaababbb
baabaaaabbaaabbaaabbaababbbbbbababbbabbbbbbabbba
abaabbbaabaababaaaabbabb
bbbbabaaaabaabbbbbbbbaab
bbaaaaabababbabbaababbab
babbaabaabbbbaaaaabbbbbb
baaabaabbbbbaaaaabbbaaab
aaabbaabbabbabbbbabbbbba
aabbababaabababaaabbabbbbbbbbbbaaaabbaaaababbabbabaaabaabbababaabbbbbabbbabbbbabaabaabaabaababba
ababaabbaabbbabababbabab
bbbabbbabaaabbbaaaabbbab
aabababbaabaabaaabaaabbbaabbbaaa
aaaaaabaabbabbaabbbbaaaaaabbaabbaaabaaaaabbbbaabaaaabbbaababbbbbababbaaa
ababaabbabababbabababbbaaabababaaabbbbaaaabbbabb
babbabbaabbabbbaababaaba
abbbbaaabbbbbbbabbababbbbaabbaab
babbaabaabbbbabbaaaaaaabaabbabba
bbaaababbaabbabbbbbbabbbbabbabaabbabaaaa
aaabaabaaabbababbababaab
bbaaabbbababaabbaabaaababaabbbbbbbabbaaa
abbabbbabaaabbbbbabbbabaaabbaabababbbbbaabbbaabababaabba
aaaaaaaaabbabbaabbabbbaaaabababbbaaabaababaabbaabbababab
aabbbabababbabaaaaabababbabbbbba
abbababbbbbbabbaaabbbbbb
bbbbbbbaabaaaaababbaabbb
aabababbabaaabbaababbaaabbbbababbbabbabbbaaababbabbbbbabaaabaabaabbabaabaaabbaaa
abbbbbabbbbbabaaabaabaab
abbabbbabbbbabababbbbbba
abababbabaaaaaabbbabaaaa
aaaaababbbbbaabbaaabaabaabaaabababbabbabbbbaabbb
baabbbbabbbaaaaababaaabb
bbaaaababbaaaabaababaaaaaabbbaabbbbabaaa
babbbbbbbabbbaaabababaabbabbbaabbbaaabaa
aabaaabbaabbaabbbababaab
baaaabbbbbabbbababbaababbabaaabaabababbaabaabbabbaaaaabaabbaaabb
abababbabaabbbbaaaaababa
aabbbbabbbbbaabaaaabbaabbbabaabababbbbaabbaabbabbaabbaaa
aaabaabaaabbababbabbbababaabbabb
bbbaaababbbbbbbbbbbababbabbbaaab
bababbaaaaaabbbbbabaaaab
bbaaaabaaaaaaabababbbabaaaaabaaa
aabbabbbbbaaababbbababaa
abbaaaababbbbbabaaaaabbb
bbaaaaaabbbaabababaabaab
ababaabbabaababbbbabbaabbbbbbbbbaaabbababbabbabbabbaabaa
bbaabbbaabababbaaaababbb
bbbbabbaaabaabaababaaaaa
bbaabbababbbbaabbababbbabbbbababbbbaaabbbaaaababaababbbababbaabb
bbaaaababababbabbabbbbaaabbbaaab
babaababaaabbaabbbababaa
ababababababbaabbabababa
abbabbbbaaaaaabbabbbabaababaabbaabbbababbbbaabaaaaaaaaabbbaabbba
bbbaaabaaaaaaaaaababbabbbbaabaab
abbbaabbabbbbaaaaaaabaab
abbbbbbbaaabbbbaaaababbaaaaabbabbababaabbbaabbabaabababa
aababbaaabaababbababaabb
babbaaabaabbabbbbbabbaaaaaaabaab
aabababaabbbbabbaaaaabaaaabaabababbaaaba
baabbabbbbaaabababaabbbb
abbaaabbbbbabaabbbbbaabbabbbbaabbaabaaabaabaaaab
bbaabbbabbbbbabbbababbbb
babaababbbbababaabaaaabbbabbabaabaabababaabababb
bbababbabbaabbbbbbbbabbbabbaabaaabbbaaaabbaabaababaaaaaa
babbbbabbbbbbbaaababbbba
abbbbababbbaaaaaaaabbbab
baaaaaabaabbbaabbabbbabbabbaaabaababbaaaabbaaababbaaaaaabaaaaaabbaababababaaabbbabaabaaa
aabaabbbabbbbaaaaababbaaababaabbabbbabbababaabba
aabababbbbbbabbaabbbbbbb
baabababbbaaaaababbbbaabbabbabbbaaababbaaaabaaab
baaabbbababbaabaabbabaaa
abaababbabbbbaabaababbbbbbbaaaab
aababaababbbabbbababbaaa
baaabbbbbbbbabbabbbbbaab
bbabbaabaaabbbaaaabbbaaa
bbabaabaababbaababbbabbbabaabbabbaabbaab
bbbbbbbaaabbaabaababaaba
aababababaaabbbaababbbaa
babbbbbabbbababbaaababaaaababbaaaaabbbabaaababaaabbbbbbbbbbaaaabbaaabbaabaaaababbbaaaaab
aababbaaabaaaababbbbabaaabbbbabaabbbbabbbabbbabb
bbbaabaaaabbbbabaababbaabbabaababbaabaaaababbbba
abaabbbaabbbaaabbabaaaab
bbbbbbbbaaabbabababaaabbbbaaaabbbabaaabb
baaaaabbbaaaaabbabbaaaaa
ababaaaaaabbbaababbaabba
bbaaaaaaaaabbababaaaaaaaaabaaaab
bbbabababbbbabbaabaaaaaa
bbaaaababaaabbbabbbabaabaabaabab
bbbabbbaaabbbbaaabbaabbaabaabbbaaabbbbba
babbabbabbbbbbbaaababababaaabaabbaaaaaabaaaaabaaabbbbbbaaabbbbbabbaabbaa
ababbabbaabbaabbbaaaaabbaababaaaabbabbab
abbabbbbbaabbbbbbabaabbb
abbbaabbaaaaababbbaabbabaababaabaababaababbbbbbbbbaabaab
baaaaaaabbbabbbaaaabbbba
bbaaabbbababbbabbaaaabaabaabbabbbbbbbbbbabbabbabbababababbaababbbbabbaba
bbbbababbaabbababbabbbab
baaabaabaababbbbbbabbbbb
abbbbababbbababbbbabbababbabaabbbbaaaabb
bbaaaaaaabbbabbbabbbbbaa
bbabaabaabbabbaaababbbaa
aabbbaababaabbabbabaabba
baaabbbaaaabaababbaaaabb
babbbbaabbbbaabaabbbaaaa
abbaabbbaababbabbaaabbababbbabab
aaabaaaaaabbabababbbbabbbbabbbbbaaabaaab
babbbaababbaaaaaaabaaababbaaabbb
bbbbaababbaaaaaabbbbbaab
bbaaaaaaabbbbababaabaaab
babaababbabbabbbaabababaabaabaab
abbbabbbabbabbaaaababaababbabaab
bbbbaaaaaabbaababbabaaabbbabaaaabbabbabb
aaabbaabbaaabbbbbbbbbaaa
abbbbaabaabbbabaabaaabababaabbba
babbabbabaaababbbbaaabbababaabaabaabbaababaabaaa
babbabbaaabaabbaaaaaabaaabbbaabaabbaaaaabbbaaabaaababbaabbbbaabaabbbbaba
aabaaabbabbaaabbbabbbabb
bbaaaaaabaabbbbaabbbaaab
bbbbaaaabbbaaabaabbbbabbbababaaa
abbbabaabbabbaabbabbbbba
aaaaaaabaababbbbababbbab
abbbababbbabbbbabbbbbabbbabaaababbababaabbbaaaab
babaaabaaabbbaaaaabbbbbbabbaaaaabaabaabbabbbababaababaaaaaabbaaababbbabbbaaababb
abbababbbaaaaaabbabaaabb
bbabbababbabbaabbababbbb
babbbbaaaabbaaababbbbaaaaabbababaaabbaabbbbbaaab
aabbaabbabaaaabbaabababaabaaaabaaaabaaaaaaabaabababababa
abababbaaaabaabaaaababbb
bababbabaaabbbaaababbbbb
baaaababbabbbabababaabba
abbbbabaaaaababbbbbaabbabaaaabbaaaababba
aabbababbbaababbabaababa
babbaaabbbaabaabbbaaabbabaaaaabaabbabbaabaabbaabbbbbababbbbabbbb
aaabbbaaabbabbabaabaaaaaaabaaaaa
aababbaaaababbbbabbbaaaa
baaabbbabababbbaaabaabba
bbabbaabbbbabaaabaaabbbbbbbaabababbaabbbbabbabbaaabaaabb
baabaabaababababaaabaabb
abbababbbbbbababbbaabaab
abababbabababbabbaaaaaab
bababbbaaabaaabababababb
aabbabbbbaaababbbbabbaaa
abbaaaababbabababbaabbbabbaabaab
bbbabbbaababaaaabbbaaabababbaaaaababbabaaabbabaaaaaaabba
baabaabaababaaabbbbbababbabbabbabababbbb
bbbbbaaabbaababaabbbbbaaababaaba
bbaaaabaabbaaaabbbababbbbbbababaabbabaababbbaaaaabaabaaa
bbabaaaaababbbbbbababbbbbbbababbbabbbbab
ababababbaaabaabbbbaababaababababaabbbaaaaababbbbabaaabb
babbbabaaabbabbbaababbba
aaaaaaaababbbababbaababbabbbaabb
aababababbaaaaaabaaaaaba
aaaaaaabbaaaabaaaababaabbbabbabb
bbabbabbbbbbabbaabbbaabaababbbaabaaabababaabbbbbbabbbbbb
bbbaabbaabaaaabaabaaabaa
babaabbabbabbaaabaabaaaaabaabaaa
aababababbbbaabaabbbbbaa
baabababbaabaabbaaaaaabbaaaaabababbabbaaabbabbaaaaaaabbb
bbabaabaababbabbbabbaabb
abaaaababbbbbbbabbabaaaa
bababbabbbbbabaababbbbbb
aabbabbbbbbbabababbabaab
abbababababbabaaaabbbaaa
aabababbabbaabbbbbbaaaabbbbbaaaa
abbbabbbaaaaaaabbaabbbbb
bbbbbbbaaabaaababbbbababbabaaabaabababbb
aaaababbaaaaaabaaabaabba
abaaaabbbbbbababbbababbbabaabaaababaabaa
bbabbbaaababbabbbbbaaaab
aababaaabaabbbbbbbbabbbb
aabbbaababbbbbabbababaaa
aabbaaababbaababbbbbababbbbbababbbbbaabbbaabbbbbabaabbaabbbabbbb
baaabbbbbbbaaabaabaabaab
baaabbaaaababaabbabaaaaa
aaabababaababbabaababababbbbbbaabbabbbaabaabaabbaaabaabaababbbbb
aabaaabbbaaabaaabbbabaab
bbbaabbaababbabababbbbbababbbabbbbaabbbbbbabaaaaaaaabbab
aabbaaabbbaabbabaaababbb
bbbbabaabbbabbbaaabaaaab
aabbaabbbabaababbaababaa
aaaaaaaababbbbababaaaabaaabababbabaaababababababaaabbabbababbbbbaaaabbab
babbbbabbababbbabaabbaaa
aabbaaabbbaababbbbbbabaaababaabbbabaaabaaabbbabbababbaba
bbbaaaaabbaaabababbabbbb
bbbbabbababbaaaabbbabbbaabbaabbbbbaabaaa
aaaababbabbaababbabababb
bababbabaaabaaabbaabbbaabaaababa
babaababbaaaaaabababbaabbababbaaaaababbb
aabbabababaaabbababaaaba
bbbaaabbabaababbbababbaa
abbabbbaabbaababbabaabba
baaababbaaaaaabaaabbbaaa
baaaaaabaabababbaaabbaabababbaababbaaabbaababbba
abbbbabbbbabbabaaaaaaabbbabbaabb
abbbbaabaaabaababbbababaaabbbaabbabbabbabbabaaababbabbbbbaababaa
bbbabababaabbaaabbaaababbabaaaaabbaaaaaa
abbbbaababbbabbbaabaaaab
bbababaaaaaabababaaabbbbbbabbaaababbabbabaaaababaaaabababbabaabaabaabaab
bbbabbaabbbbabababaaabaa
abaaabbabaaaabaaaaabbabaababbaba
babbaabaabbabbaabaaaaaba
aababababbabbbaaabbaabba
bbbabaabbaaabbbabbabbaaa
bbbababaaabbabababababbb
aabbbbababaaaabbbaabbabbbaabbaab
bbaaaababababaababbbaaab
abbbaabbaaaaabbaaabaaaabbabaaabaaaaabbabbaababaa
babbabaabababbabbbbbabbbaabbbaba
bbbbbbbaabbbaabbbbbabbab
abaabbabbaabaababaabababbbbaaababababbaaaabbbabbabbaabbb
abababbabbaaaaabaabbabba
abbabaaababbababaabaababbabaaaaabbaaabaabbabbaaa
babbabaabbababbbbbabbaaa
aabaaabaababaaaaaaaabbba
bbaabbbabbbbaaaabaabababaabaaabaaabbabba
abaaaabaaabaaabbabbabbbb
abaaaaabaaaaaaaabaaaaaba
aaabbabababbbbaaaaaabbbb
bbbbaabbabaaabababaaabbababbbabaababbaabbabaabba
bbbabbbaaabbbababbaaabbbbbbabbabbbbbbabbabbbbbbb
abaaaababaaabaabababaaba
baaabaaabbabbbaaaabbaababaaaabba
bbbbabbbbbaabbbabaabbbbb
ababbaababbbbabaababaaaaaabbaaabaaaaabbb
baaaababaaaaababbababbaa
aabaababbabbaabbbaabbababaabbaabaaabaaabbabaabbababaaabbabbbaaab
abbabbaaaaaaabbabaaaabbaababbaaa
bbbbaabaabbbbabbaabbabbbaababbbbbabaaaba
bbbaaabbbaaabbbaaaababbb
baaabbbabbbaaaaabbbaaabaaabababbabaaabbababbabab
aabaaabbabaaaaababbbaaab
bbaaaaabaabbabababbbbaaababbababaabaabba
bbaaababbbbbaaaabababbbaaaabbabb
bbababbbbbabbababbbbabaabbbbaaaaaabbbaabbabbabbbbbbabbbb
bababbbaaaabbaabaaaabbba
ababbaababaabbabaaaaabba
aaaaaabaaaabbbaaababbaba
babbbbaaabbbabbbbbbabbab
bbbbbbbabbbbabbbabbaaaba
baaabaaaaabbaabbabaaababaaababbb
baabaabababbabbbaabbbabb
bbaaaaaaabbbbabbabaabbabbabbaaabaaaababaaaaaabba
baaaaaaaaaaaaaaaaaaababa
abbaababaabbbbabaaababba
bbbbababaabbbaabaababbaaaaabaaab
aababaabaabaababbbbbaaaaababaaaaabaababbbabbbbaaabaaaaabababbbab
babaababbbaabbabbbaabbaa
baabbababaaaabaabababbaa
bbaaabbabbaaabbbbbabbabb
baabbbbabbaaaabaaaabbbba
bbababbbbaabbbbaaaaabaab
aaabababaaaaaabbabaaaabababbbbbb
bbbbbbababaaabbbbaaaaaaabbaabbaabbbbbaabaabaaabbaaabbbbabbaabaabbbbaaabbabbbaabb
aabbbaaababbabbbbaabbbbababaaaaababaaaaaaaababbbaabababb
bbabbaabbabbaaaaaaaaabba
abbabbaabbaabbabaaabaabaabbaaaaaaabaaaabbbaabaabaabbabaa
abaababbaabbaaabaaabaaaabbaaaabaabaaababaababaaabbbabbababaaabaaabbaabbabbaaabaa
bbaaaaabbbbbabaaaababbaababbabbbaaabbabababbababbabbbbba
babbbbaaaababbaaaabaabbbbaabbbaababbbbbb
aaaababbbbbbbbaabbbabbbb
bbaaababbbaaabbaaabbbabb
abbaaabbbabbaabababaabbb
aabababbabbbbbababbbaabbaaabaaaaabbabbaababaabaabaaaaabaaababbbaababbbab
babbaaaaaabbbbabbbbbbbaabaabbbabbbbbaaab
babbabaaabbaaabbbabaaaaa
aaaaaaabababababbaababbb
ababaabbbabbaaaaabbbbbbb
aabbaaabaabbbabaaaababba
baabbabaaabaabaaabbaaaaa
abaaaabaaabbbaabbabaabaa
bbaaabbbbaaabbbaababbbbb
baaababbbbbaababbbabbaaa
ababbbbbabbababbaaabaabbaabbbaaaaabbaaabbbbbababbaaaaabaaabbbbaaaabbabaaaababbbbabaabaaa
bbbbabbbababababbaabbaab
ababbaabbabbbbaababbabbabaaabbaabaaabaaabaaaabbbababaababaababbb
baaaababbabbbbabbaabbaab
bbaabbbaabaaabbbbababbaa
bbabbbbaabbaaabaabbaabbaabaabbbb
bbbaaaaabbaababbbbaabbababaababbabbaaaba
aabababbaaabbbaaababaabbabbbbbba
abaaaabaaaabaaaabaaaababaabbbaababaabbabaaaaabbaaababbbabaabbaaababaaaab
baaabbbbbababababaaaababbbbaabaaaabaaabbbabbaabbabbbabaabbaaaaba
abbbbabbbbbbabbbbabbbbbb
bbbbabbbabbaaabbbbabaabaababaababbaaaabb
ababaaaaaababaabbaabbabaabbbabaaababbaaaabbbaaaa
bbbbbbbbbbbbaabbaaaabaab
aababaabbabbabaaaaaabaab
ababaaababbabbbabbaabaaa
bbbababbabbbbbabaaaaabaa
abbbaabbbabbbbabaaabbaaa
abbaaaabbbaaaaabaabaabba
aaabbabaaabaabbbaaabbabb
ababaaababbbbaaababaababbbbaabbbbaabaaaa
baabababbaababbabaabbaab
bbaaabbbaaabaabaababbaba
baaaaabbbbbaabaabaaabaaabaabbbbb
aabbbababaaaaaabababbaaa
baaaababbaaababbaaaaabaa
aabababaabaabbababababbb
bbaaaaaabaababbabbbbabaabbbbbbaaaabbaaabbababaab
bbbbababaabababaaabbbaaa
baaabaababbabbbaaababbaa
babaaaaaabbaababaaabbbbaabababbababaaaababaabaabbbbaabbbaaaaababaabaabbabbbbbbbbabababbaabaaaaab
bbbaababbaabbbbabaaaabaaabbbbbba
aababaabaababaaabbbaaababbbabaabbbaabaab
bbbbababaaabaaaabbbaaaab
bbbbbbbbabbbabbbaababaabbbabbabbbbaabaab
baaabaaabaaabbbbaabaaabbaaabaabaaabbbbaa
bbbabaabbaaaababaaabaaab
ababababbbbbabbbaaabababbaabbaab
abbababbaababaaaaababbaa
ababababaabbaabbbababaaa
ababbabbaaaaaabbababbbab
aaabbabbbaabababaabbaabbaaabaabbbabbaabb
bbbbababaabaaaaaabaaaaaa
bbaababaababbaabaaaabaaaaabbabaabaaaaaaaaabbaaba
bbababbbbaaaaabbaaababba
bbbbbbaaabbaababbaaabbaaabbbbabababbbbba
aabbbaabbbbababbbaaababa
aabaabaabaaabaababbabbbb
bbbbabaabaabbbbababaabab
abbbaaaaaabbbbbababbababbaaaabba
aaaaaaabaaabaababbbaaaaaaabbbbbbbbaabaaaabbaaaba
baaabbabbaaabaababbaabababbabbbabaabababaaababbbbbabbaabaabbbabb
aaaaababbaaabbaabbaaaabb
bbbabbbabaabbabaabbbabbaababaaaabbbbabbabbaabbaaaabaaabbabbbbaab
baabaabaabbbbbababaaaabbbbbabaabbbbaaaabbbbbbaabbaabbbbb
bbaaaaaabbabbaabbaabaaba
abbababbbabbbbabbaaaaaabaaaaaabaaaaaabbb
abaababbaabbbaabbabaabbb
baabababbaabababbbbaaaaabbababbbbaaaabbb
baabaabaabaabbbbbaabababbabababbbbabbbaabaaaaabaaaaabaaababbbbababbbaaabbbabaaba
abbbbaaaaaabbbaabaaaabaaaaaabbaa
baababababbaaabbbabbaabb
aaaaaabaabababbabbabbbbb
aaabbabaaabbaabbbbabaaab
abbbaabbbbbbabaaaaaabaaa
aabbabbbabaaaabbaabbbaaa
aabbababbaaabbbbabbbbbabaabaabab
bbbaababaabbbbbabbabaaaabaaaabba
bbbbababaabababaaabbabaa
ababaabbbbbbbbbaaaaabbbb
aaabababbabbaaaaababbbbb
bbbbabbabbbbbbaaaabaabbbbabbbbba
bbbababbaaababababbaababbbabbaabbabaaabaabbabaab
baaabbbaabababbaababbbaa
aaaaaababbbabbaaaabaaaaaabababababbaabaababaaaba
bbabbaabbbbbbbaabbbaaaab
babbaabaabbaaabbbbaabbbaabababbaaaabbbaabaababbbabbbaaaa
baabaabbbaaababababaaabbabbbbaaaaabaaaaababbabaaabbbbbbabaabaababbbbbaaabaaaaaaa
abbaababbbbabaabababbaba
bbaababbababababbbbbbaab
bbbbaababbaaaababaaabbaaabaabbbbbbbbbaaa
babbbaaabaababaababbbabbabbaabbabbaaaabaaababaababaabaaaabbaaaba
bbababbbabaaaaabbbbbbabb
babbabbbababaaaababbbabaaaabbababbabbbbbabababbb
abbbaabbbbaaabbbaaabbabaaaaaaababaabaabbaabbbaabababbbabbbbbbbabababbbbbaaababaa
aaaaabbabbbaaaabbaaababbbaaaababaaabbabbbabbabbaabbabaabaabbaaaaabbaabaababaabaababbabaa
baaababaababbbabbaaaabbaababbaaababababababbaabbbbbabbbababbababaaabbbbaababbaba
babbabbaabbbabaaabbaaaaa
bbbaaabaaaabababbaaabbbabababbbb
bababbbaababaaaabaabaabaaabbabbbbbabababbabbbaab
aababaaaabaabbabbabaabaa
aababbaaaaabbaabaaaababa
babbbbaababbbbaaaaabbbaabbaababbbbabaaabbaaabbabababbbaa
abaaaababababbabbababbbabbabbaabbbaaabaa
aabbababaabbaababaaaaabbbabbaaaabababbabbbbabbaaaaabbbbb
aabaaababbaaaabbaabbabaaaaababbabababbbb
abbbbbaabbbabaaaaaaaabbaaabbbaaa
bbbbabaaaabbbababbbabbbb
bbbababaababaaabaabbabaa
abaababbbaaababbbabbbbaaabaabaab
aaabbaababbbbaaaaabbbbba
aabaaaabababbaaaaaabaabbaaaabbaa
baaabbabbbabaaabaaaabaabababbbbb
abaaaaabbbaaaaaabaababaa
bababbabbbbabbaaaaabbbab
abaaababbaabbabaaabaaabbabbbbabaaaaababaaabaaaabbbbabbbbbaabbaaa
aabababbaaabaaaaabbaabba
ababaaabbabbabaabbbaaaaaaaaaaabbaaabaaab
aabaaababbbababaaabaabaabbbbaaaaaabbaaaa
bababaaabbababbabbbabaaa
abaaabbabaaabaabbababbaa
abbbabaabbaabbbababbbbbb
aabbbbabbaaabaaabbaaabaa
bbbbabbaabbbbbbaaaababaa
abbbbabaaabababbaaabbbbb
abaaabbaabaaabbbbbaabbbb
aabaaabaaaaaaabaaaaabbba
abbabbbaababbabbaaaabbbb
babbaabaaaaaaaabbaabbbbabaaaababaabbaaaa
ababbabbabaaaabbbbbababbaabbababbbbababb
abbbabbbbabbbbabbbaabaab
baaababbbbaaabbabbbaaaab
abbbbaabbbbbaabbabaaababbaabaaab
bbbbababbbaaabaaabbababbbabbbbababaababaaaabaaaabaaaabaaabbbaabababbbabbbaaaaaababbaabbb
bbbbabaabbabaabbabbbbbabbabaaabbaabbaaab
baabbabaaabbaababbbbbaab
bbabaaabaabaaaababbbbbaabaaabbaabababbaaaabbaaabaaaababbaaaababaaaaaaaaaababbbbb
abaaaabaabbbabbbaaaaababbaaaaaab
abbbabbbaababbbbabaaaababbaaabbaabbbaabbbbabaaaa
bbaaabbabbaababbbbbabbaabaabbbbabbbaababababbbaa
bbaaaaaababbbbbbbaababaaababbaaabaabaaabbbababbabbabbbbababbaaab
bbaababbbbaaabbbababbaba
bbbaaabbbbbbabaabbabbaaa
bbbababaaababbbbbaababaa
baaaababaababaaaabbbbbbb
aabbbbabaaaababbbabaabba
baaabaabbbbabbbabbaaabbaabbbaabbbbaabaab
aabbbaabbaaaaaaabaaaaabbbbbaabab
baaaabaaaabbaabaabaaababaaaabaab
aaaaaabaaababbaabaaaaaba
aaabaaaaaabbbbabbaabbaaa
abaababbbbbabbbaaaaaaaaaaabaaabbbaabbbabaaabaabb
bbbaabbaabbababaabbabaaa
bbbababbabbabbbabbaaabbabababbaaababbbbb
abaabbbaababbbaaabbabaab
aababaabaaabbababababbbaaaabbabababbbbaaaaaabbbababbabab
bbabbbaaaaaaababbbaaaabababbabaaabbabbbbaaabbbbb
aaaaaabbbbbaaabbbbaabaaaaabbabaa
bbbaabbababbaabaaabbbbbb
abbbabaaaaaaababaababbab
bbabaabaaabbaabbaabbabba
baaaabaaaababaabbbabbbab
bbaabbbaaaabbaaaaaaaabaaaaaabbaa
aabaabaaaababaabbbbaabaabbbaaabbbbabbabb
aaabaabaabbbabbbaabbbbbb
babbaaaaabaaabbbbbaaababaaaaaabaababbbababbabbbbaaabbbba
abbababbbaabbabbabaabbabaaaaabbb
ababaaabbaaaaabbabbbabaabbaabbbaabaaaaabbaabaabbabbbaaaa
babbaaaabaabababbaaaabbb
aaabbbaaaabbbabababaabaa
bbbaaabaababbaabababaaba
aaababbaaabbaababbbbabbabbbabbab
abababbaaababaababbaabba
bbaaabbabbbbababaaaabaab''';

const part2input = '''42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba''';