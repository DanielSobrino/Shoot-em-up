import 'dart:math';
import '../../environment.dart';

Map<Esprites, Map<String, dynamic>> spriteTypes = {
  
  Esprites.PLAYER: {
    "fileName": "plane1_spritesheet.png",
    "frames": 4,
    "scale": 2.0,
    "frameDuration": 50,
    "hitboxes": [
      [12,2,20,28],
      [2,5,30,13]
    ],
    // mover un px a la izquierda en gimp
    "gunPos": [
      Point(2,3),
      Point(26,3)
    ],
    "bulletType": Esprites.BULLET1
  },

  Esprites.BASIC_PLANE: {
    "fileName": "plane_red_spritesheet.png",
    "frames": 4,
    "scale": 1.8,
    "frameDuration": 50,
    "hitboxes": [
      [12,2,20,28],
      [2,5,30,13]
    ],
  },

  Esprites.BACKW_PLANE: {
    "fileName": "plane_turret_spritesheet.png",
    "frames": 4,
    "scale": 1.8,
    "frameDuration": 50,
    "hitboxes": [
      [12,2,20,28],
      [2,5,30,13]
    ],
  },

  Esprites.HELICOPTER: {
    "fileName": "helicopter_spritesheet.png",
    "frames": 5,
    "scale": 2.0,
    "frameDuration": 30,
    "hitboxes": [
      [15,2,20,33],
      [8,11,27,15]
    ]
  },

  Esprites.BIROTOR_PLANE: {
    "fileName": "birotor_plane_spritesheet.png",
    "frames": 4,
    "scale": 2.0,
    "frameDuration": 50,
    "hitboxes": [
      [2,7,46,15],
      [11,4,37,39],
      [21,0,27,4]
    ]
  },

  Esprites.EXPLOSION1: {
    "fileName": "explosion1_spritesheet.png",
    "frames": 6,
    "scale": 2.0,
    "frameDuration": 50,
    "hitboxes": []
  },

  Esprites.BULLET1: {
    "fileName": "bullet1.png",
    "frames": 1,
    "scale": 2.0,
    "hitboxes": [
      [0,1,3,6]
    ]
  }

};