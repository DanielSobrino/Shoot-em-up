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
      // print("${sp.type} ${sp.pos}");
      // se generan todos los bullets
      // for(Point gun in sp.gunPos) {
      for(int i=0; i < sp.gunPos.length; i++) {
        Point gun;
        if (sp.gunPos[i] is Point) {
          gun = sp.gunPos[i];
        } else if (sp.gunPos[i].toString() == "center") {
          gun = Point(sp.frame.width / 2, sp.frame.height / 2); // Asignar centro del sprite a gunPos
        }
        Point direct = sp.gunDirection[i];
        Game.loadSprite(sp.bulletType).then((sprite) {
          Bullet bullet = sprite;
          bullet.pos = Point(gun.x * sp.scale + sp.pos.x - (bullet.frame.width * bullet.scale / 2), gun.y * sp.scale + sp.pos.y - (bullet.frame.height * bullet.scale / 2));
          bullet.direct = direct; //Point(0,-10);
          bullet.playerBullet = sp.playerBullet; // Asignamos la propiedad playerBullet del plane a la bala
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