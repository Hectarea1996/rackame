#lang scribble/manual
@(require (for-label racket
                     rackame
                     (except-in ffi/unsafe ->)))


@title{Surface}



@defstruct[rkm-surface ([vk-instance VkInstance] [vk-surface VkSurface])]{
        Representa una surface.
}


@defproc[(rkm-create-surface [instance rkm-instance?] [window cpointer?])
         rkm-surface?]{
        Crea una surface.
}