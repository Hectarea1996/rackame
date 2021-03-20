333
((3) 0 () 1 ((q lib "rackame/main.rkt")) () (h ! (equal) ((c def c (c (? . 0) q destroy-instance)) q (322 . 3)) ((c def c (c (? . 0) q get-instance-extensions)) q (227 . 3)) ((c def c (c (? . 0) q instance?)) q (83 . 3)) ((c def c (c (? . 0) q create-instance)) q (0 . 3)) ((c def c (c (? . 0) q get-instance-layers)) q (136 . 3))))
procedure
(create-instance validation) -> instance?
  validation : boolean?
procedure
(instance? v) -> boolean?
  v : any
procedure
(get-instance-layers instance) -> (listof bytes?)
  instance : instance?
procedure
(get-instance-extensions instance) -> (listof bytes?)
  instance : instance?
procedure
(destroy-instance instance) -> void?
  instance : instance?
