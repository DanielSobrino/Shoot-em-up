import 'dart:math';
import '../../environment.dart';

Map<Esprites, Map<String, dynamic>> spriteTypes = {
  // AVIONES -----------------------------------------------
  Esprites.PLAYER: {
    "fileName": "planes/player.png",
    "scale": 1,
    "frames": 1,
    "hitboxes": [
      [29,1,35,58],
      [18,16,46,22],
      [0,22,64,31],
      [20,33,44,48],
      [13,51,51,58]
    ],
    "shootType": EshootTypes.PLAYER
  },
  Esprites.PLAYER_F: { 
    //para las hitbox flipped, coger el máximo de height, y restarle el número anterior. (a los pares) Y menor a mayor
    "fileName": "planes/player_flipped.png",
    "scale": 1,
    "frames": 1,
    "hitboxes": [
      [29,0,35,57],
      [18,36,46,42],
      [0,27,64,36],
      [20,10,44,25],
      [13,0,51,7]
    ],
    "shootType": EshootTypes.PLAYER_F
  },

  Esprites.BASIC_PLANE: {
    "fileName": "planes/plane1_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [12,2,20,28],
      [2,5,30,13]
    ],
    "gunPos": [
      Point(15,2)
    ],
    "shootType": EshootTypes.BASIC,
    "score": 50

  },
  Esprites.BASIC_PLANE_F: {
    "fileName": "planes/plane1_flipped_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [12,1,20,27],
      [2,16,30,24]
    ],
    "gunPos": [
      Point(15,2)
    ],
    "shootType": EshootTypes.BASIC_F,
    "score": 50

  },

  Esprites.BACKW_PLANE: {
    "fileName": "planes/plane_turret_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [12,2,20,28],
      [2,5,30,13]
    ],
    "shootType": EshootTypes.DOUBLE,
    "score": 50
  },

  Esprites.BACKW_PLANE_F: {
    "fileName": "planes/plane_turret_flipped_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [12,1,20,27],
      [2,16,30,24]
    ],
    "shootType": EshootTypes.DOUBLE_F,
    "score": 50
  },

  Esprites.HELICOPTER: {
    "fileName": "planes/helicopter_spritesheet.png",
    "frames": 5,
    "scale": 1.5,
    "frameDuration": 30,
    "hitboxes": [
      [15,2,20,33],
      [8,11,27,15]
    ],
    "power": 3,
    "score": 75
  },

  Esprites.HELICOPTER_F: {
    "fileName": "planes/helicopter_flipped_spritesheet.png",
    "frames": 5,
    "scale": 1.5,
    "frameDuration": 30,
    "hitboxes": [
      [15,2,20,33],
      [8,20,27,24]
    ],
    "power": 3,
    "score": 75
  },

  Esprites.BIROTOR_PLANE: {
    "fileName": "planes/birotor_plane_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [2,7,46,15],
      [11,4,37,39],
      [21,0,27,4]
    ],
    "power": 5,
    "shootType": EshootTypes.TRIPLE,
    "score": 125
  },
  Esprites.BIROTOR_PLANE_F: {
    "fileName": "planes/birotor_plane_flipped_spritesheet.png",
    "frames": 4,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [2,25,46,33],
      [11,1,37,36],
      [21,36,27,40]
    ],
    "power": 5,
    "shootType": EshootTypes.TRIPLE_F,
    "score": 125
  },

  Esprites.FIGHTER_JET: {
    "fileName": "planes/fighter_jet_spritesheet.png",
    "frames": 2,
    "scale": 1.5,
    "frameDuration": 50,
    "hitboxes": [
      [0,14,31,20],
      [6,27,25,31],
      [11,7,20,27],
      [14,1,17,7]
    ],
    "score": 75
  },
  // Esprites.FIGHTER_JET_F: {
  //   "fileName": "planes/fighter_jet_flipped_spritesheet.png",
  //   "frames": 2,
  //   "scale": 1.5,
  //   "frameDuration": 50,
  //   "hitboxes": [
  //     [0,16,31,22],
  //     [6,5,25,9],
  //     [11,9,20,29],
  //     [14,29,17,35]
  //   ],
  //   "score": 75
  // },
  // EFECTOS -----------------------------------------------
  Esprites.EXPLOSION1: {
    "fileName": "explosions/explosion1_spritesheet.png",
    "frames": 6,
    "scale": 1.5,
    "frameDuration": 100,
    "hitboxes": [],
    "audio": Esounds.EXPLOSION1
  },
  Esprites.EXPLOSION_MEDIUM: {
    "fileName": "explosions/explosion_medium_spritesheet.png",
    "frames": 7,
    "scale": 1.5,
    "frameDuration": 100,
    "hitboxes": [],
    "audio": Esounds.EXPLOSION_MEDIUM
  },

  Esprites.HIT_LIGHT: {
    "fileName": "explosions/destello_spritesheet.png",
    "frames": 2,
    "scale": 1.5,
    "hitboxes": []
  },
  // BALAS -----------------------------------------------
  Esprites.BULLET1: {
    "fileName": "bullets/bullet1_spritesheet.png",
    "frames": 2,
    "frameDuration": 100,
    "hitboxes": [
      [0,1,3,5]
    ],
    "power": 1
  },

  Esprites.BULLET_ENEM1: {
    "fileName": "bullets/bullet_enem_spritesheet.png",
    "frames": 2,
    "scale": 1,
    "frameDuration": 100,
    "hitboxes": [
      [0,0,9,9]
    ],
    "power": 1
  }

};