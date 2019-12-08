import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import '../environment.dart';

class Layer {
  int _id;
  String _type;
  double _opacity;
  String _data;
  String _imageFile;
  String _name;
  int _offsetx, _offsety;
  bool _visible;
  int _x, _y;
  int _width, _height;
  List<TileSpec> _tiles = [];

  // html.CanvasElement _imgCanvas;
  // html.CanvasRenderingContext2D _imgCtx;
  html.ImageElement _image;

  // getters and setters
  List<TileSpec> get tiles => _tiles;
  int get id => _id;
  String get type => _type;
  String get imageFile => _imageFile;
  String get name => _name;
  int get offsetx => _offsetx;
  int get offsety => _offsety;
  int get width => _width;
  int get height => _height;
  double get opacity => _opacity;
  bool get visible => _visible;
  int get x => _x;
  int get y => _y;
  html.ImageElement get image => _image;

  factory Layer(Map<String, dynamic> lp) {
    return lp["type"] == "tilelayer" ? Layer.tileFromJson(lp) : Layer.imageFromJson(lp);
  }

  Layer.tileFromJson(Map<String, dynamic> lt) {
    _id = lt["id"];
    _data = lt["data"];
    _type = lt["type"];
    _name = lt["name"];
    _opacity = lt["opacity"];
    _width = lt["width"];
    _height = lt["height"];
    _x = lt["x"];
    _y = lt["y"];
    base64toList();
  }

  Layer.imageFromJson(Map<String, dynamic> li) {
    _id = li["id"];
    _type = li["type"];
    _imageFile = li["image"];
    _offsetx = li["offsetx"];
    _offsety = li["offsety"];  
    _image = html.ImageElement(src: MAPS_DIR + _imageFile);
  }

  // crea la lista de tiles a partir de data
  void base64toList() {
    // Este es el orden correcto de rotación
    final FLIP_DIAGONAL   = 0X20000000; // primero
    final FLIP_HORIZONTAL = 0X80000000; 
    final FLIP_VERTICAL   = 0X40000000; // ultimo

    Uint8List bytes = base64Decode(_data);
    bool flip_d, flip_h, flip_v;

    for(int i=0, b=0; i < bytes.length; i+=4, b++) { // 4 bytes
      int valor = bytes[i+3] << 24 |  bytes[i+2] << 16 | bytes[i+1] << 8 | bytes[i];
      flip_d = valor & FLIP_DIAGONAL   > 0;
      flip_h = valor & FLIP_HORIZONTAL > 0;
      flip_v = valor & FLIP_VERTICAL   > 0;
      // eliminamos los tres bits superiores para capturar el tile_id
      valor &= ~(FLIP_DIAGONAL | FLIP_HORIZONTAL | FLIP_VERTICAL);
      _tiles.add(TileSpec(valor, fd:flip_d, fh:flip_h, fv:flip_v));
    }
  }

  // Future loadImage() async {
  //   await _image.onLoad.first.then((e) {
  //     _imgCanvas = html.CanvasElement()..width = _image.width ..height = _image.height;
  //     _imgCtx = _imgCanvas.getContext('2d');
  //     _imgCtx.drawImage(_image, 0, 0);
  //   });
  // }


}

class TileSpec {
  int _tileId;
  bool _flip_d, _flip_h, _flip_v;

  int  get tileId => _tileId; //- 1; // ?? coincidir con el id de la clase Tile
  bool get flip_d => _flip_d;
  bool get flip_h => _flip_h;
  bool get flip_v => _flip_v;

  // set flip_d(bool d) => flip_d = d;
  // set flip_h(bool h) => flip_h = h;
  // set flip_v(bool v) => flip_v = v;

  TileSpec(this._tileId, {bool fd = false, bool fh = false, bool fv = false}): _flip_d = fd, _flip_h = fh, _flip_v = fv;
}