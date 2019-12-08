import 'dart:convert';

JsonTiles jsonTilesFromJson(String str) => JsonTiles.fromJson(json.decode(str));

String jsonTilesToJson(JsonTiles data) => json.encode(data.toJson());

class JsonTiles {
    int columns;
    Grid grid;
    int margin;
    String name;
    int spacing;
    List<Terrain> terrains;
    int tilecount;
    String tiledversion;
    int tileheight;
    List<TileProp> tiles;
    int tilewidth;
    String type;
    double version;

    JsonTiles({
        this.columns,
        this.grid,
        this.margin,
        this.name,
        this.spacing,
        this.terrains,
        this.tilecount,
        this.tiledversion,
        this.tileheight,
        this.tiles,
        this.tilewidth,
        this.type,
        this.version,
    });

    factory JsonTiles.fromJson(Map<String, dynamic> json) => JsonTiles(
        columns: json["columns"],
        grid: Grid.fromJson(json["grid"]),
        margin: json["margin"],
        name: json["name"],
        spacing: json["spacing"],
        terrains: List<Terrain>.from(json["terrains"].map((x) => Terrain.fromJson(x))),
        tilecount: json["tilecount"],
        tiledversion: json["tiledversion"],
        tileheight: json["tileheight"],
        tiles: List<TileProp>.from(json["tiles"].map((x) => TileProp.fromJson(x))),
        tilewidth: json["tilewidth"],
        type: json["type"],
        version: json["version"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "columns": columns,
        "grid": grid.toJson(),
        "margin": margin,
        "name": name,
        "spacing": spacing,
        "terrains": List<dynamic>.from(terrains.map((x) => x.toJson())),
        "tilecount": tilecount,
        "tiledversion": tiledversion,
        "tileheight": tileheight,
        "tiles": List<dynamic>.from(tiles.map((x) => x.toJson())),
        "tilewidth": tilewidth,
        "type": type,
        "version": version,
    };
}

class Grid {
    int height;
    String orientation;
    int width;

    Grid({
        this.height,
        this.orientation,
        this.width,
    });

    factory Grid.fromJson(Map<String, dynamic> json) => Grid(
        height: json["height"],
        orientation: json["orientation"],
        width: json["width"],
    );

    Map<String, dynamic> toJson() => {
        "height": height,
        "orientation": orientation,
        "width": width,
    };
}

class Terrain {
    String name;
    int tile;

    Terrain({
        this.name,
        this.tile,
    });

    factory Terrain.fromJson(Map<String, dynamic> json) => Terrain(
        name: json["name"],
        tile: json["tile"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "tile": tile,
    };
}

class TileProp {
    int id;
    String image;
    int imageheight;
    int imagewidth;

    TileProp({
        this.id,
        this.image,
        this.imageheight,
        this.imagewidth,
    });

    factory TileProp.fromJson(Map<String, dynamic> json) => TileProp(
        id: json["id"],
        image: json["image"],
        imageheight: json["imageheight"],
        imagewidth: json["imagewidth"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "imageheight": imageheight,
        "imagewidth": imagewidth,
    };
}
