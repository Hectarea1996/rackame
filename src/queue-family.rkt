#lang racket/base


(require "cvar.rkt"
         "physical-device.rkt"
         "surface.rkt"
         racket/bool
         vulkan/unsafe
         ffi/unsafe
         ffi/cvector)


(provide (struct-out rkm-queue-family)
         rkm-get-family-queue
         rkm-get-family-queues)


; ----------------------------------------------------
; ------------------- Estructuras --------------------
; ----------------------------------------------------

(struct rkm-queue-family
    (index
     queue-flags
     queue-count))


; ----------------------------------------------------
; ---------------- Funciones privadas ----------------
; ----------------------------------------------------

; Devuelve las propiedades de las familias de colas de un dispositivo
(define (get-family-queues-properties vk-physical-device)

  (define family-queues-count (make-cvar _uint32))
  (vkGetPhysicalDeviceQueueFamilyProperties vk-physical-device (cvar-ptr family-queues-count) #f)
  (define family-queues-properties (make-cvector _VkQueueFamilyProperties (cvar-ref family-queues-count)))
  (vkGetPhysicalDeviceQueueFamilyProperties vk-physical-device (cvar-ptr family-queues-count) (cvector-ptr family-queues-properties))

  (cvector->list family-queues-properties))


; Devuelve una familia de colas que verifique las restricciones dadas
(define (get-family-queue vk-physical-device queue-flags queue-count vk-surface exclusive-flags except-out)

    (define vk-family-properties (get-family-queues-properties vk-physical-device))
    (for/or ([index (build-list (length vk-family-properties) values)] [property vk-family-properties])
        (if (and (implies (> queue-flags 0) (and (equal? (bitwise-and (VkQueueFamilyProperties-queueFlags property) queue-flags) queue-flags)
                                                 (implies exclusive-flags
                                                         (equal? (bitwise-ior (VkQueueFamilyProperties-queueFlags property) queue-flags)))))
                 (implies vk-surface (let ([cv-present-queue (make-cvar _VkBool32)])
                                      (vkGetPhysicalDeviceSurfaceSupportKHR vk-physical-device index vk-surface (cvar-ptr cv-present-queue))
                                      (cvar-ref cv-present-queue)))
                 (implies (> queue-count 0) (>= (VkQueueFamilyProperties-queueCount property) queue-count))
                 (not (for/or ([exception except-out])
                          (equal? (rkm-queue-family-index exception) index))))
            (rkm-queue-family index (VkQueueFamilyProperties-queueFlags property) queue-count)
            #f)))


; Devuelve una lista de familias de colas que verifican las restricciones dadas
(define (get-family-queues vk-physical-device queue-flags queue-count vk-surface exclusive-flags except-out)

    (define vk-family-properties (get-family-queues-properties vk-physical-device))
    (for/list ([index (build-list (length vk-family-properties) values)] [property vk-family-properties]
               #:when (and (implies (> queue-flags 0) (and (equal? (bitwise-and (VkQueueFamilyProperties-queueFlags property) queue-flags) queue-flags)
                                                       (implies exclusive-flags
                                                               (equal? (bitwise-ior (VkQueueFamilyProperties-queueFlags property) queue-flags)))))
                           (implies vk-surface (let ([cv-present-queue (make-cvar _VkBool32)])
                                                (vkGetPhysicalDeviceSurfaceSupportKHR vk-physical-device index vk-surface (cvar-ptr cv-present-queue))
                                                (cvar-ref cv-present-queue)))
                           (implies (> queue-count 0) (>= (VkQueueFamilyProperties-queueCount property) queue-count))
                           (not (for/or ([exception except-out])
                                    (equal? (rkm-queue-family-index exception) index)))))
        (rkm-queue-family index (VkQueueFamilyProperties-queueFlags property) queue-count)))


; ----------------------------------------------------
; ---------------- Funciones publicas ----------------
; ----------------------------------------------------

; Devuelve una familia de colas que verifique las restricciones dadas
(define (rkm-get-family-queue physical-device #:queue-flags [queue-flags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                                                                      VK_QUEUE_TRANSFER_BIT
                                                                                      VK_QUEUE_COMPUTE_BIT)]
                              #:surface [surface #f]
                              #:queue-count [queue-count 1]
                              #:exclusive-flags [exclusive-flags #f]
                              #:families-out [families-out '()])

    (define vk-physical-device (rkm-physical-device-vk-physical-device physical-device))
    (define vk-surface (and surface (rkm-surface-vk-surface surface)))

    (get-family-queue vk-physical-device queue-flags queue-count vk-surface exclusive-flags families-out))


; Devuelve una lista de familias de colas que verifican las restricciones dadas
(define (rkm-get-family-queues physical-device #:queue-flags [queue-flags (bitwise-ior VK_QUEUE_GRAPHICS_BIT
                                                                                      VK_QUEUE_TRANSFER_BIT
                                                                                      VK_QUEUE_COMPUTE_BIT)]
                               #:surface [surface #f]
                               #:queue-count [queue-count 1]
                               #:exclusive-flags [exclusive-flags #f]
                               #:families-out [families-out '()])

    (define vk-physical-device (rkm-physical-device-vk-physical-device physical-device))
    (define vk-surface (and surface (rkm-surface-vk-surface surface)))

    (get-family-queues vk-physical-device queue-flags queue-count vk-surface exclusive-flags families-out))
