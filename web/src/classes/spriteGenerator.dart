import 'dart:math';
import '../environment.dart';

class SpriteGenerator {

  int _trigger;
  Esprites _spriteType;
  Point _pos;
  int _quantity;
  int _triggerOffset;
  static List<SpriteGenerator> _sprQueue = [];

  static List<SpriteGenerator> get sprQueue => SpriteGenerator._sprQueue;
  int get trigger => _trigger;
  Esprites get spriteType => _spriteType;
  Point get pos => _pos;

  SpriteGenerator( this._trigger, this._spriteType, this._pos, {int quantity, int triggerOffset} ) {
    this._quantity = quantity ?? 1;
    this._triggerOffset = triggerOffset ?? 0;
    _sprQueue.add(this);
    // ahora creamos todos los elementos de la lista
    while( --this._quantity > 0 ) {
      int newTrigger = _trigger + _triggerOffset * _quantity;
      SpriteGenerator( newTrigger, this._spriteType, this._pos );
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

void main() {
  SpriteGenerator(1950, Esprites.BIROTOR_PLANE, Point(100, 0), quantity: 5, triggerOffset: -50);
  SpriteGenerator(1850, Esprites.BULLET1, Point(100, 0), quantity: 5, triggerOffset: -80);
  print(SpriteGenerator.sprQueue);
}