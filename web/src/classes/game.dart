import 'dart:html' as html;
import 'dart:async';
import 'dart:math';

import '../../src/environment.dart';
import 'bullet.dart';
import 'levelMap.dart';
import 'plane.dart';
import 'sprite.dart';

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
    //Creación del avión
    player = await loadSprite(Esprites.PLAYER);
    player.pos = Point(SCREEN_WIDTH/2 - player.width/4, 850);
    _spr.add(player);
    // para generar la cache de imágenes
    Sprite bullet = await loadSprite(Esprites.BULLET1); bullet.hit(0);
    Sprite explos = await loadSprite(Esprites.EXPLOSION1); explos.hit(0);
    enemies.addAll(await createEnemies(10, Esprites.HELICOPTER)); //
    enemies.addAll(await createEnemies(10, Esprites.BACKW_PLANE)); //
    enemies.addAll(await createEnemies(6, Esprites.BIROTOR_PLANE)); //
    // enemies.addAll(await createEnemies(5, Esprites.BASIC_PLANE)); //
    _spr.addAll(enemies);
 
    //Keyboard listenners
    html.window.addEventListener('keydown', (e) => keyDown(e));
    html.window.addEventListener('keyup', (e) => keyUp(e));
    // propiedades para el mapa
    int maxMapPos = levelMap.map_cnv.height - SCREEN_HEIGHT;
    mapStart = maxMapPos.toDouble();

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
    //Añadir los sprites pendientes
    _spr.addAll(_waitingSpr);
    _waitingSpr.clear();
    // enviamos el evento de tick para ser procesado por los sprites
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
    List<Sprite> bullets = _spr.where((s) => s.type == Esprites.BULLET1).toList();
    List<Sprite> enemies = _spr.where((s) => s.type != Esprites.PLAYER).toList();
    enemies.removeWhere((s) => s.type == Esprites.BULLET1);
    if(enemies.isEmpty) {
      endGame = true;
      winGame = true;
    }

    // comprobamos todas las colisiones de bullets
    for(Sprite enemy in enemies) {
      for(Sprite bullet in bullets) {
        if(!enemy.onDestroy && enemy.collision(bullet)) {
          _explode(enemy);
          bullet.hit(0);
        }
      }
      // destrucción del player
      if(!enemy.onDestroy && enemy.collision(player)) {
        _explode(enemy);
        _explode(player);
        Future.delayed(Duration(milliseconds: 800), gameOver);
      }
    }

  }

  void _explode(Sprite currSpr) {
    currSpr.hit(200);
    // Creamos sprite de explosión
    loadSprite(Esprites.EXPLOSION1).then((newSpr) {
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

  void draw() {
    //mapa de fondo
    _ctx.putImageData(levelMap.map_ctx.getImageData(0, mapStart.toInt(), SCREEN_WIDTH, SCREEN_HEIGHT), 0, 0);

    //dibujamos los sprites
    Iterator<Sprite> i = _spr.iterator;
    while(i.moveNext()) {
      _ctx.drawImageScaled(i.current.frame, i.current.pos.x, i.current.pos.y, i.current.frame.width * i.current.scale, i.current.frame.height * i.current.scale);
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
  
    if(pressed[html.KeyCode.SPACE] &&  currentTime - _lastShotTime > _shotDelay ) {
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
                             y < 0 || y > -80 +SCREEN_HEIGHT - i.current.frame.height * i.current.scale ? i.current.direct.y * -1 : i.current.direct.y);
    if (i.current.child != null) {
      // movemos los child al igual que su padre
      i.current.child.pos = i.current.pos;
    }
  }

}