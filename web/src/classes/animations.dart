import '../environment.dart';
import 'dart:math';
import 'dart:html';
import 'levelMap.dart';
import 'sprite.dart';

void takeOff(Sprite sprite, CanvasRenderingContext2D ctx, LevelMap lMap, int mStart) async {
    double s = 0.5;
    double scale = sprite.scale;
    for (var y = 865; y > 650; y--) {
      int center_pos_x = sprite.width * sprite.scale ~/ 2;
      int center_pos_y = sprite.height * sprite.scale ~/ 2;
      sprite.pos = Point(SCREEN_WIDTH/2 - center_pos_x, center_pos_y + y);
      sprite.scale = s;
      if (y < 800) {
        s = s >= scale ? scale : s + 0.01;
      }
      ctx.putImageData(lMap.map_ctx.getImageData(0, mStart, SCREEN_WIDTH, SCREEN_HEIGHT), 0, 0);
      ctx.drawImageScaled(sprite.frame, sprite.pos.x, sprite.pos.y, sprite.frame.width * sprite.scale, sprite.frame.height * sprite.scale);
      
      await Future.delayed(Duration(milliseconds: 10));
    }
    sprite.scale = scale;
  }