import requisitos.*

class Estudiante {

  const carrerasCursando = #{}
  const materiasCursadas = []
  const inscripciones = #{}
  
  method inscribirCarrera(carrera){
    self.validarInscripcionACarrera(carrera)
    carrerasCursando.add(carrera)
  }

  method validarInscripcionACarrera(carrera){
    if (carrerasCursando.contains(carrera)) {
      self.error("Ya esta inscripto en la carrera " + carrera.nombre())
        }
    }

  method carrerasCursando() {
    return carrerasCursando
  }

  method estaInscriptoA(materia){
    return inscripciones.contains(materia)
  }

  method materiasCursadas() {
    return materiasCursadas
  }

  method cursarMateria(materia, nota){
    self.validarNoAprobada(materia)
    self.validarNota(nota)
    materiasCursadas.add(new MateriaCursada(materia = materia, nota = nota))
  }

  method validarNoAprobada(materia){
    if (self.aproboLaMateria(materia)) {
      self.error("Ya se aprobo la materia " + materia.nombre())
    }
  }

  method validarNota(nota){
    if (nota < 0 || nota > 10) {
      self.error("La nota debe estar entre 0 y 10")
    }
  }

  method aproboLaMateria(materia){
    return materiasCursadas.any({m => m.esIgual(materia) && m.estaAprobada()})
  }

  method materiasAprobadasDeCarrera(carrera){
    return materiasCursadas.filter({m => carrera.pertenece(m.materia()) && m.estaAprobada()})
  }

  method cantidadDeMateriasAprobadasDeCarrera(carrera){
    return self.materiasAprobadasDeCarrera(carrera).size()
  }

  method promedioDeMateriasAprobadasDeCarrera(carrera){
    const materiasAprobadas = self.materiasAprobadasDeCarrera(carrera)

    if (materiasAprobadas.isEmpty()) {
      self.error("No hay materias aprobadas en la carrera " + carrera)
    }
    
    return materiasAprobadas.sum({m => m.nota()}) / materiasAprobadas.size()
  }

  method cantidadTotalDeMateriasAprobadas(){
    return materiasCursadas.filter({m => m.estaAprobada()}).size()
  }

  method promedioTotalDeMateriasAprobadas(){
    const materiasAprobadas = materiasCursadas.filter({m => m.estaAprobada()})

    if (materiasAprobadas.isEmpty()) {
      self.error("No hay materias aprobadas")
    }
    return materiasAprobadas.sum({m => m.nota()}) / materiasAprobadas.size()
  }

  method historialDeLaMateria(materia){
    return materiasCursadas.filter({m => m.esIgual(materia)}) 
  }

  method puedeInscribirseA(materia) =
    self.esDeUnaCarreraActual(materia)
    && !self.aproboLaMateria(materia)
    && !self.estaInscriptoA(materia)
    && materia.puedeCursarla(self)

  method esDeUnaCarreraActual(materia) =
    carrerasCursando.any({ c => c.pertenece(materia) })

  method inscribirAMateria(materia) {
    if (!self.puedeInscribirseA(materia)) {
      self.error("El estudiante no puede inscribirse a la materia " + materia.nombre())
    }
    inscripciones.add(materia)
    materia.agregarEstudiante(self)
}

  method materiasALasQuePuedeInscribirseEn(carrera){
    const materiasDeCarrera = carrera.materias()
    return materiasDeCarrera.filter({m => self.puedeInscribirseA(m)})
  }

  method creditosActualesEnLaCarreraDe(materia){
    if (!self.esDeUnaCarreraActual(materia)){
      self.error("La materia " + materia.nombre() + " no es de ninguna carrera actual")
    }
    return  self.sumarCreditos(self.materiasAprobadasDeCarrera(self.carreraDe(materia)))
  }

  method carreraDe(materia){
    return carrerasCursando.find({ c => c.pertenece(materia)})
  }

  method sumarCreditos(materias){
    return materias.sum({m => m.materia().creditosQueOtorga()})
  }

  method aproboTodasLasDelAñoEnLaCarreraDe(año, materia){
    return self.carreraDe(materia).materiasDelAño(año).all({ m => self.aproboLaMateria(m) })
  }

  method materiasEnEspera(){
    return inscripciones.filter({m => m.estaEnListaDeEspera(self)})
  }

  method materiasConfirmadas(){
   return inscripciones.filter({m => m.estaEnListaDeEstudiantes(self)})
  }

  method darseDeBajaDe(materia) {
   materia.retirarEstudiante(self)  
   inscripciones.remove(materia)
  } 

}


class Carrera {

  const property nombre = ""
  const property materias = #{}

  method agregarMateria(materia){
    materias.add(materia)
  }

  method pertenece(materia){
    return materias.contains(materia)
  }

  method materiasDelAño(año){
   return materias.filter({ m => m.año() == año })
  }

}


class Materia {

  const property nombre = ""
  const estudiantesInscriptos = #{}
  const listaDeEspera = []
  var property requisito = nada
  var property creditosQueOtorga = 0
  var property año = 0
  var property cupo = 30
  
  method agregarEstudiante(estudiante){
    if(estudiantesInscriptos.size() == cupo){listaDeEspera.add(estudiante)}
    else {estudiantesInscriptos.add(estudiante)}
  }

  method estudiantesInscriptos(){
    return estudiantesInscriptos
  }

  method puedeCursarla(estudiante){
    return requisito.cumple(estudiante, self)
  }

  method retirarEstudiante(estudiante){
    self.validarEstudianteEnLaMateria(estudiante)
    estudiantesInscriptos.remove(estudiante)
    listaDeEspera.remove(estudiante)
    self.agregarPrimerEstudianteEnListaDeEspera()
  }

  method validarEstudianteEnLaMateria(estudiante){
    if(!self.estaEnListaDeEstudiantes(estudiante) && !self.estaEnListaDeEspera(estudiante)){
      self.error("El estudiante " + estudiante + " no está inscripto en la materia")
    }
  }

  method agregarPrimerEstudianteEnListaDeEspera(){
    if(!listaDeEspera.isEmpty()){
      estudiantesInscriptos.add(listaDeEspera.first())
      listaDeEspera.remove(listaDeEspera.first())
    }
  }

  method listaDeEspera(){return listaDeEspera}

  method estaEnListaDeEspera(estudiante){
    return listaDeEspera.contains(estudiante)
  }

  method estaEnListaDeEstudiantes(estudiante){
    return estudiantesInscriptos.contains(estudiante)
  }


}

class MateriaCursada{

  const property materia 
  const property nota 

  method esIgual(unaMateria){
    return materia == unaMateria
  }

  method estaAprobada(){
    return nota >= 6
  }

}
