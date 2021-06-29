
#lang racket/base

(require "physical-device.rkt"
         vulkan/unsafe)


(struct rkm-family-queue
    (family-index))