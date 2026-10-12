object nada {

    method cumple(estudiante, materia){
        return true
    }

}

class Creditos {

    var property creditosNecesarios = 0

    method cumple(estudiante, materia){
        return estudiante.creditosActualesEnLaCarreraDe(materia) >= creditosNecesarios
    }

}

object porAño {

    method cumple(estudiante, materia){
        return estudiante.aproboTodasLasDelAñoEnLaCarreraDe((materia.año() - 1), materia)
    }

}

class Correlativas {

    const property materiasPrevias = #{}

    method cumple(estudiante, materia){
        return materiasPrevias.all({ m => estudiante.aproboLaMateria(m) })
    }
}