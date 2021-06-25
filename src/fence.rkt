#lang racket/base

(require "device.rkt" 
         "cvar.rkt"
         vulkan/unsafe
         ffi/unsafe/alloc
         ffi/cvector)


(provide (struct-out rkm-fence)
         rkm-create-fence
         rkm-reset-fence
         rkm-reset-fences
         rkm-wait-for-fence
         rkm-wait-for-fences)



(struct rkm-fence
   (vk-device
    vk-fence))


(define UINT64_MAX (- (expt 2 64) 1))


(define (create-fence device #:signaled [signaled #f])

    (define vk-device (rkm-device-vk-device device))

    (define vk-fence-info (make-VkFenceCreateInfo VK_STRUCTURE_TYPE_FENCE_CREATE_INFO
                                                  #f
                                                  (if signaled VK_FENCE_CREATE_SIGNALED_BIT 0)))
                                                  
    (define cv-fence (make-cvar _VkFence))
    (define fence-result (vkCreateFence vk-device vk-fence-info #f (cvar-ptr cv-fence)))
    (check-vkResult fence-result)
    
    (rkm-fence vk-device cvar-ref cv-fence))



(define (destroy-fence fence)

    (define vk-device (rkm-fence-vk-device fence))
    (define vk-fence (rkm-fence-vk-fence fence))

    (vkDestroyFence vk-device vk-fence #f))



(define rkm-create-fence ((allocator destroy-fence) create-fence))



(define (rkm-reset-fence fence)
    
    (define vk-device (rkm-fence-vk-device fence))
    (define vk-fence (rkm-fence-vk-fence fence))
    (define cv-fence (cvar _VkFence vk-fence))
    
    (define reset-result (vkResetFences vk-device 1 (cvar-ptr cv-fence)))
    (check-vkResult reset-result))


(define (rkm-reset-fences fences)
    
    (define vk-device (rkm-fence-vk-device (car fences)))
    (define vk-fences (map rkm-fence-vk-fence fences))
    (define cv-fences (list->cvector fences _VkFence))
    
    (define reset-result (vkResetFences vk-device (cvector-length cv-fences) (cvector-ptr cv-fences)))
    (check-vkResult reset-result))



(define (rkm-wait-for-fence fence #:timeout [timeout UINT64_MAX])

    (define vk-device (rkm-fence-vk-device fence))
    (define vk-fence (rkm-fence-vk-fence fence))
    (define cv-fence (cvar _VkFence vk-fence))
    
    (define wait-result (vkWaitForFences vk-device 1 (cvar-ptr cv-fence) VK_TRUE timeout))
    (check-vkResult wait-result))


(define (rkm-wait-for-fences fences #:waitAll [waitAll #t] #:timeout [timeout UINT64_MAX])

    (define vk-device (rkm-fence-vk-device (car fences)))
    (define vk-fences (map rkm-fence-vk-fence fences))
    (define cv-fences (list->cvector fences _VkFence))
    
    (define wait-result (vkWaitForFences vk-device (cvector-length cv-fences) (cvector-ptr cv-fences) (if waitAll VK_TRUE VK_FALSE) timeout))
    (check-vkResult wait-result))