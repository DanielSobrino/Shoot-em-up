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
  EshootTypes.BASIC: {
    "bulletType": Esprites.BULLET_ENEM1,
    "direction": [
      Point(0,4.5)
    ],
    "gunPos": [
      "center"
    ],
    "shootRate": 2000,
    "randomRate": 1500
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
    "shootRate": 4000,
    "randomRate": 2500
  },
  
};