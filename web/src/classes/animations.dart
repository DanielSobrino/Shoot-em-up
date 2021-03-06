import '../environment.dart';
import 'dart:math';
import 'dart:html';
import 'levelMap.dart';
import 'sprite.dart';

void takeOff(Sprite sprite, CanvasRenderingContext2D ctx, LevelMap lMap, int mStart) async {
  double s = 0.3;
  double scale = sprite.scale;
  for (var y = 865; y > 650; y--) {
    double center_pos_x = sprite.width * sprite.scale / 2;
    double center_pos_y = sprite.height * sprite.scale / 2;
    sprite.pos = Point(SCREEN_WIDTH/2 - center_pos_x, center_pos_y + y);
    sprite.scale = s;
    if (y < 800) {
      s = s >= scale ? scale : s + 0.005;
    }
    ctx.putImageData(lMap.map_ctx.getImageData(0, mStart, SCREEN_WIDTH, SCREEN_HEIGHT), 0, 0);
    ctx.drawImageScaled(sprite.frame, sprite.pos.x, sprite.pos.y, sprite.frame.width * sprite.scale, sprite.frame.height * sprite.scale);
    
    await Future.delayed(Duration(milliseconds: 10));
  }
  sprite.scale = scale;
}

void endLevelAnim(Sprite sprite, CanvasRenderingContext2D ctx, LevelMap lMap, mEnd) async {
  sprite.invulnerability = true; //por si viene alguna bala por detrás mientras está la animación
  int center_point = (SCREEN_WIDTH / 2 - sprite.width * sprite.scale / 2).toInt();
  while(sprite.pos.y > -80) {
    sprite.pos = Point(sprite.pos.x, sprite.pos.y - 0.5);
    if (sprite.pos.x != center_point) {
      int currPosX = sprite.pos.x.toInt();
      currPosX = currPosX < center_point ? currPosX + 1 : currPosX;
      currPosX = currPosX > center_point ? currPosX - 1 : currPosX;
      sprite.pos = Point(currPosX, sprite.pos.y);

      ctx.putImageData(lMap.map_ctx.getImageData(0, mEnd, SCREEN_WIDTH, SCREEN_HEIGHT), 0, 0);
      ctx.drawImageScaled(sprite.frame, currPosX, sprite.pos.y, sprite.frame.width * sprite.scale, sprite.frame.height * sprite.scale);
    }
    await Future.delayed(Duration(milliseconds: 50));
  }
  sprite.hit(0);
    
}