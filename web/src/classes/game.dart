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

html.CanvasElement _canvas;
html.CanvasRenderingContext2D _ctx;

// final LevelMap levelMap = LevelMap.fromJson(level1);


class Game {

  LevelMap levelMap;
  static List<Sprite> _spr = []; // sprites activos en el gameloop
  static List<Sprite> _waitingSpr = [];
  Plane player;
  List<Sprite> enemies = []; // para testear. añadir enemigos
  int inc_step = 5;

  int aFrame;
  int fps = 0, fpsTotal = 0;

  // enemigos pendientes durante el nivel
  // List<SpriteGenerator> _pendingEnemies = [];

  Map<int, bool> pressed = {
    html.KeyCode.DOWN: false, html.KeyCode.UP: false, html.KeyCode.LEFT: false, 
    html.KeyCode.RIGHT: false, html.KeyCode.SPACE: false
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
  static StreamController gameTick = StreamController<String>.broadcast();

  //---DEBUG---
  bool showHitboxes = false;
  bool pause = false;
  // posiciones mapa
  double mapStart = 0; //posición desde donde se va a dibujar
  double mapStep  = 0.6; //pixels verticales a desplazar

  Game() {
    init().then((resp) {
      gameLoop(0);
    });
  }

  Future init() async {
    _canvas = html.querySelector('#canvas');
    _ctx = _canvas.getContext('2d');
    _canvas..width = SCREEN_WIDTH ..height = SCREEN_HEIGHT;
    _ctx.imageSmoothingEnabled = false;
    // cargamos el mapa
    levelMap = await LevelMap.FromFile('/src/assets/maps/level1.json');
    // para generar la cache de imágenes
    for(Esprites esptype in Esprites.values) {
      Sprite sp = await loadSprite(esptype);
      sp.hit(0);
    }
    print('fin cache de imagenes');
    // propiedades para el mapa
    int maxMapPos = levelMap.map_cnv.height - SCREEN_HEIGHT;
    mapStart = maxMapPos.toDouble();
    print(mapStart);
    //Creación del avión
    player = await loadSprite(Esprites.PLAYER);
    player.pos = Point(SCREEN_WIDTH/2 - player.width/4, 670);
    _spr.add(player);
    await takeOff(player, _ctx, levelMap, mapStart.toInt());
    
    // player.setFlicker(ticks: 100, invulnerable: true); // parpadeo player
    SpriteGenerator(1950, Esprites.BIROTOR_PLANE, Point(player.pos.x, 0), quantity: 5, triggerOffset: -50);
    SpriteGenerator(1900, Esprites.BACKW_PLANE, Point(100, 0), quantity: 10, triggerOffset: -25);
 
    //Keyboard listenners
    html.window.addEventListener('keydown', (e) => keyDown(e));
    html.window.addEventListener('keyup', (e) => keyUp(e));

    //mostrar fps
    Timer.periodic(Duration(seconds: 1), (t) {fpsTotal = fps; fps = 0;});
  }

  void gameLoop(num f) {
    if(!endGame) {
      kybControl();
      updateState();
      draw();
      aFrame = html.window.requestAnimationFrame((f) => gameLoop(f));
    } else {
      gameTick.sink.close(); // paramos el streamController
      String txt = winGame ? 'U win! :D' : 'U lost. lol';
      showText(txt);
    }
  }

  void showText(String txt) {
    _ctx.font = 'bold 48px roboto';
    _ctx.setFillColorRgb(0xff, 0xff, 0xff);
    _ctx.fillRect(90, SCREEN_HEIGHT / 2 - 40, 220, 50);
    _ctx.setFillColorRgb(0x00, 0x00, 0x00);
    _ctx.fillText(txt, 100, SCREEN_HEIGHT/2);
  }


  static Future<Sprite> loadSprite(Esprites type, {int frames, double scale, int frameDuration}) async {
    Sprite newSpr;
    switch(type) {
      case Esprites.PLAYER:
      case Esprites.BACKW_PLANE:
      case Esprites.BASIC_PLANE:
      case Esprites.BIROTOR_PLANE:
      case Esprites.FIGHTER_JET:
        newSpr = Plane.fromType(type);
        break;
      case Esprites.HELICOPTER:
        newSpr = Sprite.fromType(type);
        break;
      case Esprites.EXPLOSION1:
        newSpr = Sprite.fromType(type);
        break;
      case Esprites.BULLET1:
        newSpr = Bullet.fromType(type);
        break;
      case Esprites.BULLET_ENEM1:
        newSpr = Bullet.fromType(type);
        break;
      default: 
        newSpr = Sprite.fromType(type);
    }
    newSpr.strmSubs = Game.gameTick.stream;
    await newSpr.complete();
    return newSpr;
  }

  void updateState() {
    //Eliminar sprites antes de iterarlos para evitar excepciones
    // spr.removeWhere((d) => d.destroy);
    _spr = _spr.where((d) => !d.destroy).toList();
    //Comprobar trigger de enemigos y crearlos
    checkEnemyTrigger();
    //Añadir los sprites pendientes
    _spr.addAll(_waitingSpr);
    _waitingSpr.clear();
    //Enviamos el evento de tick para ser procesado por los sprites
    gameTick.sink.add('newTick');
    //Comprobar colisiones
    collisions();
    //actualizar posición mapa
    mapStart = mapStart > mapStep ? mapStart - mapStep : 0;
    //rebote sprites
    moveSpr(enemies);
  }

  // Gestión de colisiones
  void collisions() {
    List<Sprite> bullets = _spr.where((s) => s.type == Esprites.BULLET1 || s.type == Esprites.BULLET_ENEM1).toList();
    List<Sprite> enemies = _spr.where((s) => s.type != Esprites.PLAYER).toList();
    enemies.removeWhere((s) => s.type == Esprites.BULLET1 || s.type == Esprites.BULLET_ENEM1);
    // if(enemies.isEmpty) {
    //   endGame = true;
    //   winGame = true && !player.onDestroy; // winGame si player no está en destrucción
    // }

    // comprobamos todas las colisiones de bullets
    for(Sprite enemy in enemies) {
      for(Sprite bullet in bullets) {
        if(!enemy.invulnerability && enemy.collision(bullet)) {
          int pw_left = enemy.power - bullet.power;
          // print('Ep: ${enemy.power}, Bp: ${bullet.power}');
          bullet.hit(0);
          _explode(bullet, Esprites.HIT_LIGHT);
          if(pw_left <= 0) {
            _explode(enemy, Esprites.EXPLOSION1, destroy: true, destroyInMillis: 300);
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
        _explode(enemy, Esprites.EXPLOSION1, destroy: true);
        _explode(player, Esprites.EXPLOSION1, destroy: true);
        Future.delayed(Duration(milliseconds: 800), gameOver);
      }
    }

  }

  // muestra una explosión exp_type y se asocia a currSpr
  void _explode(Sprite currSpr, Esprites expl_type, { bool destroy = false, int destroyInMillis }) {
    // indica si debe destruirse el sprite currSpr o no
    if( destroy ) {
      currSpr.hit( destroyInMillis ?? 200);
    }
    //   loadSprite(Esprites.EXPLOSION1).then((newSpr) {
    loadSprite(expl_type).then((newSpr) {
      Point currPos = currSpr.pos;
      double currScale = currSpr.scale;
      currSpr.child = newSpr; // Asignamos la explosión como hijo del sprite
      newSpr.complete().then((e) {
        newSpr.pos = currPos;
        newSpr.scale = currScale;
        // Añadimos la explosión a los sprites pendientes
        _waitingSpr.add(newSpr);
        newSpr.hit(newSpr.frameDuration * newSpr.framesNum * 2); // Se programa la destrucción de la explosión
      });
    });
  }

  //Genera nuevos enemigos en base a SpriteGenerator
  void checkEnemyTrigger() async {
    if (SpriteGenerator.sprQueue.isEmpty) return;
    SpriteGenerator currentGen = SpriteGenerator.sprQueue[0];
    if (currentGen.trigger >= mapStart) {
      Sprite enemy = await loadSprite(currentGen.spriteType);
      enemy.pos = currentGen.pos;
      enemy.direct = Point(0.5, 1); //
      enemies.add(enemy);
      _waitingSpr.add(enemy);
      SpriteGenerator.removeFromQueue(currentGen);
    }
  }

  void draw() {
    //mapa de fondo
    _ctx.putImageData(levelMap.map_ctx.getImageData(0, mapStart.toInt(), SCREEN_WIDTH, SCREEN_HEIGHT), 0, 0);

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
    
    //fps
    fps++;
    _ctx.font = 'bold 18px serif';
    _ctx.setFillColorRgb(0x00, 0x00, 0x00);
    _ctx.fillText('fps: $fpsTotal', 360, 25);
    _ctx.fillText('sprites: ${_spr.length}  ', 260, 25);
    
  }

  //---KEYBOARD---
  void keyDown(html.KeyboardEvent e) {
    // e.preventDefault();
    if(e.keyCode == html.KeyCode.P) {
      if(pause) {
        print('resume');
        aFrame = html.window.requestAnimationFrame((f) => gameLoop(f));
      } else {
        print('pausa');
        html.window.cancelAnimationFrame(aFrame);
      }
      pause = !pause;
      return;
    }
    if (e.keyCode == html.KeyCode.DOWN || e.keyCode == html.KeyCode.UP || e.keyCode == html.KeyCode.LEFT || 
        e.keyCode == html.KeyCode.RIGHT || e.keyCode == html.KeyCode.SPACE) {
      pressed[e.keyCode] = true;
    }
  }

  void kybControl() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if(pressed[html.KeyCode.DOWN] && player.pos.y < SCREEN_HEIGHT - player.frame.height * player.scale) {
      player.pos = Point(player.pos.x, player.pos.y + inc_step + player.frame.height * player.scale > SCREEN_HEIGHT ? SCREEN_HEIGHT - player.frame.height * player.scale : player.pos.y + inc_step);} 
    if(pressed[html.KeyCode.UP] && player.pos.y > 0) {
      player.pos = Point(player.pos.x, player.pos.y - inc_step < 0 ? 0 : player.pos.y - inc_step);} 
    if(pressed[html.KeyCode.RIGHT] && player.pos.x < SCREEN_WIDTH - player.frame.width * player.scale) {
      player.pos = Point(player.pos.x + inc_step + player.frame.width * player.scale > SCREEN_WIDTH ? SCREEN_WIDTH - player.frame.width * player.scale : player.pos.x + inc_step , player.pos.y);}
    if(pressed[html.KeyCode.LEFT] && player.pos.x > 0) { 
      player.pos = Point(player.pos.x - inc_step < 0 ? 0 : player.pos.x - inc_step, player.pos.y);} 
  
    if(pressed[html.KeyCode.SPACE] &&  currentTime - _lastShotTime > _shotDelay && !player.isFlicking ) {
      player.planeShoot();
      _lastShotTime = currentTime;
    }
  }

  void keyUp(html.KeyboardEvent e) {
    pressed[e.keyCode] = false;
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
  }

}


void moveSpr(List<Sprite> sp) {
  int inc_step = 2;
  Iterator<Sprite> i = sp.iterator;
  while (i.moveNext()) {
    final x = i.current.pos.x + i.current.direct.x * inc_step;
    final y = i.current.pos.y + i.current.direct.y * inc_step;
    i.current.pos = Point(x,y);
    i.current.direct = Point(x < 0 || x > SCREEN_WIDTH - i.current.frame.width * i.current.scale ? i.current.direct.x * -1 : i.current.direct.x,
                              y < 0 || y > SCREEN_HEIGHT - i.current.frame.height * i.current.scale ? i.current.direct.y * -1 : i.current.direct.y);
    if (i.current.child != null) {
      // movemos los child al igual que su padre
      i.current.child.pos = i.current.pos;
    }
  }

}