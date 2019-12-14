#lang racket

(require pollen/decode)

(define (root . xs)
  (decode `(div ,@xs)
          #:txexpr-elements-proc detect-paragraphs
          #:exclude-tags '(pre)
          ))

(provide (all-defined-out))

