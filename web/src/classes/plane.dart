import 'dart:math';
import 'dart:async';

import '../assets/sprites/spriteTypes.dart';
import '../assets/sprites/shootTypes.dart';
import '../environment.dart';
import 'mixins/shoot.dart';
import 'sprite.dart';


class Plane extends Sprite with Shoot {

  List<dynamic> _gunPos = [];
  List<Point> _gunDirection;
  Esprites _bulletType;
  EshootTypes _shootType;
  int _score_value;
  bool _playerBullet; // para marcar si la bala es del jugador
  int _shootRate; // delay entre disparos
  int _randomRate; // delay random que se añade entre disparos
  bool _isCache; //si es del caché no dispara
  bool _gamePaused = false; // captura la pausa de game

  Plane(fileName,  type, {int frames, double scale, int frameDuration}):
        super(fileName, type, frames:frames, scale:scale, frameDuration:frameDuration);

  // cargamos las propiedades comunes y específicas
  Plane.fromType(Esprites type, {bool isCache}): super.fromType(type) {
    Map<String, dynamic> spr_type = spriteTypes[type];
    _shootType = spr_type['shootType'];
    _score_value = spr_type['score'];
    _isCache = isCache ?? false;
    prepareShoot();
  }
  
  // getters
  List<dynamic> get gunPos => _gunPos;
  List<Point> get gunDirection => _gunDirection;
  int get score_value => _score_value;
  Esprites get bulletType => _bulletType;
  bool get playerBullet => _playerBullet;

  // para poder disparar el plane debe estar completo
  void prepareShoot() {
    // sólo se asignan las propiedades si existe shootType
    if(_shootType != null && !_isCache) {
      this.complete().then((e) {
        Map<String, dynamic> shoot_type = shootTypes[_shootType];
        _gunPos = shoot_type['gunPos'];
        _bulletType = shoot_type['bulletType'];
        _gunDirection = shoot_type['direction'];
        _shootRate = shoot_type['shootRate'];
        _randomRate = shoot_type['randomRate'] ?? 0;
        _playerBullet = shoot_type['playerBullet'] ?? false;
        // una vez leidas las propiedades, se genera el timer para los disparos automáticos
        if (_shootRate != null) {
          loopShoot();
        }
      });
    }
  }

  void loopShoot() async {
    int shotDelay = _shootRate + Random().nextInt(_randomRate);
    if(!this.onDestroy) {
      if(!_gamePaused) {
        planeShoot();
        await Future.delayed(Duration(milliseconds: shotDelay));
      }
      loopShoot();
    }
  
  }

  // para llamar al shoot del mixin pasándole el plane
  void planeShoot() => shoot(this);

  @override
  void gameHandler(Map<String, dynamic> gameEvent) {
    super.gameHandler(gameEvent);

    if(gameEvent.containsKey("pauseOn")) {
      print('activada la pausa en plane');
      this._gamePaused = true;
    }
    if(gameEvent.containsKey("pauseOff")) {
      print('desactivada la pausa en plane');
      this._gamePaused = false;
    }
    
  }

  
}