import 'dart:convert';
import 'dart:html' as html;

import '../assets/maps/tiles.json.dart';
import 'tile.dart';
import 'layer.dart';

class LevelMap {
  int _width; 
  int _height;
  int _tileWidth;
  int _tileHeight;

  TileMap _tiles = TileMap(tiles);
  // List<Map<String,dynamic>> _layerList = [];
  List<dynamic> _layerList = [];
  Map<int,Layer> _layerMap = {};
  html.CanvasElement _map_cnv;
  html.CanvasRenderingContext2D _map_ctx;

  // getters and setters
  Map<int,Layer> get layerMap => _layerMap;
  int get width => _width;
  int get height => _height;
  int get tileWidth => _tileWidth;
  int get tileHeight => _tileHeight;
  List<Map<String,dynamic>> get layerList => _layerList;
  TileMap get getTiles => _tiles;
  html.CanvasElement get map_cnv => _map_cnv;
  html.CanvasRenderingContext2D get map_ctx => _map_ctx;

  // constructor desde objeto json
  LevelMap.fromJson(Map<String, dynamic> json) {
    _width = json["width"];
    _height = json["height"];
    _tileWidth = json["tilewidth"];
    _tileHeight = json["tileheight"];
    _layerList = json["layers"];
    _layerMap.addEntries( _layerList.map((ly) => MapEntry(ly["id"], Layer(ly)) ) );
  }

  static Future<LevelMap> FromFile(String fileName) async {
    String fileContent = await html.HttpRequest.getString(fileName);
    Map<String, dynamic> jsonMap = jsonDecode(fileContent);
    final LevelMap newMap = LevelMap.fromJson(jsonMap);
    await newMap.prepareMap();
    return newMap;
  }

  Future _loadTiles() async {
    List<Future> ltiles = _tiles.tileMap.values.map((v) => v.loadTile()).toList();
    return await Future.wait(ltiles); // esperamos a que termine la carga de tiles
  }

  Future prepareMap() async {
    await _loadTiles();
    final map_width = _width * _tileWidth;
    final map_height = _height * _tileHeight;
    _map_cnv = html.CanvasElement()..width = map_width ..height = map_height;
    _map_ctx = map_cnv.getContext('2d');
    List<int> layer_ids = _layerMap.values.where((v) => v.type == "tilelayer").map((v) => v.id).toList();
    List<int> image_ids = _layerMap.values.where((v) => v.type == "imagelayer").map((v) => v.id).toList();
    layer_ids.forEach((id) => _loadLayer(id));
    image_ids.forEach((id) {
      _map_ctx.drawImage(_layerMap[id].image, _layerMap[id].offsetx, _layerMap[id].offsety);
    });

    // //cuadros de control
    // _map_ctx.setStrokeColorRgb(0, 0, 0);
    // _map_ctx.lineWidth = 1;
    // _map_ctx.strokeRect(0, 0, _map_cnv.width, 30);
    // _map_ctx.strokeRect(0, _map_cnv.height - 30, _map_cnv.width, 30);
  }

  void _loadLayer(int id) {
    int tile_offset = 0;
    for (int tile_y = 0; tile_y < _height; tile_y++) {
      for (int tile_x = 0; tile_x < _width; tile_x++) {
        TileSpec tile = _layerMap[id].tiles[tile_offset++];
        int x = tile_x * _tileWidth;
        int y = tile_y * _tileHeight;
        if(tile.tileId > 0) {
          _map_ctx.drawImage(_tiles.tileMap[tile.tileId - 1] //hay que restar uno
                 .getImage(flip_d: tile.flip_d, flip_h: tile.flip_h, flip_v: tile.flip_v), x, y);

        }
      }
    }
  
  }

}

