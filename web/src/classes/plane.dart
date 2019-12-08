import 'dart:math';

import '../assets/sprites/spriteTypes.dart';
import '../environment.dart';
import 'mixins/shoot.dart';
import 'sprite.dart';


class Plane extends Sprite with Shoot {

  List<Point> _gunPos = [];
  Esprites _bulletType;

  Plane(fileName,  type, {int frames, double scale, int frameDuration}): 
        super(fileName, type, frames:frames, scale:scale, frameDuration:frameDuration);
  
  // cargamos las propiedades comunes y el resto
  Plane.fromType(Esprites type): super.fromType(type) {
    Map<String, dynamic> spr_type = spriteTypes[type];
    _gunPos = spr_type['gunPos'];
    _bulletType = spr_type['bulletType'];
  }

  // getters
  List<Point> get gunPos => _gunPos;
  Esprites get bulletType => _bulletType;

  // para llamar al shoot del mixin pasándole el plane
  void planeShoot() => shoot(this);

}