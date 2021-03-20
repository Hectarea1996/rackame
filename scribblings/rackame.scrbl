#lang scribble/manual
@(require (for-label racket
                     rackame))

@title{Rackame}

@author[(author+email "Héctor Galbis Sanchis" "hectometrocuadrado@gmail.com")]

@defmodule[rackame]

Rackame apunta a ser un software para crear videojuegos usando el lenguaje Racket.

@local-table-of-contents[]

@section{Instancia}

@defproc[(create-instance [validation boolean?])
         instance?]{
    Crea una instancia de vulkan. 

    Si @racket[validation] no es @racket[#f] se activará la capa de validación de
    vulkan.
}

@defproc[(instance? [v any])
         boolean?]{
    Comprueba si el valor @racket[v] es una instancia. En ese caso se devuelve #t. En otro
    caso se retorna #f.
}

@defproc[(get-instance-layers [instance instance?])
         (listof bytes?)]{
    Devuelve las capas activadas por la instancia.
}

@defproc[(get-instance-extensions [instance instance?])
         (listof bytes?)]{
    Devuelve las extensiones activadas por la instancia.
}

@defproc[(destroy-instance [instance instance?])
         void?]{
    Destruye una instancia de vulkan.
}



