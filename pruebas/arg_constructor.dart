class Persona {
  String _nombre;
  String _dir;
  int _edad;
  String _talla;

  Persona (this._nombre, { String dir, int edad, String talla}): 
          _dir = dir ?? 'sin direccion', _edad = edad ?? 20, _talla = talla;


  @override
  String toString() {
    return '$_nombre dir:$_dir edad:$_edad talla:$_talla';
  }

}

Persona nuevaP(String nombre, {String dir, int edad, String talla}) {

    Persona p2 = Persona(nombre, dir: dir, edad: edad, talla: talla  );
    return p2;

}

main() {
  List<Persona> pers1, pers2, pers3, persNull;

  Persona p1 = Persona('bartolin', edad: 33, talla:"110");
  print('p1: ${p1}');

  Persona p2 = nuevaP('cuidadin', dir: 'calle grumete 12', edad: 54 );
  print('p2: $p2');
  // IMPORTANTE: comprueba si p2._talla es null antes de lanzar el método
  String tallap2 = p2._talla?.length ?? 'no definido';
  print('tallap2: $tallap2');

  pers1 = [p1, p2];
  print('pers1: $pers1');

  pers2 =[Persona('romualdo', dir: 'sucasa'), Persona('tiburcio', edad: 26, talla:"90")];
  print('pers2: $pers2');

  // operador spread
  pers3 = [ ...pers1 , ...pers2, ...?persNull ]; // persNull no está definido - puntero nulo

  print('pers3: $pers3');
  print('pers3.length: ${pers3.length}');

}

