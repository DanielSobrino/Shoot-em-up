import 'dart:math';

import '../bullet.dart';
import '../game.dart';
import '../plane.dart';
import '../sprite.dart';

mixin Shoot {

  void shoot(Sprite sp) {
    List<Bullet> bullets = [];
    List<Future> waitComplete = [];

    // el "is Plane" hace el cast automático a Plane
    if(sp is Plane) {
      // se generan todos los bullets
      for(Point gun in sp.gunPos) {
        // print('llamada a shoot');
        // Bullet bullet = Bullet.fromType(Esprites.BULLET1);
        Game.loadSprite(sp.bulletType).then((bullet) {
          bullet.pos = Point(gun.x * sp.scale + sp.pos.x, gun.y * sp.scale + sp.pos.y);
          bullet.direct = Point(0,-10);
          waitComplete.add(bullet.complete());
          bullets.add(bullet);
        });
      }
    
    }
    // una vez generados los bullets, los pasamos a waitingSpr de Game
    // para ser incluidos en el siguiente ciclo de gameloop
    Future.wait(waitComplete).then((e) {
      Game.addWaitingSpr = bullets;
    });
  }
}