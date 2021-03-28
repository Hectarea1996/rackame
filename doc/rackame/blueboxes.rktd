862
((3) 0 () 1 ((q lib "rackame/main.rkt")) () (h ! (equal) ((c def c (c (? . 0) q rkm-window?)) q (1144 . 3)) ((c def c (c (? . 0) q rkm-create-window)) q (872 . 9)) ((c def c (c (? . 0) q rkm-destroy-window)) q (1284 . 3)) ((c def c (c (? . 0) q rkm-create-instance)) q (0 . 3)) ((c def c (c (? . 0) q rkm-instance?)) q (91 . 3)) ((c def c (c (? . 0) q rkm-destroy-surface)) q (791 . 3)) ((c def c (c (? . 0) q rkm-instance-layers)) q (148 . 3)) ((c def c (c (? . 0) q rkm-instance-extensions)) q (243 . 3)) ((c def c (c (? . 0) q rkm-destroy-instance)) q (436 . 3)) ((c def c (c (? . 0) q rkm-create-surface)) q (521 . 4)) ((c def c (c (? . 0) q rkm-window-glfw-window)) q (1199 . 3)) ((c def c (c (? . 0) q rkm-instance-vk-instance)) q (342 . 3)) ((c def c (c (? . 0) q rkm-surface?)) q (644 . 3)) ((c def c (c (? . 0) q rkm-surface-vk-surface)) q (700 . 3))))
procedure
(rkm-create-instance validation) -> rkm-instance?
  validation : boolean?
procedure
(rkm-instance? v) -> boolean?
  v : any
procedure
(rkm-instance-layers instance) -> (listof bytes?)
  instance : rkm-instance?
procedure
(rkm-instance-extensions instance) -> (listof bytes?)
  instance : rkm-instance?
procedure
(rkm-instance-vk-instance instance) -> VkInstance
  instance : rkm-instance?
procedure
(rkm-destroy-instance instance) -> void?
  instance : rkm-instance?
procedure
(rkm-create-surface instance window) -> rkm-surface?
  instance : rkm-instance?
  window : cpointer?
procedure
(rkm-surface? v) -> boolean?
  v : any
procedure
(rkm-surface-vk-surface surface) -> VkSurfaceKHR
  surface : rkm-surface?
procedure
(rkm-destroy-surface surface) -> void?
  surface : rkm-surface?
procedure
(rkm-create-window instance     
                   name         
                   width        
                   height)  -> rkm-window?
  instance : rkm-instance?
  name : string?
  width : integer?
  height : integer?
procedure
(rkm-window? v) -> boolean?
  v : any
procedure
(rkm-window-glfw-window window) -> cpointer?
  window : rkm-window?
procedure
(rkm-destroy-window window) -> void?
  window : rkm-window?
