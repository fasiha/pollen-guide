#lang pollen

◊(define (emphatic . xs) `(em ,@xs))
◊(define (linky url . xs) `(a ((href ,url)) ,@xs))

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

◊h1{Take One. Or, Let's Try To Get the Basics.}

Let's try and make the basics work. How do we do things like the tutorials on Pollen markup: ◊emphatic{italicize things}, make ◊linky["http://github.com"]{links to cool things}, and, hardest of all, take a single sidenote and make it into ◊emphatic{three} HTML tags that Tufte-CSS needs?◊sidenote["sidenoteReference"]{Here's that sidenote!}

Observe that ◊emphatic{this call} produces the same result as ◊(emphatic "this call"). And Pollen, when targeting HTML, can deal with attributes in the same way: ◊span['((class "hidden"))]{this span} produces the same output as ◊(span '((class "hidden")) "this span"). But watch out! If you ◊code{define} a tag like we did with ◊code{linky} to make links, you can't just randomly pass attributes in this way, since ◊code{linky} is expecting two arguments, a URL and some text. This won't work: (missing ◊lozenge{})linky['((class "hidden") (href "/"))]{won't work}.

Build me with ◊pre{
$ raco pollen render take1.html
$ python -m SimpleHTTPServer 9090
}
Then visit ◊linky["http://localhost:9090/take1.html"]{localhost:9090/take1.html}.
