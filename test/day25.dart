import 'package:test/test.dart';

int transform(int value, int subject) =>
(value * subject) % 20201227;

int transformLoop(int loopSize, [int subject = 7]) {
  var result = 1;
  for (var i = 0; i < loopSize; i++) {
    result = transform(result, subject);
  }
  return result;
}

int guessLoop(int value, int subject) {
  var result = 1;
  var count = 0;
  while (result != value) {
    result = transform(result, subject);
    count++;
  }
  return count;
}
void  main() {
  test('sample', () {
      expect(guessLoop(sample.first,7), 8);
      expect(guessLoop(sample.last,7), 11);
      expect(transformLoop(8, sample.last), 14897079);
      expect(transformLoop(11, sample.first), 14897079);
  });

  test('part1', () {
      var loop = guessLoop(input.first, 7);
      print(transformLoop(loop, input.last));
  });
}
const input = [17115212, 3667832];

const sample = [5764801, 17807724];
