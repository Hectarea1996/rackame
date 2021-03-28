#lang scribble/manual
@(require (for-label racket
                     rackame
                     (except-in ffi/unsafe ->)))


@title{Window}


@defproc[(rkm-create-window [instance rkm-instance?] [name string?] [width integer?] [height integer?])
         rkm-window?]{
    Crea una ventana con nombre @racket[name] y tamaño @racket[windth]*@racket[height].
}

@defproc[(rkm-window? [v any])
         boolean?]{
    Comprueba si @racket[v] es una ventana.
}

@defproc[(rkm-window-glfw-window [window rkm-window?])
         cpointer?]{
    Devuelve la ventana de glfw.
}

@defproc[(rkm-destroy-window [window rkm-window?])
         void?]{
    Destruye una ventana.
}