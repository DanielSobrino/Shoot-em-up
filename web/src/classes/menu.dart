import 'dart:async';
import 'dart:html' as html;
import '../classes/game.dart';
import '../classes/sound.dart';
import '../environment.dart';

html.Element menu = html.document.getElementById('menu');
html.CanvasElement gameCanvas = html.document.getElementById('canvas');

html.Element playButton = html.document.createElement('button');
html.Element storeButton = html.document.createElement('button');
html.Element configButton = html.document.createElement('button');

html.HtmlElement levelSelectTitle = html.document.createElement('div');

html.Element bgImg = html.document.createElement('img');
html.Element buttonHome = html.document.createElement('button');
html.Element buttonRetry = html.document.createElement('button');
html.Element buttonNextLevel = html.document.createElement('button');
html.Element finalScoreText = html.document.createElement('div');
html.Element contenedor = html.document.getElementById('contenedor');

class Menu {

  StreamSubscription gameSubs = Game.menuCtrl.stream.listen((data) => menuHandle(data));
  static Game game = Game();
  static int level = 1; //Hacer selector de niveles

  Menu() {
    game.init().then((e) {
      initMenu();
      startMenu();
    });
  }

  static void startMenu() {
    clearMenu();
    //Mostrar menu
    menu.style.display = 'block';
    Sound.loop(Esounds.MENU_MUSIC);
    gameCanvas.style.display = 'none';
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
    bgImg.remove();
    buttonHome.remove();
    buttonNextLevel.remove();
    buttonRetry.remove();
    finalScoreText.remove();
  }

  void showLevelSelector() {
    levelSelectTitle.innerHtml = '<p>Level select</p>';
    levelSelectTitle.className = 'title';
    contenedor.append(levelSelectTitle);
  }

  void initMenu() {
    
    //Home menu
    playButton.className = 'rect';
    playButton.id = 'button_play';
    playButton.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      // launchGame();
      playButton.remove();
      storeButton.remove();
      configButton.remove();      
      showLevelSelector();
    });
    storeButton.className = 'rect';
    storeButton.id = 'button_store';
    configButton.className = 'rect';
    configButton.id = 'button_settings';

    //EndLevel Background
    bgImg.style.width = '${108*3}px';
    bgImg.style.height = '${113*3}px';
    bgImg.style.marginLeft = '${(SCREEN_WIDTH - 108*3) / 2}px';
    bgImg.style.top = '${(SCREEN_HEIGHT - 113*3) / 2}px';
    bgImg.className = 'endgame_menu';
    //Home button
    buttonHome.style.background = 'url(src/assets/sprites/endgame_menu/home_button.png) no-repeat';
    buttonHome.className = 'endgame_button';
    buttonHome.style.width = '${23*3}px';
    buttonHome.style.height = '${23*3}px';
    buttonHome.style.marginLeft = '${(SCREEN_WIDTH - 186) / 2}px';
    buttonHome.style.top = '${(SCREEN_HEIGHT + 129) / 2}px';
    buttonHome.style.backgroundSize = 'cover';
    buttonHome.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      Menu.startMenu();
    });

    //NextLevel button
    buttonNextLevel.style.background = 'url(src/assets/sprites/endgame_menu/next_level_button_victory_menu.png) no-repeat';
    buttonNextLevel.className = 'endgame_button';
    buttonNextLevel.style.width = '${23*3}px';
    buttonNextLevel.style.height = '${23*3}px';
    buttonNextLevel.style.marginLeft = '${(SCREEN_WIDTH + 48) / 2}px';
    buttonNextLevel.style.top = '${(SCREEN_HEIGHT + 129) / 2}px';
    buttonNextLevel.style.backgroundSize = 'cover';
    buttonNextLevel.addEventListener('click', (e) {
      Sound.play(Esounds.BUTTON);
      level+=1;
      launchGame();
    });
    
    //Retry button
    buttonRetry.style.background = 'url(src/assets/sprites/endgame_menu/retry_button_defeat_menu.png) no-repeat';
    buttonRetry.className = 'endgame_button';
    buttonRetry.style.width = '${23*3}px';
    buttonRetry.style.height = '${23*3}px';
    buttonRetry.style.marginLeft = '${(SCREEN_WIDTH + 48) / 2}px';
    buttonRetry.style.top = '${(SCREEN_HEIGHT + 129) / 2}px';
    buttonRetry.style.backgroundSize = 'cover';
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
        contenedor.append(buttonNextLevel);
    }
    contenedor.append(bgImg);

  }
  
}


