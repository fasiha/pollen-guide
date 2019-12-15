#lang pollen
◊(require txexpr)
◊(require pollen/decode)

◊(define (sidenote label . xs)
  `(splice-me
     (label ((for ,label) (class "margin-toggle sidenote-number"))) 
     (input ((id ,label) (class "margin-toggle")(type "checkbox"))) 
     (span ((class "sidenote")) ,@xs)))

◊;literally the same as above
◊(define (stupid-sidenote label . xs)
  `(stupid-sidenote
     (label ((for ,label) (class "margin-toggle sidenote-number"))) 
     (input ((id ,label) (class "margin-toggle")(type "checkbox"))) 
     (span ((class "sidenote")) ,@xs)))

◊(define (splice xs)
  (apply append (for/list ([x (in-list xs)])
                  (if (and (txexpr? x) (member (get-tag x) '(splice-me)))
                      (get-elements x)
                      (list x)))))

◊(define (root . xs)
  (decode `(decoded-root ,@xs)
          #:txexpr-elements-proc (compose1 detect-paragraphs splice)
          #:exclude-tags '(pre)
          ))

◊h1{Take Two. Or, some things are harder than they appear.}

◊section{
Tufte CSS' has nice sidenotes, but each sidenote is made up of three side-by-side tags: a ◊code{<label>} to contain a unique identifier, a fake ◊code{<input>}, and a ◊code{span} tag containing the sidenote's content. We'd like to make a single ◊code{sidenote} tag in Pollen that renders to that.◊sidenote["sidenoteReference"]{Here's that sidenote!}

None of the magic from Take One helps tell us how to expand a single tag into three adjacent ones, unless it's something stupid like combining the three into a single parent tag (NE VEUX PAS◊stupid-sidenote["although"]{Although it would work.}). So we need some new magic, courtesy of Matthew Butterick's ◊a['((href "http://unitscale.com/mb/technique/pollen.rkt.html"))]{example code}: the ◊code{splice} function and a custom ◊code{root} function.

We also desperately need to automatically detect paragraphs and insert ◊code{<p>} tags.

Build me with ◊pre{
$ raco pollen render take2.html
}
Then open ◊code{take2.html} in your browser.
}
