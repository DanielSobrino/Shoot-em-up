import 'dart:math';

import '../environment.dart';
import 'sprite.dart';

class Bullet extends Sprite {

  Point _direct = Point(0,0);

  //Getters setters
  Point get direct => _direct;
  set direct(Point d) => _direct = d;

  Bullet.fromType(Esprites type): super.fromType(type);


  void travel() {
    int x = pos.x + _direct.x;
    int y = pos.y + _direct.y;
    this.pos = Point(x,y);
    // print("$x, $y");
    // Comprobamos si la bala ha salido del canvas para destruirla
    if(x > SCREEN_WIDTH || x + this.frameWidth * this.scale < 0 || y > SCREEN_HEIGHT || y + this.height * this.scale < 0) {
      this.hit(0);
    }
  }

  @override
  void gameHandler(String gameEvent) {
    if(gameEvent == 'newTick') {
      travel();
    }
  }

}