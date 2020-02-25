import 'dart:async';
import 'dart:html' as html;
import 'dart:math';
import '../environment.dart';
import '../assets/sprites/spriteTypes.dart';

// Clase que contiene la estructura de los sprites.
class Sprite {
  // Propiedades del sprite.
  String _fileName;
  int _width;
  int _height;
  double _scale;
  Esprites _type;
  int _power;

  int _frameIndex = 0;
  int _framesNum; // for spritesheets
  int _frameWidth;
  int _frameDuration;
  int _ticksCounter = 0;
  final int TICKS_ANIMATE = 5;
  static Map<String, List<html.CanvasElement>> _frames = {};
  static Map<String, html.ImageElement> _image = {};
  Point _pos = Point(0,0);
  Point _direct = Point(0,0);
  List<Hitbox> _hitBoxes = [];
  Sprite _child; // sprite hijo asociado
  // estados del sprite
  bool _destroy = false;
  bool _onDestroy = false; // está destruyéndose
  bool _showSprite = true;  // indica si debe mostrarse el sprite
  bool _invulnerability = false; // el sprite no recibe impactos
  bool _isFlicking = false; // está parpadeando
  // parpadeo
  final int TICKS_FLICKER_CHANGE = 4;
  int  _ticks_flicker;
  bool _flicker = false;    // sprite en modo parpadeo
  int  _flickerCounter; // contador de ticks hasta TICKS_FLICKER

  // nos suscribimos al stream de la clase game
  StreamSubscription<String> _strmSubs;

  // Constructores
  //
  // Parametros obligatorios: [_fileName], [_type].
  // Parametros opcionales: [frames], [scale], [frameDuration]. Por defecto `1`, `2.0`, `50`, respectivamente.
  Sprite(this._fileName,  this._type, {int frames, double scale, int frameDuration}):
        _framesNum = frames ?? 1, _scale = scale ?? 2.0, _frameDuration = frameDuration ?? 50;

  // constructor por tipo
  Sprite.fromType(Esprites type) {
    Map<String, dynamic> spr_type = spriteTypes[type];
    _fileName = spr_type['fileName'];
    _type = type;
    _power = spr_type['power'] ?? 2;
    _framesNum = spr_type['frames'] ?? 1;
    _scale =  spr_type['scale'] ?? 2.0;
    _frameDuration = spr_type['frameDuration'] ?? 50;
    spr_type['hitboxes'].forEach((hbox) => setHitbox(Point(hbox[0],hbox[1]), Point(hbox[2], hbox[3])));
  }


  // Getters
  html.CanvasElement get frame => Sprite._frames[_fileName][_frameIndex];
  int get width => this._width;
  int get height => this._height;
  double get scale => this._scale;
  int get imgCount => this._framesNum;
  Point get pos => this._pos;
  Point get direct => this._direct;
  String get fileName => this._fileName;
  int get frameWidth => this._frameWidth;
  List<Hitbox> get hitBoxes => this._hitBoxes;
  bool get destroy => _destroy;
  int get frameDuration => _frameDuration;
  Esprites get type => _type;
  bool get onDestroy => _onDestroy;
  Sprite get child => _child;
  int get framesNum => _framesNum;
  int get ticksCounter => _ticksCounter;
  int get power => _power;
  bool get showSprite => _showSprite;
  bool get invulnerability => _invulnerability;
  bool get isFlicking => _isFlicking;

  // Setters
  set pos(Point p) => this._pos = p;
  set direct(Point d) => this._direct = d;
  set scale(double s) => this._scale = s;
  set frameDuration(int d) => this._frameDuration = d;
  set child(Sprite c) => this._child = c;
  set power(int pw) => this._power = pw;
  set invulnerability(bool inv) => this._invulnerability = inv;
  // referencia a objectos de la clase game
  set strmSubs(Stream strm) {this._strmSubs = strm.listen((strGame) => gameHandler(strGame));}

  // Devuelve la promesa de la carga de [_image].
  Future complete() async {
    // Solo se cargará la imágen en la primera instancia que indice su [_fileName].
    if(!Sprite._image.containsKey(_fileName)) {
      _image[_fileName] = html.ImageElement(src: SPRITE_DIR + _fileName);
    }
    if(_image[_fileName].complete) {
      // si ya existe la imagen, cargamos las propiedades del objeto estático
      this._width = _image[_fileName].width;
      this._height = _image[_fileName].height;
      this._frameWidth = _width ~/ _framesNum;
    } else {
      await _image[_fileName].onLoad.first
        .then((e) {
          this._width = _image[_fileName].width;
          this._height = _image[_fileName].height;
          //Recorte de spritesheet a frames
          final html.CanvasElement canvas = html.CanvasElement()..width = _width ..height = _height;
          final html.CanvasRenderingContext2D ctx = canvas.getContext('2d');

          _frameWidth = _width ~/ _framesNum;

          ctx.drawImage(_image[_fileName], 0, 0);
          Sprite._frames[_fileName] = [];
          for (var i = 0; i < _framesNum; i++) {
            Sprite._frames[_fileName].add(html.CanvasElement()..width = _frameWidth ..height = _height);
            html.CanvasRenderingContext2D frame_ctx = Sprite._frames[_fileName][i].getContext('2d');
            frame_ctx.putImageData(ctx.getImageData(_frameWidth * i, 0, _frameWidth, _height), 0, 0);
          }
        });
        print('nuevo sprite: $_fileName');
    }
  }

  // Cambia el frame de forma cíclica.
  void animate() {
    _frameIndex = _frameIndex < _framesNum - 1 ? ++_frameIndex : 0;
  }

  void gameHandler(String gameEvent) {
    // print('gameHandler: $gameEvent');
    if(gameEvent == 'newTick') {
      _ticksCounter++;
      // cambio de frame
      if(_ticksCounter >= TICKS_ANIMATE) {
        _ticksCounter = 0;
        animate();
      }
      // control de parpadeo
      if( _flicker ) {
        if( _flickerCounter++ <= _ticks_flicker ) {
          // conmutamos según el contador de cambio
          _showSprite = _flickerCounter % TICKS_FLICKER_CHANGE == 0 ? !_showSprite: showSprite; 
        } else {
          stopFlicker();
        }
      }
    }
  }

  // activar parpadeo
  void setFlicker({int ticks, bool invulnerable}) {
    this._ticks_flicker = ticks ?? 20;
    this._flicker = true;
    this._invulnerability = invulnerable ?? false;
    _flickerCounter = 0;
    this._isFlicking = true;
  } 
  // terminar parpadeo
  void stopFlicker() {
    _showSprite = true;
    _flicker = false;
    _invulnerability = false;
    this._isFlicking = false;
  }

  // Crea una nueva hitbox desde [start] a [end].
  void setHitbox(Point start, Point end) {
    _hitBoxes.add(Hitbox(Point(start.x * scale, start.y * scale), Point(end.x * scale, end.y * scale)));
  }

  // Devuelve `true` cuando se detecta colisión con la hitbox del [sp] recibido.
  bool collision(Sprite sp) {
    bool col = false;
    outerLoop:
    for(Hitbox hb in this._hitBoxes) {
      for(Hitbox sphb in sp.hitBoxes) {
        if (this._pos.x + hb.start.x <= sp._pos.x + sphb.start.x + sphb.end.x - sphb.start.x &&
            this._pos.x + hb.start.x + hb.end.x - hb.start.x > sp._pos.x + sphb.start.x &&
            this._pos.y + hb.start.y <= sp._pos.y + sphb.start.y + sphb.end.y - sphb.start.y &&
            this._pos.y + hb.start.y + hb.end.y - hb.start.y > sp._pos.y + sphb.start.y) {
          col = true;
          break outerLoop;
        }
      }
    }
    return col;
  }

  void hit(int millis) {
    print('hit: $type');
    _onDestroy = true; // activamos la destrucción
    _invulnerability = true; // invulnerable mientras está en proceso de destrucción
    // si el delay es 0, destrucción inmediata
    if(millis == 0) {
      doDestroy();
    } else {
      Future.delayed(Duration(milliseconds: millis), () => doDestroy());
    }
  }

  void doDestroy() {
    _strmSubs.cancel(); //IMPORTANTE: cancelar la suscripción para que no genere eventos.
    this._destroy = true;
  }

  @override
  String toString() {
    return 'w: $_width h: $_height name: $_fileName';
  }

}

// Definición de una hitbox.
class Hitbox {

  Point _start;
  Point _end;

  Hitbox(this._start, this._end);

  Point get start => this._start;
  Point get end => this._end;

}