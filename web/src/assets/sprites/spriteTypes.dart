import 'dart:math';
import '../../environment.dart';

Map<Esprites, Map<String, dynamic>> spriteTypes = {
  
  Esprites.PLAYER: {
    "fileName": "player.png",
    "frames": 1,
    "hitboxes": [
      [15,1,19,30],
      [1,11,33,16],
      [10,18,24,24],
      [8,25,26,29]
    ],
    // mover un px a la izquierda en gimp
    "gunPos": [
      Point(3,8),
      Point(27,8)
    ],
    "bulletType": Esprites.BULLET1
  },

  Esprites.BASIC_PLANE: {
    "fileName": "plane1_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [12,2,20,28],
      [2,5,30,13]
    ],
  },

  Esprites.BACKW_PLANE: {
    "fileName": "plane_turret_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [12,2,20,28],
      [2,5,30,13]
    ],
  },

  Esprites.HELICOPTER: {
    "fileName": "helicopter_spritesheet.png",
    "frames": 5,
    "scale": 1.5,
    "frameDuration": 30,
    "hitboxes": [
      [15,2,20,33],
      [8,11,27,15]
    ],
    "power": 2
  },

  Esprites.BIROTOR_PLANE: {
    "fileName": "birotor_plane_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [2,7,46,15],
      [11,4,37,39],
      [21,0,27,4]
    ],
    "power": 5
  },

  Esprites.FIGHTER_JET: {
    "fileName": "fighter_jet_spritesheet.png",
    "frames": 2,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [0,14,31,20],
      [6,27,25,31],
      [11,7,20,27],
      [14,1,17,7]
    ]
  },

  Esprites.EXPLOSION1: {
    "fileName": "explosion1_spritesheet.png",
    "frames": 6,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": []
  },

  Esprites.HIT_LIGHT: {
    "fileName": "destello_spritesheet.png",
    "frames": 2,
    "scale": 1.5,
    "hitboxes": []
  },

  Esprites.BULLET1: {
    "fileName": "bullet1_spritesheet.png",
    "frames": 2,
    "frameDuration": 100,
    "hitboxes": [
      [0,1,3,5]
    ]
  },

  Esprites.BULLET_ENEM1: {
    "fileName": "bullet_enem_spritesheet.png",
    "frames": 2,
    "scale": 1.5,
    "frameDuration": 100,
    "hitboxes": [
      [0,0,9,9]
    ]
  }

};