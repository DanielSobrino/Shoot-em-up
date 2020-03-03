import '../../environment.dart';
import 'dart:math';
import '../../classes/spriteGenerator.dart';
import '../../classes/movement.dart';

void prepareSprites(int level) {
  //----------------------------------------------------------------------------------
  //SpriteGenerator(trigger_pos, spriteType, spawn_pos, {quantity, triggerOffset movement: Movement({max_y, EmoveTypes type, desp_x, desp_y, sin_ampl, dsin_res, max_x })});
  //----------------------------------------------------------------------------------
  switch (level) {
    case 1:
      SpriteGenerator(1850, Esprites.BASIC_PLANE, Point(180, -50), quantity: 4, triggerOffset: -50, movement: Movement(desp_y: 0.5, type: EmoveTypes.WAVE, sin_ampl: 170, sin_res: 0.02));
      SpriteGenerator(1650, Esprites.BIROTOR_PLANE, Point(60, -70), quantity: 2, triggerOffset: -150, movement: Movement(type: EmoveTypes.LINEAR, desp_y: 0.8));
      SpriteGenerator(1500, Esprites.BACKW_PLANE, Point(250, -50), quantity: 3, triggerOffset: -50, movement: Movement(type: EmoveTypes.ZIGZAG, max_x: 60));
      SpriteGenerator(1250, Esprites.BASIC_PLANE, Point(100, -50), quantity: 4, triggerOffset: -50, movement: Movement(desp_y: 0.5, type: EmoveTypes.WAVE, sin_ampl: 100, sin_res: 0.02));
      SpriteGenerator(1250, Esprites.BASIC_PLANE, Point(300, -50), quantity: 4, triggerOffset: -50, movement: Movement(desp_y: 0.5, type: EmoveTypes.WAVE, sin_ampl: 100, sin_res: 0.02));
      SpriteGenerator(1200, Esprites.BIROTOR_PLANE, Point(250, -70), quantity: 2, triggerOffset: -150, movement: Movement(desp_y: 0.5, type: EmoveTypes.WAVE, sin_ampl: 30, sin_res: 0.02));
      SpriteGenerator(1050, Esprites.BACKW_PLANE, Point(440, -50), quantity: 2, triggerOffset: -50, movement: Movement(type: EmoveTypes.LINEAR, desp_x: -1.3));
      SpriteGenerator(1050, Esprites.BASIC_PLANE, Point(300, -50), quantity: 4, triggerOffset: -50, movement: Movement(desp_y: 0.5, type: EmoveTypes.WAVE, sin_ampl: 70, sin_res: 0.02));
      SpriteGenerator(1050, Esprites.BACKW_PLANE, Point(300, -50), quantity: 2, triggerOffset: -50, movement: Movement(type: EmoveTypes.ZIGZAG, max_x: 80));
      SpriteGenerator(750, Esprites.BIROTOR_PLANE, Point(440, 0), quantity: 3, triggerOffset: -80, movement: Movement(type: EmoveTypes.LINEAR, desp_x: -0.5, desp_y: 0.5));
      SpriteGenerator(650, Esprites.BIROTOR_PLANE, Point(-90, 0), quantity: 3, triggerOffset: -80, movement: Movement(type: EmoveTypes.LINEAR, desp_x: 0.5, desp_y: 0.5));
      SpriteGenerator(450, Esprites.BASIC_PLANE, Point(180, -50), quantity: 4, triggerOffset: -50, movement: Movement(desp_y: 0.5, type: EmoveTypes.WAVE, sin_ampl: 170, sin_res: 0.02));
      break;
      //----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  }

}


