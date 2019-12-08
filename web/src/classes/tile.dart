import 'dart:html' as html;
import 'dart:typed_data';
import '../environment.dart';
import 'jsonTiles.dart';

enum EFlips { HORIZONTAL, VERTICAL, DIAGONAL  }

class TileMap {
  Map<int,Tile> _tileMap = {};
  JsonTiles properties;

  TileMap(Map<String,dynamic> tmap) {
    properties = JsonTiles.fromJson(tmap);
    properties.tiles.forEach((tp) {
      _tileMap[tp.id] = Tile(tp);
    });
  }

  Map<int,Tile> get tileMap => _tileMap;
}

class Tile {
  int _id;
  String _imageFile;
  html.CanvasElement _imgCanvas;
  html.CanvasRenderingContext2D _ctx;
  int _side;

  // canvas para transformaciones
  html.CanvasElement _imgCanvasTmp;
  html.CanvasRenderingContext2D _imgCtxTmp;

  Tile(TileProp t) {
    this._id = t.id;
    this._imageFile = t.image;
    this._side = t.imagewidth;
    this._imgCanvas = html.CanvasElement()..width = _side ..height = _side;
    this._imgCanvasTmp = html.CanvasElement()..width = _side ..height = _side;
    this._imgCtxTmp = _imgCanvasTmp.getContext('2d');
  }

  String get imageFile => _imageFile;
  int get id => _id;
  html.CanvasElement get imgCanvas => _imgCanvas;

  Future loadTile() async {
    html.ImageElement img = html.ImageElement(src: MAPS_DIR + _imageFile);
    _ctx = _imgCanvas.getContext('2d');
    return await img.onLoad.first.then((e) {
      _ctx.drawImage(img, 0, 0);
    });
  }

  html.CanvasElement getImage({bool flip_v = false, bool flip_h = false, bool flip_d = false}) {
    // comprobamos is es necesario girar
    if(!(flip_d||flip_h||flip_v)) {
      return _imgCanvas;
    }
    // copiamos la imagen original
    _imgCtxTmp.putImageData(_ctx.getImageData(0, 0, _side, _side), 0, 0);
    // Uint8ClampedList data = _imgCtxTmp.getImageData(0, 0, _side, 1).data; //_imgDataTmp.data; 

    // transformaciones sobre _imageData;
    if(flip_v) _arrayFlip(EFlips.VERTICAL);
    if(flip_h) _arrayFlip(EFlips.HORIZONTAL);
    if(flip_d) _arrayFlip(EFlips.DIAGONAL);
    return _imgCanvasTmp;
  }

  void _arrayFlip( EFlips flip ) {
    Uint8ClampedList orig = _imgCtxTmp.getImageData(0, 0, _side, _side).data;

    html.ImageData idataDest = _imgCtxTmp.createImageData(_side, _side);
    Uint8ClampedList dest = idataDest.data;
    int offsetOrig, offsetDest;
    // desplazamos todos los pixels dependiendo del flip
    for(int y = 0; y < _side; y++){
      for (int x = 0; x < _side; x++) {
        offsetOrig = (y * _side + x) * 4;

        switch(flip) {
          case EFlips.DIAGONAL:
            offsetDest = ((_side - x - 1) * _side + _side - y - 1) * 4; break;
          case EFlips.HORIZONTAL:
            offsetDest = ((_side * y) + _side - x - 1) * 4; break;
          case EFlips.VERTICAL: 
            offsetDest = (( _side - y -1 ) * _side + x ) * 4; break;
          // default: offsetDest = offsetOrig;
        }
        dest[ offsetDest ] = orig[ offsetOrig ];
        dest[offsetDest+1] = orig[offsetOrig+1];
        dest[offsetDest+2] = orig[offsetOrig+2];
        dest[offsetDest+3] = orig[offsetOrig+3];
      }
    }
    _imgCtxTmp.putImageData(idataDest, 0, 0);
  }

}