import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import '../classes/game.dart';
import '../classes/sound.dart';
import '../environment.dart';
import '../assets/maps/levels/levels.dart' as levels;


html.Element menu = html.document.getElementById('menu');
html.CanvasElement gameCanvas = html.document.getElementById('canvas');

html.Element logoDiv = html.document.createElement('div');
html.Element logoMenu = html.document.createElement('img');

html.Element playButton = html.document.createElement('button');
html.Element storeButton = html.document.createElement('button');
html.Element configButton = html.document.createElement('button');

html.HtmlElement returnToMenuButton = html.document.createElement('button'); //también se usará en la tienda y ajustes

html.Element levelBoxDiv = html.document.createElement('div');
html.Element levelSelectTitle = html.document.createElement('div');


html.Element bgImg = html.document.createElement('img');
html.Element buttonHome = html.document.createElement('button');
html.Element buttonRetry = html.document.createElement('button');
html.Element buttonNextLevel = html.document.createElement('button');
html.Element finalScoreText = html.document.createElement('div');
html.Element contenedor = html.document.getElementById('contenedor');

html.Storage localStorage = html.window.localStorage;

class Menu {

  StreamSubscription gameSubs = Game.menuCtrl.stream.listen((data) => menuHandle(data));
  static Game game = Game();
  static int level = 1; //Hacer selector de niveles
  static int number_of_levels = levels.levelList.length;
  static List<dynamic> level_stars = [];

  Menu() {
    game.init().then((e) {
      initMenu();
      startMenu();
    });
  }

  static void startMenu() {
    if (localStorage['level_stars'] != null) {
      level_stars = json.decode(localStorage['level_stars']);
    } else {
      for (var i = 0; i < number_of_levels; i++) {
        level_stars.add(0);
      }
      localStorage['level_stars'] = json.encode(level_stars);
    }
    
    clearMenu();
    //Mostrar menu
    menu.style.display = 'block';
    if (!Sound.playing) {
      Sound.loop(Esounds.MENU_MUSIC);
    }
    gameCanvas.style.display = 'none';
    menu.append(logoDiv);
    logoDiv.append(logoMenu);
    menu.append(playButton);
    menu.append(storeButton);
    menu.append(configButton);
  }

  static void launchGame() {
    clearMenu();
    playButton.remove();
    storeButton.remove();
    configButton.remove();
    menu.style.display = 'none';
    Sound.stop(Esounds.MENU_MUSIC);
    gameCanvas.style.display = 'block';

    game.initLevel(level);
  }

  static void clearMenu() {
    levelBoxDiv.innerHtml = '';
    levelBoxDiv.remove();
    logoDiv.remove();
    bgImg.remove();
    buttonHome.remove();
    buttonNextLevel.remove();
    buttonRetry.remove();
    levelSelectTitle.remove();
    returnToMenuButton.remove();
    finalScoreText.remove();
  }

  void showLevelSelector() {  
    //creamos el menú
    menu.append(levelSelectTitle);
    menu.append(levelBoxDiv);
    // returnToMenu button
    returnToMenuButton.className = 'returnToMenuButton';
    returnToMenuButton.style.top = '${SCREEN_HEIGHT - 70}px';
    contenedor.append(returnToMenuButton);
    returnToMenuButton.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      Menu.startMenu();
    });

    levels.levelList.forEach((l) {
      html.Element levelBox = html.document.createElement('button');
      html.Element levelImg = html.document.createElement('img');
      html.Element levelTitle = html.document.createElement('p');
      int levelNumber = l['levelNum'];
      levelTitle.className = 'levelTitle';
      levelBox.className = 'levelBox';
      levelImg.className = 'levelImg';
      levelTitle.innerHtml = 'Level  ${levelNumber}';
      int currentLevelStars = level_stars[levelNumber-1];
      levelBox.style.backgroundImage = 'url(src/assets/sprites/level_selector/${currentLevelStars}_level_select_menu.png)';
      levelImg.style.background = 'url(src/assets/maps/level_preview_images/level${levelNumber}_preview.png) no-repeat';
      levelBox.addEventListener('click', (e) {
        level = levelNumber;
        launchGame();
      });
      levelBox.append(levelImg);
      levelBox.append(levelTitle);
      levelBoxDiv.append(levelBox);
    });
  }

  void initMenu() {    
    //Home menu
    logoMenu.className = 'logo';
    logoDiv.append(logoMenu);
    playButton.className = 'rect';
    playButton.id = 'button_play';
    playButton.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      logoDiv.remove();
      playButton.remove();
      storeButton.remove();
      configButton.remove();
      showLevelSelector();
    });
    storeButton.className = 'rect';
    storeButton.id = 'button_store';
    configButton.className = 'rect';
    configButton.id = 'button_settings';
    //LevelSelect menu
    levelSelectTitle.innerHtml = '<p>Level select</p>';
    levelSelectTitle.className = 'title';
    levelBoxDiv.className = 'levelBoxDiv';

    //EndLevel Background
    bgImg.className = 'bgImageEndMenu endgame_menu';
    bgImg.style.marginLeft = '${(SCREEN_WIDTH - 108*3) / 2}px';
    bgImg.style.top = '${(SCREEN_HEIGHT - 113*3) / 2}px';

    //Home button
    buttonHome.className = 'buttonHome endgame_button';
    buttonHome.style.marginLeft = '${(SCREEN_WIDTH - 186) / 2}px';
    buttonHome.style.top = '${(SCREEN_HEIGHT + 129) / 2}px';
    buttonHome.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      Menu.startMenu();
    });

    //NextLevel button
    buttonNextLevel.className = 'buttonNextLevel endgame_button';
    buttonNextLevel.style.marginLeft = '${(SCREEN_WIDTH + 48) / 2}px';
    buttonNextLevel.style.top = '${(SCREEN_HEIGHT + 129) / 2}px';
    buttonNextLevel.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      level+=1;
      launchGame();
    });
    
    //Retry button
    buttonRetry.className = 'buttonRetry endgame_button';
    buttonRetry.style.marginLeft = '${(SCREEN_WIDTH + 48) / 2}px';
    buttonRetry.style.top = '${(SCREEN_HEIGHT + 129) / 2}px';
    buttonRetry.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      launchGame();
    });

    //Final Score text
    finalScoreText.id = 'final_score';
    finalScoreText.className = 'endgame_menu';
    
  }

  static void menuHandle(Map<String, int> opt) {
    finalScoreText.innerHtml = '<p>FINAL SCORE: ${Game.score}</p>';
    contenedor.append(finalScoreText);
    contenedor.append(buttonHome);
    switch(opt.keys.first) {
      case 'defeat':
        Sound.play(Esounds.DEFEAT);
        bgImg.setAttribute('src', 'src/assets/sprites/endgame_menu/defeat_menu.png');
        contenedor.append(buttonRetry);
        break;
      case 'victory':
        Sound.play(Esounds.VICTORY);
        switch(opt.values.first) {
          case 1:
            bgImg.setAttribute('src', 'src/assets/sprites/endgame_menu/one_star_win_menu.png');
            break;
          case 2:
            bgImg.setAttribute('src', 'src/assets/sprites/endgame_menu/two_star_win_menu.png');
            break;
          case 3:
            bgImg.setAttribute('src', 'src/assets/sprites/endgame_menu/three_star_win_menu.png');
            break;
        }
        if (opt.values.first > level_stars[level-1]) {
          level_stars[level-1] = opt.values.first;
          localStorage['level_stars'] = json.encode(level_stars);
        }

        contenedor.append(buttonNextLevel);
    }
    contenedor.append(bgImg);

  }
  
}


