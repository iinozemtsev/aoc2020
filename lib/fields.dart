class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  operator ==(Object other) {
    if (other is Position) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  @override
  int get hashCode => x ^ y;

  @override
  String toString() => 'Position($x, $y)';

  Offset operator -(Position other) => Offset(x - other.x, y - other.y);
  Position operator +(Offset offset) => Position(x + offset.dx, y + offset.dy);
}

class Offset {
  final int dx;
  final int dy;

  const Offset(this.dx, this.dy);

  @override
  operator ==(Object other) {
    if (other is Offset) {
      return dx == other.dx && dy == other.dy;
    }
    return false;
  }

  @override
  int get hashCode => dx ^ dy;

  @override
  String toString() => 'Offset($dx, $dy)';

  Offset operator -() => Offset(-dx, -dy);
}
