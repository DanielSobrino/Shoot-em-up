import 'dart:math';
import '../environment.dart';
import 'movement.dart';

class SpriteGenerator {

  int _trigger;
  Esprites _spriteType;
  Point _pos;
  int _quantity;
  int _triggerOffset;
  static List<SpriteGenerator> _sprQueue = [];
  Movement _movement;

  static List<SpriteGenerator> get sprQueue => SpriteGenerator._sprQueue;
  int get trigger => _trigger;
  Esprites get spriteType => _spriteType;
  Point get pos => _pos;
  Movement get movement => _movement;

  SpriteGenerator( this._trigger, this._spriteType, this._pos, {Movement movement, int quantity, int triggerOffset} ) {
    this._movement = movement;
    this._quantity = quantity ?? 1;
    this._triggerOffset = triggerOffset ?? 10;
    _sprQueue.add(this);
    // ahora creamos todos los elementos de la lista
    while( --this._quantity > 0 ) {
      int newTrigger = _trigger + _triggerOffset * _quantity;
      Movement tmp_mv = movement == null ? null : Movement.clone(this._movement);
      SpriteGenerator(newTrigger, this._spriteType, this._pos, movement: tmp_mv);
    }
    // ordenar la lista según valor de trigger
    _sprQueue.sort((a, b) => b._trigger.compareTo(a.trigger));
  }

  static void clearQueue() => _sprQueue.clear();
  static void removeFromQueue(SpriteGenerator elem) => _sprQueue.remove(elem);

  @override
  String toString() {
    return '$_trigger: $_spriteType pos: $_pos';
  }

}

// void main() {
//   SpriteGenerator(1950, Esprites.BIROTOR_PLANE, Point(100, 0), quantity: 5, triggerOffset: -50);
//   SpriteGenerator(1850, Esprites.BULLET1, Point(100, 0), quantity: 5, triggerOffset: -80);
//   print(SpriteGenerator.sprQueue);
// }