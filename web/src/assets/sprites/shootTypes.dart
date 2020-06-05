import 'dart:math';
import '../../environment.dart';

Map<EshootTypes, Map<String, dynamic>> shootTypes = {
  EshootTypes.PLAYER: {
    "bulletType": Esprites.BULLET1,
    "direction": [
      Point(0,-10),
      Point(0,-10)
    ],
    // mover un px a la izquierda en gimp
    "gunPos": [
      Point(8,21),
      Point(54,21)
    ],
    "shootRate": null,
    "playerBullet": true
  },
  EshootTypes.PLAYER_F: {
    "bulletType": Esprites.BULLET1,
    "direction": [
      Point(0,10),
      Point(0,10)
    ],
    // mover un px a la izquierda en gimp
    "gunPos": [
      Point(8,21),
      Point(54,21)
    ],
    "shootRate": null,
    "playerBullet": true
  },
  EshootTypes.BASIC: {
    "bulletType": Esprites.BULLET_ENEM1,
    "direction": [
      Point(0,4.5)
    ],
    "gunPos": [
      "center"
    ],
    "shootRate": 2100,
    "randomRate": 400
  },
  EshootTypes.DOUBLE: {
    "bulletType": Esprites.BULLET_ENEM1,
    "direction": [
      Point(-1.2,4),
      Point(1.2,4)
    ],
    "gunPos": [
      "center",
      "center"
    ],
    "shootRate": 3000,
    "randomRate": 600
  },
  EshootTypes.TRIPLE: {
    "bulletType": Esprites.BULLET_ENEM1,
    "direction": [
      Point(-1.5,4),
      Point(0,4.5),
      Point(1.5,4)
    ],
    "gunPos": [
      "center",
      "center",
      "center"
    ],
    "shootRate": 4500,
    "randomRate": 900
  },
  EshootTypes.BASIC_F: {
    "bulletType": Esprites.BULLET_ENEM1,
    "direction": [
      Point(0,-4.5)
    ],
    "gunPos": [
      "center"
    ],
    "shootRate": 2100,
    "randomRate": 400
  },
  EshootTypes.DOUBLE_F: {
    "bulletType": Esprites.BULLET_ENEM1,
    "direction": [
      Point(-1.2,-4),
      Point(1.2,-4)
    ],
    "gunPos": [
      "center",
      "center"
    ],
    "shootRate": 3000,
    "randomRate": 600
  },
  EshootTypes.TRIPLE_F: {
    "bulletType": Esprites.BULLET_ENEM1,
    "direction": [
      Point(-1.5,-4),
      Point(0,-4.5),
      Point(1.5,-4)
    ],
    "gunPos": [
      "center",
      "center",
      "center"
    ],
    "shootRate": 4500,
    "randomRate": 900
  },
  
};