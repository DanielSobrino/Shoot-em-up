import 'dart:html' as html;
import '../environment.dart';

Map<Esounds, String> soundFiles = {
  Esounds.BG_MUSIC: './src/assets/audio/bg_music/bg_music.mp3',
  Esounds.MENU_MUSIC: './src/assets/audio/bg_music/bg_menu.mp3',
  Esounds.DEFEAT: './src/assets/audio/bg_music/bg_defeat.mp3',
  Esounds.VICTORY: './src/assets/audio/bg_music/bg_victory.mp3',
  Esounds.PLAYER_HURT: './src/assets/audio/effects/player_hurt.mp3',
  Esounds.BUTTON: './src/assets/audio/effects/button_press.mp3',
  Esounds.TAKE_OFF: './src/assets/audio/effects/take_off.mp3',
  Esounds.PLAYER_SHOT: './src/assets/audio/shooting/player_shot.mp3',
  Esounds.EXPLOSION1: './src/assets/audio/explosions/explosion.mp3',
  Esounds.EXPLOSION_MEDIUM: './src/assets/audio/explosions/explosion_medium.mp3'
};


class Sound {

  static Map<Esounds, html.AudioElement> sounds = <Esounds, html.AudioElement>{};
  static bool playing = false;

  // Sound(Esounds eSound) {
  //   sound = html.AudioElement(soundFiles[eSound]);
  // }

  Sound() {
    soundFiles.forEach((k,v) {
      sounds[k] = html.AudioElement(v);
    });
  }

  static void play(Esounds sound) {
    stop(sound);
    playing = true;
    sounds[sound].play();
    
  }

  static void stop(Esounds sound) {
    playing = false;
    sounds[sound].pause();
    sounds[sound].currentTime = 0;
    
  }

  static void loop(Esounds sound) {
    stop(sound);
    sounds[sound].loop = true; 
    playing = true;
    play(sound);
  }


}