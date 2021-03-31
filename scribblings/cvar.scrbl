#lang scribble/manual

@(require (for-label racket
                     rackame
                     (except-in ffi/unsafe ->)))
                

@title{cvar}

Facilita el uso de variables de C.


@defproc[(make-cvar [type ctype?]) cvar?]{
    Genera una variable C de tipo @racket[type].
}


@defproc[(cvar [type ctype?] [val any]) cvar?]{
    Genera una variable C de tipo @racket[type] y se inicializa con valor @racket[val].
}


@defproc[(cvar? [v any]) boolean?]{
    Comprueba si el @racket[v] es una variable C (cvar) o no.
}


@defproc[(cvar-ref [cv cvar?]) any]{
    Devuelve el valor de la variable @racket[cv].
}


@defproc[(cvar-set! [cv cvar?] [val any]) void?]{
    Asigna el valor @racket[val] a la variable @racket[cv].
}


@defproc[(cvar-type [cv cvar?]) ctype?]{
    Devuelve el tipo de la variable @racket[cv].
}


@defproc[(cvar-ptr [cv cvar?]) cpointer?]{
    Devuelve el puntero a la variable @racket[cv].
}


@defproc[(make-cvar* [cptr cpointer?] [type ctype?]) cvar?]{
    Construye una variable usando el puntero @racket[cptr].
}