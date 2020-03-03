import 'dart:math';

import '../environment.dart';
import 'sprite.dart';

class Bullet extends Sprite {

  Point _direct = Point(0,0);
  bool _playerBullet = false;

  //Getters setters
  Point get direct => _direct;
  bool get playerBullet => _playerBullet;
  set direct(Point d) => _direct = d;
  set playerBullet(bool pb) => _playerBullet = pb;

  Bullet.fromType(Esprites type): super.fromType(type);


  void travel() {
    double x = pos.x + _direct.x;
    double y = pos.y + _direct.y;
    this.pos = Point(x,y);
    // print("$x, $y");
    // Comprobamos si la bala ha salido del canvas para destruirla
    if(x > SCREEN_WIDTH || x + this.frameWidth * this.scale < 0 || y > SCREEN_HEIGHT || y + this.height * this.scale < 0) {
      this.hit(0);
    }
  }

  @override
  void gameHandler(Map<String, dynamic> gameEvent) {
    if(gameEvent.containsKey("newTick")) {
      travel();
    }
  }

}