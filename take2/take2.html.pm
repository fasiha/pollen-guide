#lang pollen
◊(require txexpr)
◊(require pollen/world pollen/decode)

◊(define (sidenote label . xs)
  (define string-label label)
  `(splice-me ,@(list 
    `(label ((for ,string-label)(class "margin-toggle sidenote-number"))) 
    `(input ((id ,string-label)(class "margin-toggle")(type "checkbox"))) 
    `(span ((class "sidenote")) ,@xs))))

◊(define (splice xs)
  (define tags-to-splice '(splice-me))
  (apply append (for/list ([x (in-list xs)])
                  (if (and (txexpr? x) (member (get-tag x) tags-to-splice))
                      (get-elements x)
                      (list x)))))

◊(define (root . xs)
  (decode `(decoded-root ,@xs)
          #:txexpr-elements-proc (compose1 detect-paragraphs splice)
          #:exclude-tags '(style script pre)
          ))

◊h1{Take Two. Or, some things are harder than they appear.}

◊section{
Tufte CSS' has nice sidenotes, but each sidenote is made up of three side-by-side tags: a ◊code{<label>} to contain a unique identifier, a fake ◊code{<input>}, and a ◊code{span} tag containing the sidenote's content. We'd like to make a single ◊code{sidenote} tag in Pollen that renders to that.◊sidenote["sidenoteReference"]{Here's that sidenote!}

None of the magic from Take One helps tell us how to expand a single tag into three adjacent ones, unless it's something stupid like combining the three into a single parent tag (NE VEUX PAS). So we need some new magic, courtesy of Matthew Butterick's ◊a['((href "http://unitscale.com/mb/technique/pollen.rkt.html"))]{example code}: the ◊code{splice} function and a custom ◊code{root} function.

We also desperately need to automatically detect paragraphs and insert ◊code{<p>} tags.

Build me with ◊pre{
$ raco pollen render take2.html
$ python -m SimpleHTTPServer 9090
}
Then visit ◊a['((href "http://localhost:9090/take2.html"))]{localhost:9090/take2.html}. Or just open ◊code{take2.html} in your browser.
}