import 'dart:async';
import 'dart:math';

import '../environment.dart';
import 'sprite.dart';

class Movement {
  Point pos; // posicion inicial
  Sprite sp;

  int max_y; 
  int max_x;
  int direct_y; // dirección de la coordenada Y
  double desp_x; // incremento en coordenada X
  double desp_y; // incremento en coordenada Y
  double counter = 0;
  // atributos para el desplazamiento ondular
  int sin_x_offset;
  double sin_ampl; // amplitud de onda
  double sin_res;  // a menor valor, mayor resolución
  final double SIN_ARC = 2 * pi;
  EmoveTypes type;

  StreamController<Point> strCtrl = StreamController();
  StreamSubscription strmSub;
  bool _gamePaused = false; // captura la pausa de game
  // nos suscribimos al stream de la clase game
  StreamSubscription<String> _gameStrmSub;

  // setters
  // referencia a objectos de la clase game
  set strmSubs(Stream strm) {this._gameStrmSub = strm.listen((strGame) => gameHandler(strGame));}

  Movement(int max_y, { EmoveTypes type, double desp_x, double desp_y, double sin_ampl, double sin_res, int max_x }) {
    // inicializar posición fuera de la pantalla
    this.desp_x = desp_x ?? 1.0;
    this.desp_y = desp_y ?? 1.0;
    this.max_x = max_x ?? 20;
    this.max_y = max_y;
    this.sin_ampl = sin_ampl ?? 80.0;
    this.sin_res = sin_res ?? 0.05;
    this.type = type ?? EmoveTypes.LINEAR;
    // la dirección de Y depende del signo del desplazamiento en Y
    this.direct_y = this.desp_y.sign.toInt();
  }

  // constructor de copia
  Movement.clone(Movement mvm): this(mvm.max_y, type: mvm.type, desp_x: mvm.desp_x, desp_y: mvm.desp_y, sin_ampl: mvm.sin_ampl, sin_res: mvm.sin_res, max_x: mvm.max_x);

  // se encarga de generar los valores para el streamController
  void strmControl() async {
    while(nextPos(this.type)) {
      await Future.delayed( Duration(milliseconds: 10));
    }
    // al terminar la secuencia, cerramos el stream 
    await strCtrl.sink.close();
    sp.hit(PLANE_DESTROY_DELAY); // programa destrucción del objeto
  }

  // para arrancar el proceso de generación y quedar a la escucha
  void startMove(Sprite sp) {
    this.sp = sp;
    this.pos = sp.pos;
    this.sin_x_offset = this.pos.x;
    strmControl(); // lanzamos el generador
    strmSub = strCtrl.stream.listen((val) {
      // print('nvalue: $nvalue');
      this.pos = val;
      sp.pos = this.pos;
    });
    // cuando se cierre el stream, cancelamos la suscripción
    strmSub.onDone(() {
      print('-- alcanzado onDone --');
      strmSub.cancel();
      _gameStrmSub.cancel();
    });
  }

  // calcula la siguiente posición del objeto
  bool nextPos( EmoveTypes movType ) {
    if (_gamePaused) return true;
    double new_x, new_y;
    // desplazamiento Y en base al offset
    new_y = this.pos.y + desp_y;
    switch( movType ) {
      case EmoveTypes.LINEAR:
          new_x = this.pos.x;
          break;
      case EmoveTypes.ZIGZAG:
          new_x = this.pos.x + desp_x;
          counter++;
          // if( nuevo_x < 0 || nuevo_x > max_x - this.tam.x )
          if( counter > max_x ) {
            desp_x = desp_x * -1; //invertimos el desplazamiento en X
            counter = 0;
          }
          break;
      case EmoveTypes.WAVE:
          counter = counter > SIN_ARC ? 0: counter + sin_res;
          new_x = this.sin_x_offset + sin(counter) * sin_ampl;
          break;
    }
    // print('nuevo_y: ${nuevo_y * direcc_y} - max_y:${max_y * direcc_y}');
    // comparación dependiendo de la dirección
    if( (new_y * direct_y) <= (this.max_y * direct_y) && !sp.onDestroy ) {
      strCtrl.sink.add(Point(new_x, new_y));
      return true;
    }
    return false;
  }

  void gameHandler(String gameEvent) {
    if (gameEvent == "pauseOn") {
      _gamePaused = true;
    }
    if (gameEvent == "pauseOff") {
      _gamePaused = false;
    }
  }
}
