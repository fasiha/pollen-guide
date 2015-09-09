#lang pollen
◊(define (emphatic . xs) `(em ,@xs))
◊(define (linky url . xs) `(a ((href ,url)) ,@xs))





◊h1{Take One. Or, Let's Try To Get the Basics.}

Let's try and make the basics work. How do we do things like the tutorials on Pollen markup: ◊emphatic{italicize things}. How do we make ◊linky["http://github.com"]{links to cool things}? Cool!

Observe that ◊emphatic{this call} produces the same result as ◊(emphatic "this call"). And Pollen, when targeting HTML, can deal with attributes in the same way: ◊span['((class "hidden"))]{this span} produces the same output as ◊(span '((class "hidden")) "this span"). But watch out! If you ◊code{define} a tag like we did with ◊code{linky} to make links, you can't just randomly pass attributes in this way. Since ◊code{linky} is expecting its first argument to be a string URL, not a list, this won't even compile: ◊code{(missing ◊lozenge{})linky['((class "hidden") (href "/"))]{won't work}}.

Build me with ◊pre{
$ raco pollen render take1.html
}
Then open `take1.html` in your browser.
