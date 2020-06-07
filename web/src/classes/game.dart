import 'dart:html' as html;
import 'dart:async';
import 'dart:math';

import '../../src/environment.dart';
import 'bullet.dart';
import 'levelMap.dart';
import 'plane.dart';
import 'sprite.dart';
import 'spriteGenerator.dart';
import 'animations.dart';
import '../assets/maps/level_sprites.dart';
import 'sound.dart';
import 'movement.dart';

html.CanvasElement _canvas;
html.CanvasRenderingContext2D _ctx;

// final LevelMap levelMap = LevelMap.fromJson(level1);
class Game {

  LevelMap levelMap;
  static List<Sprite> _spr = []; // sprites activos en el gameloop
  static List<Sprite> _waitingSpr = [];
  List<Sprite> enemies = [];

  Plane player;
  int player_health;
  Sprite player_shield;
  List<html.ImageElement> healthbar = [];


  // variables de score
  static int score = 0;
  int created_enemies = 0;
  int defeated_enemies = 0;

  int inc_step = 5;

  int aFrame;
  int fps = 0, fpsTotal = 0;

  // enemigos pendientes durante el nivel
  // List<SpriteGenerator> _pendingEnemies = [];

  Map<int, bool> pressed = {
    html.KeyCode.DOWN: false, html.KeyCode.UP: false, html.KeyCode.LEFT: false, 
    html.KeyCode.RIGHT: false, html.KeyCode.CTRL: false
  };
  // tiempo entre disparos
  int _lastShotTime = 0;
  int _shotDelay = 400;
  // control del bucle de gameloop
  bool endGame = false;
  bool winGame = false;

  //setter para añadir sprites en espera
  static set addWaitingSpr(List<Sprite> sp) => _waitingSpr.addAll(sp);
  // stream para control del timing
  static StreamController _gameTick = StreamController<dynamic>.broadcast();
  // static get gameTick => _gameTick.stream;
  // stream para control del menu
  static StreamController menuCtrl = StreamController<dynamic>();

  // posiciones mapa
  static double _mapPos = 0; //posición desde donde se va a dibujar
  double _mapStep  = 0.6; //pixels verticales a desplazar
  static get mapPos => _mapPos;

  //---DEBUG---
  bool debug = false;
  bool showHitboxes = false;
  bool pause = false;


  // Game(int level) {
  //   init().then((resp) {
  //     // gameLoop(0);
  //     initLevel(level);
  //   });
  // }

  Future init() async {
    _canvas = html.querySelector('#canvas');
    _ctx = _canvas.getContext('2d');
    _canvas..width = SCREEN_WIDTH ..height = SCREEN_HEIGHT;
    _ctx.imageSmoothingEnabled = false;
    // para generar la cache de imágenes
    for(Esprites esptype in Esprites.values) {
      Sprite sp = await loadSprite(esptype, isCache: true);
      sp.hit(0);
    }
    print('fin cache de imagenes');
    // Carga de las imágenes de la healthbar
    for (int i = 0; i < 10; i++) {
      healthbar.add(html.ImageElement(src: 'src/assets/sprites/healthbar/${i}_health.png'));
    }
    //Keyboard listenners
    html.window.addEventListener('keydown', (e) => keyDown(e));
    html.window.addEventListener('keyup', (e) => keyUp(e));
    //mostrar fps
    Timer.periodic(Duration(seconds: 1), (t) {fpsTotal = fps; fps = 0;});
  }

  void initLevel(int level) async {
    // INICIALIZAR VARIABLES
    _spr.clear();
    _waitingSpr.clear();
    enemies.clear();
    score = 0;
    player_health = 9;
    created_enemies = 0;
    defeated_enemies = 0;
    endGame = false;
    winGame = false;
    _mapPos = 0;

    _gameTick = StreamController<dynamic>.broadcast();
    // cargamos el mapa
    levelMap = await LevelMap.FromFile('/src/assets/maps/level${level}.json');
    
    // propiedades para el mapa
    int maxMapPos = levelMap.map_cnv.height - SCREEN_HEIGHT;
    // _mapPos = 10; //FIXME:
    _mapPos = maxMapPos.toDouble();
    // print(_mapPos); // debug acabar rápido
    //vaciamos la cola de spriteGeneratos
    SpriteGenerator.clearQueue();
    //Preparamos los sprites del nivel
    prepareSprites(level);
    //Creación del jugador
    player = await loadSprite(Esprites.PLAYER);
    player.pos = Point(SCREEN_WIDTH/2 - player.width/4, 670);
    _spr.add(player);
    // player.setFlicker(ticks: 100, invulnerable: true); // parpadeo player
    if (!debug) {
      await takeOff(player, _ctx, levelMap, mapPos.toInt());
    }
    // player.invulnerability = true;
    //Reproducimos música de fondo
    Sound.loop(Esounds.BG_MUSIC);

    
    // LLAMADA GAME LOOP
    gameLoop(0);

  }

  void gameLoop(num f) {
    if(!endGame) {
      kybControl();
      if(!pause) updateState();
      draw();
      aFrame = html.window.requestAnimationFrame((f) => gameLoop(f));
    } else {
      _gameTick.sink.close(); // paramos el streamController
      _spr.forEach((s) => s.hit(0)); // eliminamos todos los Sprites
      // Comprobamos si ha ganado
      if (winGame) {
        endLevelAnim(player, _ctx, levelMap);
        // calcular estrellas basado en e_d / e_c 
        double efficiency = defeated_enemies / created_enemies;
        int stars = efficiency < 0.4 ? 1 : efficiency < 0.9 ? 2 : 3;
        menuCtrl.sink.add({'victory': stars});

        // print(efficiency);
        // print('c: $created_enemies');
        // print('d: $defeated_enemies');

      } else {
        menuCtrl.sink.add({'defeat': 1});
      }
      html.window.cancelAnimationFrame(aFrame);

    }
  }

  void showText(String txt) {
    _ctx.font = 'bold 48px roboto';
    _ctx.setFillColorRgb(0xff, 0xff, 0xff);
    _ctx.fillRect(90, SCREEN_HEIGHT / 2 - 40, 220, 50);
    _ctx.setFillColorRgb(0x00, 0x00, 0x00);
    _ctx.fillText(txt, 100, SCREEN_HEIGHT/2);
  }


  static Future<Sprite> loadSprite(Esprites type, {int frames, double scale, int frameDuration, bool isCache}) async {
    Sprite newSpr;
    switch(type) {
      case Esprites.PLAYER:
      case Esprites.PLAYER_F:
      case Esprites.BACKW_PLANE:
      case Esprites.BACKW_PLANE_F:
      case Esprites.BASIC_PLANE:
      case Esprites.BASIC_PLANE_F:
      case Esprites.BIROTOR_PLANE:
      case Esprites.BIROTOR_PLANE_F:
      case Esprites.FIGHTER_JET:
      case Esprites.HELICOPTER:
      case Esprites.HELICOPTER_F:
        newSpr = Plane.fromType(type, isCache: isCache);
        break;
      case Esprites.EXPLOSION1:
      case Esprites.EXPLOSION_MEDIUM:
      case Esprites.HIT_LIGHT:
      case Esprites.POW_POWERUP:
      case Esprites.SHIELD:
      case Esprites.SHIELD_POWERUP:
      case Esprites.DAMAGE_POWERUP:
        newSpr = Sprite.fromType(type);
        break;
      case Esprites.BULLET1:
      case Esprites.BULLET_ENEM1:
      case Esprites.BULLET_DMG_BOOST:
        newSpr = Bullet.fromType(type);
        break;
      default: 
        newSpr = Sprite.fromType(type);
        print('sprite genérico del tipo: $type');
    }
    newSpr.strmSubs = _gameTick.stream;
    await newSpr.complete();
    return newSpr;
  }

  void updateState() {
    //Eliminar sprites antes de iterarlos para evitar excepciones
    _spr = _spr.where((d) => !d.destroy).toList();
    //Comprobar trigger de enemigos y crearlos
    checkEnemyTrigger();
    //Añadir los sprites pendientes
    _spr.addAll(_waitingSpr);
    _waitingSpr.clear();
    //Enviamos el evento de tick para ser procesado por los sprites
    _gameTick.sink.add({'newTick':null});
    //Comprobar colisiones
    collisions();
    //actualizar posición mapa
    _mapPos = _mapPos > _mapStep ? _mapPos - _mapStep : 0;
    if (_mapStep > _mapPos) {
      winGame = !player.onDestroy;
      gameOver();
    }
    _gameTick.sink.add({'mapPos':_mapPos});
    //rebote sprites
    // moveSpr(enemies);
  }

  // Gestión de colisiones
  void collisions() {
    int pw_left;
    // listas para los bullets
    List<Sprite> player_bullets = _spr.where((s) => s is Bullet && s.playerBullet).toList();
    List<Sprite> enemy_bullets = _spr.where((s) => s is Bullet && !s.playerBullet).toList();
    List<Sprite> pow_powerups = _spr.where((s) => s.type == Esprites.POW_POWERUP).toList();
    List<Sprite> shield_powerups = _spr.where((s) => s.type == Esprites.SHIELD_POWERUP).toList();
    List<Sprite> damage_powerups = _spr.where((s) => s.type == Esprites.DAMAGE_POWERUP).toList();
    // lista enemigos, debe ser Plane y no ser el Player
    List<Sprite> enemies = _spr.where((s) => s.type != Esprites.PLAYER && s is Plane).toList();
    // enemies.removeWhere((s) => s.type == Esprites.BULLET1 || s.type == Esprites.BULLET_ENEM1);
    
    //comprobar colisión jugador con damage powerup
    for (Sprite damage_pup in damage_powerups) {
      if (player.collision(damage_pup)) {
        damage_pup.hit(0);
        Sound.play(damage_pup.audio);
        player.shootType = EshootTypes.PLAYER_DMG_BOOST;
        Future.delayed(Duration(seconds: 8), () => player.shootType = EshootTypes.PLAYER);
      }
    }
    //comprobar colisión jugador con shield powerup
    for (Sprite shield_pup in shield_powerups) {
      if (player.collision(shield_pup)) {
        if (player_shield != null) {
          player_shield.hit(0);
          player_shield = null;
        }
        shield_pup.hit(0);
        Sound.play(shield_pup.audio);
        shieldPlayer();
      }
    }
    //comprobar colisión jugador con pow
    for (Sprite pow in pow_powerups) {
      if (player.collision(pow)) {
        enemies.forEach((e) {
          pw_left = e.power - pow.power;
          if(pw_left <= 0) {
            if (e.frameWidth < BIG_PLANE_WIDTH) {
              _explode(e, Esprites.EXPLOSION1, destroy: true, destroyInMillis: 300);
            } else {
              _explode(e, Esprites.EXPLOSION_MEDIUM, destroy: true, destroyInMillis: 450);
            }
            defeated_enemies++;
            score += e.score_value;
          } else {
            e.power = pw_left;
            e.setFlicker();
          }
        });
        score += pow.score_value;
        Sound.play(pow.audio);
        pow.hit(0);
      }

    }

    // comprobamos las colisiones de bullets del player y la colisión del player con otro enemigo
    for(Sprite enemy in enemies) {
      for(Sprite bullet in player_bullets) {
        if(!enemy.onDestroy && !enemy.invulnerability && enemy.collision(bullet)) {
          pw_left = enemy.power - bullet.power;
          // print('Ep: ${enemy.power}, Bp: ${bullet.power}');
          bullet.hit(0);
          _explode(bullet, Esprites.HIT_LIGHT);
          if(pw_left <= 0) {
            Random pup_drop_chance = Random();
            if (pup_drop_chance.nextDouble() < POWER_UP_DROP_ROBABILITY) {
              dropPowerUp(enemy);
            }
            if (enemy.frameWidth < BIG_PLANE_WIDTH) {
              _explode(enemy, Esprites.EXPLOSION1, destroy: true, destroyInMillis: 300);
            } else {
              _explode(enemy, Esprites.EXPLOSION_MEDIUM, destroy: true, destroyInMillis: 450);
            }
            // Añadir score del enemigo al score global
            score += enemy.score_value;
            defeated_enemies++;
          } else {
            // mostramos la explosión pequeña sin destruir el sprite
            //_explode(bullet, Esprites.HIT_LIGHT);
            enemy.power = pw_left;
            enemy.setFlicker(); // activamos parpadeo
          }
        }
      }
      // destrucción del player
      if(!enemy.onDestroy && !player.invulnerability && enemy.collision(player)) {
        pw_left = enemy.power - 1;
        enemy.power = pw_left;
        enemy.setFlicker();
        if (player_health <= 2) {
          Sound.play(Esounds.PLAYER_HURT);
          player_health = 0; // para la healthbar
          // print(player_health);
          _explode(player, Esprites.EXPLOSION1, destroy: true);
          winGame = false;
          Future.delayed(Duration(milliseconds: 800), gameOver);
        } else {
          // print('choque aviones');
          Sound.play(Esounds.PLAYER_HURT);
          player_health = player_health - 2; // el jugador recibe 2 de daño al colisionar con un enemigo
          // print(player_health);
          player.setFlicker(ticks: 40, invulnerable: true);
        }
      }
    }
    
    for (Bullet bullet in enemy_bullets) {
    // comprobación bala contra escudo
      if (player_shield != null) {
        if (player_shield.collision(bullet)) {
          bullet.hit(0);
        }
      } 
      // comprobamos si el player choca con una bala enemiga
      else if (!player.invulnerability && player.collision(bullet)) {
        bullet.hit(0);
        _explode(bullet, Esprites.HIT_LIGHT);
        if (player_health <= 1) {
          Sound.play(Esounds.PLAYER_HURT);
          player_health = 0; // para la healthbar
          // print(player_health);
          _explode(player, Esprites.EXPLOSION1, destroy: true);
          winGame = false;
          Future.delayed(Duration(milliseconds: 800), gameOver);
        } else {
          Sound.play(Esounds.PLAYER_HURT);
          player_health--; // el jugador recibe 1 de daño al colisionar con una bala
          // print(player_health);
          player.setFlicker(invulnerable: true); 
        }
      }
    }

  }

  dropPowerUp(Sprite enemy) async {
    Random rng = Random();
    double random_number = rng.nextDouble();
    Esprites power_up_type;
    if (random_number < 0.333) {
      power_up_type = Esprites.POW_POWERUP;
      print('dropeo pow');
    } else if (random_number < 0.666) {
      power_up_type = Esprites.DAMAGE_POWERUP;
      print('dropeo dmg');
    } else {
      power_up_type = Esprites.SHIELD_POWERUP;
      print('dropeo shield');
    }
    // Sprite power_up = await loadSprite(power_up_type);
    SpriteGenerator(_mapPos.toInt(), power_up_type, Point(enemy.pos.x.toInt()+5, enemy.pos.y.toInt()+5), movement: Movement(type: EmoveTypes.GROUNDED));
    //SpriteGenerator(trigger_pos, spriteType, spawn_pos, {quantity, triggerOffset movement: Movement({EmoveTypes type, desp_x, desp_y, sin_ampl, dsin_res, max_x, max_y})});

  }

  //Genera nuevos enemigos en base a SpriteGenerator
  void checkEnemyTrigger() async {
    if (SpriteGenerator.sprQueue.isEmpty) return;
    SpriteGenerator currentGen = SpriteGenerator.sprQueue[0];
    if (currentGen.trigger >= _mapPos) {
      Sprite enemy = await loadSprite(currentGen.spriteType);
      enemy.pos = currentGen.pos;
      // enemy.direct = Point(0.5, 1); //
      if (enemy.type != Esprites.POW_POWERUP) {
        enemies.add(enemy);
        // print(enemy);
        created_enemies++;
      }
      _waitingSpr.add(enemy);
      if (currentGen.movement != null) {
        currentGen.movement.startMove(enemy, mapPos: _mapPos);
        currentGen.movement.strmSubs = _gameTick.stream; // lo añadimos al stream de game
      }
      SpriteGenerator.removeFromQueue(currentGen);
    }
  }

  // muestra una explosión exp_type y se asocia a currSpr
  void _explode(Sprite currSpr, Esprites expl_type, { bool destroy = false, int destroyInMillis }) {
    // indica si debe destruirse el sprite currSpr o no
    if( destroy ) {
      currSpr.hit( destroyInMillis ?? PLANE_DESTROY_DELAY);
    }
    //   loadSprite(Esprites.EXPLOSION1).then((newSpr) {
    loadSprite(expl_type).then((newSpr) {
      Point currPos = currSpr.pos;
      double currScale = currSpr.scale;
      currSpr.child = newSpr; // Asignamos la explosión como hijo del sprite
      newSpr.complete().then((e) {
        if (newSpr.audio != null) Sound.play(newSpr.audio);
        newSpr.pos = currPos;
        newSpr.scale = currScale;
        // Añadimos la explosión a los sprites pendientes
        _waitingSpr.add(newSpr);
        newSpr.hit(newSpr.frameDuration * newSpr.framesNum); // Se programa la destrucción de la explosión
      });
    });
  }

  void shieldPlayer() async {
    Sprite shield = await loadSprite(Esprites.SHIELD);
      Point shieldPos = player.pos;
      double shieldScale = player.scale;
      player.child = shield;
      await shield.complete();
      shield.pos = shieldPos;
      shield.scale = shieldScale;
      _waitingSpr.add(shield);
      player_shield = shield;
      Future.delayed(Duration(milliseconds: shield.frameDuration * (shield.framesNum-1)), () {
        shield.hit(0);   
        player_shield = null;
      });
  }

  void draw() {
    //mapa de fondo
    _ctx.putImageData(levelMap.map_ctx.getImageData(0, _mapPos.toInt(), SCREEN_WIDTH, SCREEN_HEIGHT), 0, 0);

    //dibujar los sprites
    Iterator<Sprite> i = _spr.iterator;
    while(i.moveNext()) {
      if (i.current.showSprite) {
        _ctx.drawImageScaled(i.current.frame, i.current.pos.x, i.current.pos.y, i.current.frame.width * i.current.scale, i.current.frame.height * i.current.scale);
      }
      if(showHitboxes) {
        i.current.hitBoxes.forEach((hb) {
            _ctx.fillRect(i.current.pos.x + hb.start.x, i.current.pos.y + hb.start.y, hb.end.x - hb.start.x, hb.end.y - hb.start.y);
        });
      }
    }

    _ctx.drawImage(healthbar[player_health], 35, 850);
    
    //textos
    if (debug) {
      //fps
      fps++;
      _ctx.font = 'bold 18px serif';
      _ctx.setFillColorRgb(0x00, 0x00, 0x00);
      _ctx.fillText('fps: $fpsTotal', 360, 25);
      _ctx.fillText('sprites: ${_spr.length}  ', 260, 25);
      // created / defeated enemies
      _ctx.fillText('c_enemies: $created_enemies', 300, 50);
      _ctx.fillText('d_enemies: $defeated_enemies', 300, 75);
      _ctx.fillText('map_pos: ${_mapPos.toInt()}', 300, 100);
    }
    _ctx.font = '35px Retro';//retro.ttf';
    _ctx.fillText('SCORE: $score', 20, 30);
    
  }

  //---KEYBOARD---
  void keyDown(html.KeyboardEvent e) {
    // e.preventDefault();
    switch (e.keyCode) {
      case html.KeyCode.P:
        if(pause) {
          print('resume');
          _gameTick.sink.add({'pauseOff':null});
          // aFrame = html.window.requestAnimationFrame((f) => gameLoop(f));
        } else {
          print('pausa');
          _gameTick.sink.add({'pauseOn':null});
          // html.window.cancelAnimationFrame(aFrame);
        }
        pause = !pause;
        break;
      case html.KeyCode.H:
        this.showHitboxes = !this.showHitboxes;
        break;
      case html.KeyCode.D:
        this.debug = !debug;
        break;
      case html.KeyCode.DOWN:
      case html.KeyCode.UP:
      case html.KeyCode.LEFT:
      case html.KeyCode.RIGHT:
      case html.KeyCode.CTRL:
        pressed[e.keyCode] = true;
        break;
      // case html.KeyCode.S:
      //   if (player_shield == null) {
      //     shieldPlayer();
      //   }
      //   break;
    }
  }

  void kybControl() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if(pressed[html.KeyCode.DOWN] && player.pos.y < SCREEN_HEIGHT - player.frame.height * player.scale) {
      player.pos = Point(player.pos.x, player.pos.y + inc_step + player.frame.height * player.scale > SCREEN_HEIGHT ? SCREEN_HEIGHT - player.frame.height * player.scale : player.pos.y + inc_step);} 
    if(pressed[html.KeyCode.UP] && player.pos.y > 0) {
      player.pos = Point(player.pos.x, player.pos.y - inc_step < 0 ? 0 : player.pos.y - inc_step);} 
    if(pressed[html.KeyCode.LEFT] && player.pos.x > 0) { 
      player.pos = Point(player.pos.x - inc_step < 0 ? 0 : player.pos.x - inc_step, player.pos.y);} 
    if(pressed[html.KeyCode.RIGHT] && player.pos.x < SCREEN_WIDTH - player.frame.width * player.scale) {
      player.pos = Point(player.pos.x + inc_step + player.frame.width * player.scale > SCREEN_WIDTH ? SCREEN_WIDTH - player.frame.width * player.scale : player.pos.x + inc_step , player.pos.y);}
  
    if(pressed[html.KeyCode.CTRL] &&  currentTime - _lastShotTime > _shotDelay && !player.isFlicking && !player.onDestroy) {
      player.planeShoot();
      Sound.play(Esounds.PLAYER_SHOT);
      _lastShotTime = currentTime;
    }
  }

  void keyUp(html.KeyboardEvent e) {
    if (e.keyCode == html.KeyCode.DOWN || e.keyCode == html.KeyCode.UP || e.keyCode == html.KeyCode.LEFT || 
        e.keyCode == html.KeyCode.RIGHT || e.keyCode == html.KeyCode.CTRL) {
      pressed[e.keyCode] = false;
    }
  }

  // crear malotes
  Future<List<Sprite>> createEnemies(int quant, Esprites type) async {
    List<Sprite> enemies = [];
    for (int i = 0; i < quant; i++) {
      Sprite enemy = await loadSprite(type);
      enemy.direct = Point(Random().nextBool() ? 1: -1, Random().nextBool() ? 1: -1);
      enemy.pos = Point(Random().nextInt(SCREEN_WIDTH - (enemy.frameWidth * enemy.scale).toInt()), Random().nextInt((SCREEN_HEIGHT/2 - enemy.height * enemy.scale).toInt()));
      enemies.add(enemy);
    }
    return enemies;
  }

  void gameOver() {
    endGame = true;
    Sound.stop(Esounds.BG_MUSIC);
  }

}


// void moveSpr(List<Sprite> sp) {
//   int inc_step = 2;
//   Iterator<Sprite> i = sp.iterator;
//   while (i.moveNext()) {
//     final x = i.current.pos.x + i.current.direct.x * inc_step;
//     final y = i.current.pos.y + i.current.direct.y * inc_step;
//     i.current.pos = Point(x,y);
//     i.current.direct = Point(x < 0 || x > SCREEN_WIDTH - i.current.frame.width * i.current.scale ? i.current.direct.x * -1 : i.current.direct.x,
//                               y < 0 || y > SCREEN_HEIGHT - i.current.frame.height * i.current.scale ? i.current.direct.y * -1 : i.current.direct.y);
//     if (i.current.child != null) {
//       // movemos los child al igual que su padre
//       i.current.child.pos = i.current.pos;
//     }
//   }

// }