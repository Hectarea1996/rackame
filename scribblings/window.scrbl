#lang scribble/manual
@(require (for-label racket
                     rackame
                     (except-in ffi/unsafe ->)))


@title{Window}



@defstruct[rkm-window ([glfw-window cpointer?] [surface rkm-surface?])]{
    Representa una ventana.
}


@defproc[(rkm-create-window [instance rkm-instance?] [name string?] [width integer?] [height integer?])
         rkm-window?]{
    Crea una ventana con nombre @racket[name] y tamaño @racket[windth]*@racket[height].
}