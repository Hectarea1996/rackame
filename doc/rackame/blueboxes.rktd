3791
((3) 0 () 6 ((q lib "rackame/main.rkt") (q 1779 . 30) (q 3032 . 16) (q 510 . 6) (q 900 . 5) (q 1270 . 5)) () (h ! (equal) ((c def c (c (? . 0) q struct:rkm-instance)) c (? . 3)) ((c def c (c (? . 0) q rkm-swapchain?)) c (? . 2)) ((c def c (c (? . 0) q rkm-device-graphics-pool)) c (? . 1)) ((c def c (c (? . 0) q rkm-device)) c (? . 1)) ((c def c (c (? . 0) q rkm-swapchain-device)) c (? . 2)) ((c def c (c (? . 0) q rkm-create-device)) q (2832 . 4)) ((c def c (c (? . 0) q rkm-window)) c (? . 5)) ((c def c (c (? . 0) q rkm-instance-vk-instance)) c (? . 3)) ((c def c (c (? . 0) q rkm-device-present-pool)) c (? . 1)) ((c def c (c (? . 0) q rkm-device-transfer-pool)) c (? . 1)) ((c def c (c (? . 0) q cvar)) q (59 . 4)) ((c def c (c (? . 0) q cvar-ref)) q (183 . 3)) ((c def c (c (? . 0) q rkm-swapchain)) c (? . 2)) ((c def c (c (? . 0) q rkm-surface-vk-instance)) c (? . 4)) ((c def c (c (? . 0) q rkm-destroy-surface)) q (1189 . 3)) ((c def c (c (? . 0) q rkm-instance-layers)) c (? . 3)) ((c def c (c (? . 0) q rkm-device-transfer-queue)) c (? . 1)) ((c def c (c (? . 0) q make-rkm-swapchain)) c (? . 2)) ((c def c (c (? . 0) q rkm-surface)) c (? . 4)) ((c def c (c (? . 0) q rkm-device-transfer-index)) c (? . 1)) ((c def c (c (? . 0) q rkm-window-glfw-window)) c (? . 5)) ((c def c (c (? . 0) q cvar-set!)) q (234 . 4)) ((c def c (c (? . 0) q rkm-device-vk-device)) c (? . 1)) ((c def c (c (? . 0) q rkm-create-window)) q (1430 . 9)) ((c def c (c (? . 0) q rkm-instance)) c (? . 3)) ((c def c (c (? . 0) q cvar?)) q (134 . 3)) ((c def c (c (? . 0) q rkm-instance?)) c (? . 3)) ((c def c (c (? . 0) q rkm-device-compute-pool)) c (? . 1)) ((c def c (c (? . 0) q rkm-device-vk-physical-device)) c (? . 1)) ((c def c (c (? . 0) q cvar-type)) q (309 . 3)) ((c def c (c (? . 0) q make-rkm-surface)) c (? . 4)) ((c def c (c (? . 0) q make-rkm-window)) c (? . 5)) ((c def c (c (? . 0) q rkm-device-present-index)) c (? . 1)) ((c def c (c (? . 0) q rkm-window?)) c (? . 5)) ((c def c (c (? . 0) q rkm-destroy-swapchain)) q (3686 . 3)) ((c def c (c (? . 0) q rkm-create-surface)) q (1066 . 4)) ((c def c (c (? . 0) q rkm-device-compute-index)) c (? . 1)) ((c def c (c (? . 0) q rkm-destroy-window)) q (1702 . 3)) ((c def c (c (? . 0) q rkm-swapchain-image-views)) c (? . 2)) ((c def c (c (? . 0) q make-cvar*)) q (421 . 4)) ((c def c (c (? . 0) q struct:rkm-surface)) c (? . 4)) ((c def c (c (? . 0) q rkm-swapchain-images)) c (? . 2)) ((c def c (c (? . 0) q make-rkm-device)) c (? . 1)) ((c def c (c (? . 0) q rkm-device?)) c (? . 1)) ((c def c (c (? . 0) q rkm-create-swapchain)) q (3563 . 4)) ((c def c (c (? . 0) q rkm-surface-vk-surface)) c (? . 4)) ((c def c (c (? . 0) q rkm-swapchain-extent)) c (? . 2)) ((c def c (c (? . 0) q rkm-device-graphics-queue)) c (? . 1)) ((c def c (c (? . 0) q rkm-create-instance)) q (724 . 3)) ((c def c (c (? . 0) q rkm-window-surface)) c (? . 5)) ((c def c (c (? . 0) q rkm-destroy-instance)) q (815 . 3)) ((c def c (c (? . 0) q rkm-swapchain-image-count)) c (? . 2)) ((c def c (c (? . 0) q rkm-device-present-queue)) c (? . 1)) ((c def c (c (? . 0) q make-rkm-instance)) c (? . 3)) ((c def c (c (? . 0) q rkm-swapchain-vk-swapchain)) c (? . 2)) ((c def c (c (? . 0) q rkm-swapchain-format)) c (? . 2)) ((c def c (c (? . 0) q rkm-device-compute-queue)) c (? . 1)) ((c def c (c (? . 0) q struct:rkm-device)) c (? . 1)) ((c def c (c (? . 0) q cvar-ptr)) q (364 . 3)) ((c def c (c (? . 0) q rkm-instance-extensions)) c (? . 3)) ((c def c (c (? . 0) q struct:rkm-swapchain)) c (? . 2)) ((c def c (c (? . 0) q struct:rkm-window)) c (? . 5)) ((c def c (c (? . 0) q make-cvar)) q (0 . 3)) ((c def c (c (? . 0) q rkm-device-graphics-index)) c (? . 1)) ((c def c (c (? . 0) q rkm-destroy-device)) q (2955 . 3)) ((c def c (c (? . 0) q rkm-surface?)) c (? . 4))))
procedure
(make-cvar type) -> cvar?
  type : ctype?
procedure
(cvar type val) -> cvar?
  type : ctype?
  val : any
procedure
(cvar? v) -> boolean?
  v : any
procedure
(cvar-ref cv) -> any
  cv : cvar?
procedure
(cvar-set! cv val) -> void?
  cv : cvar?
  val : any
procedure
(cvar-type cv) -> ctype?
  cv : cvar?
procedure
(cvar-ptr cv) -> cpointer?
  cv : cvar?
procedure
(make-cvar* cptr type) -> cvar?
  cptr : cpointer?
  type : ctype?
struct
(struct rkm-instance (vk-instance layers extensions)
    #:extra-constructor-name make-rkm-instance)
  vk-instance : VkInstance
  layers : (listof bytes?)
  extensions : (listof bytes?)
procedure
(rkm-create-instance validation) -> rkm-instance?
  validation : boolean?
procedure
(rkm-destroy-instance instance) -> void?
  instance : rkm-instance?
struct
(struct rkm-surface (vk-instance vk-surface)
    #:extra-constructor-name make-rkm-surface)
  vk-instance : VkInstance
  vk-surface : VkSurface
procedure
(rkm-create-surface instance window) -> rkm-surface?
  instance : rkm-instance?
  window : cpointer?
procedure
(rkm-destroy-surface surface) -> void?
  surface : rkm-surface?
struct
(struct rkm-window (glfw-window surface)
    #:extra-constructor-name make-rkm-window)
  glfw-window : cpointer?
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
(rkm-destroy-window window) -> void?
  window : rkm-window?
struct
(struct rkm-device (vk-physical-device
                    vk-device
                    graphics-index
                    transfer-index
                    compute-index
                    present-index
                    graphics-queue
                    transfer-queue
                    compute-queue
                    present-queue
                    graphics-pool
                    transfer-pool
                    compute-pool
                    present-pool)
    #:extra-constructor-name make-rkm-device)
  vk-physical-device : VkPhysicalDevice
  vk-device : VkDevice
  graphics-index : integer?
  transfer-index : integer?
  compute-index : integer?
  present-index : integer?
  graphics-queue : VkQueue
  transfer-queue : VkQueue
  compute-queue : VkQueue
  present-queue : VkQueue
  graphics-pool : VkCommandPool
  transfer-pool : VkCommandPool
  compute-pool : VkCommandPool
  present-pool : VkCommandPool
procedure
(rkm-create-device instance window) -> rkm-device?
  instance : rkm-instance?
  window : rkm-window?
procedure
(rkm-destroy-device device) -> void?
  device : rkm-device?
struct
(struct rkm-swapchain (device
                       vk-swapchain
                       format
                       extent
                       image-count
                       images
                       image-views)
    #:extra-constructor-name make-rkm-swapchain)
  device : rkm-device?
  vk-swapchain : VkSwapchainKHR
  format : VkFormat
  extent : VkExtent2D
  image-count : integer?
  images : (listof VkImage)
  image-views : (listof VkImageView)
procedure
(rkm-create-swapchain device window) -> rkm-swapchain?
  device : rkm-device?
  window : rkm-window?
procedure
(rkm-destroy-swapchain swapchain) -> void?
  swapchain : rkm-swapchain?
