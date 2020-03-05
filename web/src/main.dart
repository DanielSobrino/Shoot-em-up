import 'dart:html';
import 'classes/game.dart';

Element menu = document.getElementById("menu");
CanvasElement gameCanvas = document.getElementById("canvas");
ButtonElement playButton = document.getElementById("button_play");

void main() async {

  menu.style.display = "block";
  gameCanvas.style.display = "none";

  playButton.onClick.listen((c) {
    launchGame();
  });
  
}

void launchGame() {
  menu.style.display = "none";
  gameCanvas.style.display = "block";
  Game();
}