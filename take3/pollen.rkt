#lang racket

(require pollen/world pollen/decode)

(define (root . xs)
  (decode `(decoded-root ,@xs)
          #:txexpr-elements-proc detect-paragraphs
          #:exclude-tags '(pre)
          ))

(provide (all-defined-out))

