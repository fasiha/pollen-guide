# A poor guide to Pollen
The [official Pollen documentation](pkg-build.racket-lang.org/doc/pollen/) is a rich and hearty repast. That may be why it took me longer than expected to get where I wanted to go.

So, here’s a poor and meagre introduction that may help others get started as quickly as possible.

## Goal
I’m trying to write Pollen markup that generates Dave Liepmann’s [Tufte CSS](http://www.daveliepmann.com/tufte-css/)-compliant HTML. Tufte CSS has some nice rules for sidenotes and headings that I’d like to write for, without writing HTML.

## Preliminaries
Install [Racket](http://download.racket-lang.org/)

> On **Mac OS X**, verify the installation location by running `$ /Applications/Racket\ v6.2.1/bin/racket -v`, then add the following to your `~/.bash_profile`: 
```bash
export PATH="$PATH:/Applications/Racket v6.2.1/bin"
```

Then install Pollen by running `$ raco pkg install pollen` and answering “yes” a couple of times.

Now. After reading portions of [three](http://pkg-build.racket-lang.org/doc/pollen/first-tutorial.html) [longform](http://pkg-build.racket-lang.org/doc/pollen/second-tutorial.html) [tutorials](http://pkg-build.racket-lang.org/doc/pollen/third-tutorial.html) ([fourth](http://pkg-build.racket-lang.org/doc/pollen/fourth-tutorial.html) available), a [mini-tutorial](http://pkg-build.racket-lang.org/doc/pollen/mini-tutorial.html), and a [quick tour](http://pkg-build.racket-lang.org/doc/pollen/quick-tour.html), you will likely be very excited about many things. But for purposes of this poor guide, you can forget everything about DrRacket, `.pp` Pollen preprocessor files, `.pmd` & Pollen-Markdown mode, the Pollen project server (`raco pollen start`), etc.

We’ll be writing Pollen markup directly in `.html.pm` files, rendering them from the command line with `raco pollen render`, and viewing just the result in a browser. Clone this repository and follow along.

**N.B.** I’m assuming some passing familiarity with a Lisp, like Common Lisp or Emacs Lisp or Scheme or Clojure. The examples that follow have enough weird Pollen awesomeness that I can’t stop and explain parens or symbols or [`,@ unquote-splicing`](http://docs.racket-lang.org/guide/qq.html). But I will try to point out Racketisms to save some Googling, and it’s always a good idea to [Learn X=Racket in Y Minutes](http://learnxinyminutes.com/docs/racket/).

## Take One. Basic and not-so-basic functionality.
In the `take1/` directory there are
- two input files: Pollen markup in `take1.html.pm` and an HTML template `template.html`,
- one helper file: the `tufte.css` file from Liepmann, and
- out output file: `take1.html` which is generated by running `raco pollen render take1.html`.


The reason you could forget about Markdown and the Pollen preprocessor is because these are small fry compared to real Pollen markup. Compare the Pollen markup input and its rendered output:

<img width="1482" alt="take1-screenshot" src="https://cloud.githubusercontent.com/assets/37649/9675781/2c032492-5290-11e5-9a88-68aacc828ab3.png">

In the Pollen markup file `take1/take1.html.pm`, we have some Racket function definitions starting with ◊, then a bunch of content. Wait, maybe I overstated the difference between Racket code versus content, because what’s the difference between
- ``◊(define (emphatic . xs) `(em ,@xs))``, and
- ``◊emphatic{italicize things}``? Or, worse,
- ``◊h1{Take One. Or, Let’s Try To Get the Basics.}``?

### Pollen text mode versus Racket mode: Pollen’s two syntaxes for calling functions
Here’s the first thing you need to know. There’s a **one-to-one equivalence** between 
- `◊foo[arg1 arg2]{final-arg}`, which [is called](http://pkg-build.racket-lang.org/doc/pollen/reader.html#%28part._.The_two_command_modes__text_mode___.Racket_mode%29) Pollen text mode, and 
- `◊(foo arg1 arg2 final-arg)` which is Racket mode.

Both call a Racket function `foo`. If the existence of this isomorphism strikes you as pretty freaking amazing, it should, and not just from a theoretical sense. It allows you to treat `foo` as a Racket function using the latter, and as an *equivalent* HTML tag with the former. 

### Pollen forgives undefined functions
The other thing you need to know is also awesome: **if Pollen finds you using functions-tags that you haven’t `define`d, it’ll treat them as plain HTML tags**. This is why `take1.html.pm` can call `◊h1{Take One …}` without anybody defining `h1` anywhere.

Put the two of these factoids together and you see why we can use `◊span` as 
- a Pollen tag via `◊span['((class "hidden") (id "id1"))]{my span}`, 
- **and** as a Racket function via `◊(span '((class "hidden") (id "id2")) "my other span")`, without explicitly defining `span`.

Of course you can see that, while they’re equivalent, in practice it’s easier to use one syntax in for some situations and the other for others, if only because you don’t need to quote text when you use `◊span{look ma, no quotes!}`.

### Explaining aforementioned usages
Now you can understand those three lines of code above.

``◊(define (emphatic . xs) `(em ,@xs))`` is written using Racket mode syntax, and defines a function called `emphatic` with all arguments rolled into a list called `xs` (just like `def foo(*args)` in Python or `varargin` in other languages), and which returns the input arguments list `xs` prepended with the symbol `em` using a bit of that [quasiquote](http://docs.racket-lang.org/guide/qq.html) magic the Lisp family is famed for.

We invoke this function using `◊emphatic{italicized text}`, and it renders as `<em>italicized text</em>`.

And as Pollen smartly passes through undefined functions as tags, ``◊h1{Take One. Or, Let’s Try To Get the Basics.}`` produces the appropriate `<h1>` tag.

Test your understanding: given this `linky` function,
```racket
◊(define (linky url . xs) `(a ((href ,url)) ,@xs))
```
what would
```racket
◊linky["http://github.com"]{slinky dress}
```
render as? You may need to refer to the documentation on [`unquote`](http://docs.racket-lang.org/guide/qq.html) again. Note how this sophomoric implementation prevents `linky` from being given additional attributes like `id` or `class`.

### Templates: packaging it into a tidy HTML file
So in the `take1/` directory, run
```
$ raco pollen render take1.html
```
Unlike other markup translators I’ve used, Pollen doesn’t write to stdout, and will overwrite `take1.html`. For now it can just be opened it in a browser (we’ll talk about webservers in a subsequent take). 

You may have noticed, even in the screenshot above, that there is some boilerplate in the rendered HTML that’s not in the origial Pollen markup, like `head` and `meta` tags. This comes from a template file, in our case called `take1/template.html`.

This template is also a Pollen file, despite lacking any Pollen-esque file extension. Note a couple of ◊s in it: the first one is just a bit of showing off—the contents of the first `<h1>` tag is grabbed via a Pollen function `select` and used to set the page’s `<title>`: `<title>◊select['h1 doc]</title>`. (In Racket mode, this would be `◊(select 'h1 doc)`.) The X-expr `doc` containing the abstract syntax tree (AST) of `take1.html.pm` is available when the template is rendered, which `select` can scan, à la `getElementsByTagName`. 

A bit later, inside a Tufte CSS-specific `<article>` tag, another Pollen function `->html` converts the AST to HTML. This function is clearly tightly intertwined with its target format, but it’s illuminating to see an alternative AST-to-output converter: 
```racket
◊(apply string-append (filter string? (flatten doc)))
```
After flattening the nested lists and throwing out tags and attributes, concatenate the strings that remain and you have a pretty good *plaintext* representation of `take1.html.pm`.

### Summary of Take One

The functionality demonstrated so far is pretty elementary. The Pollen syntax can seem peculiar, and one couldn’t be blamed for being uneasy with the thought of constantly dropping into Racket. Maybe worst of all is we don’t have any easy way to *italicize* text like Markdown.

But I am already awestruck by the vistas of flexibility Pollen’s approach reveals. Having your document and your template be fully-programmable in the same language dramatically lowers the activation energy for complex document workflows. 

The classic gripe of technical writers with Markdown—its lack of footnotes—can readily be fixed by a couple of quick Racket functions: you could write your paper in Markdown, use Pollen annotations just for the footnotes, and output another Markdown file with footnotes all fancy. But I’d argue that Markdown offers precious little besides single-character markup compared to Pollen markup, hence my advice to throw oneself whole-heartedly on Pollen markup.

In the next take, we’ll see how to make Tufte CSS sidenotes and get proper paragraph tags, two much more cognitively burdensome tasks.


## Take Two. Things are harder than they appear.

Now consider the contents of the `take2/` directory. Again we have a Pollen markup file, a template, the Tufte CSS `.css` file, and the rendered HTML. Re-render the last with
```
$ raco pollen render take2.html
```

### Sidenote sausage
As mentioned above, [Tufte CSS](http://www.daveliepmann.com/tufte-css/) has nice sidenotes. But a sidenote isn’t a single tag. Here’s how the sidenote sausage is made:
```html
Flowing text.
<label for="LABEL" class="margin-toggle sidenote-number"></label>
<input id="LABEL" class="margin-toggle" type="checkbox"></input>
<span class="sidenote">SIDENOTE CONTENT</span>
More flowing text.
```
We’d like to get this from just
```
Flowing text.◊sidenote["LABEL"]{SIDENOTE CONTENT} More flowing text.
```
The Pollen magic from the first take doesn’t help here. At best we could squeeze all three of these tags into a single `<sidenote>` tag, which browsers could probably handle just fine. But can we find something more elegant, to just place three adjacent tags in the flow of the parent tag?

Matthew Butterick’s [source code](http://unitscale.com/mb/technique/pollen.rkt.html) to [Making a dual typed / untyped Racket library](http://unitscale.com/mb/technique/dual-typed-untyped-library.html) shows us how to do this. It defines a `splice` Racket function and includes a test for it, and here’s my version of it:
```racket
(define (splice xs)
  (apply append (for/list ([x (in-list xs)])
                  (if (and (txexpr? x) (member (get-tag x) '(splice-me)))
                      (get-elements x)
                      (list x)))))

(splice '(p "foo" (splice-me "bar") "zam")) ; should be equal to '(p "foo" "bar" "zam")
```
All this is worth puzzling over for a bit. As I make it out, `splice` searches the contents of an X-expr (which is a list, and without recursing into any nested sublist child-tags), looking for a child tag called `splice-me`. When it finds one, it replaces the child tag with its contents. So an input representing `<p>foo <splice-me>bar</splice-me> zam</p>` becomes `<p>foo bar zam</p>`. That `txexpr` and `get-tag` stuff is for dealing with the specifics of X-exprs (which *are* lists, i.e., S-exprs, but with extra pixie dust on top).

So if instead of enclosing the `label`, `input`, and `span` tags inside a `<sidenote>` tag like I bemoaned doing a minute ago, enclose them in a `<splice-me>` tag, and ask Racket to run `splice` on every sub-X-expr in the document.

Pollen has a neat way of doing this. It’s related to something I forgot to point out about the rendered HTML in Take One, that Pollen markup is enclosed in a `<root>` tag by Pollen convention. So define a `root` Racket function:
```racket
(define (root . xs)
  (decode `(decoded-root ,@xs) #:txexpr-elements-proc splice))
```
[`decode`](http://pkg-build.racket-lang.org/doc/pollen/Decode.html) looks like a pretty powerful function that can operate on X-exprs—any X-exprs, including subsets of the `doc` AST (and the `#:` syntax is Racket for keyword arguments). Here, `decode` is used to apply `splice` to every child node of `<root>`, that is, the entire document, and put the results in a new tag, `<decoded-root>`.

So now, instead of the contents of the Pollen markup going in a `<root>` tag, they’ll be in `<decoded-root>`. Any `<splice-me>` tag will have its contents spliced into its parent tag. 

Sidenote sausage cooked.

You are appalled that one had to write so much Racket to do something that one would think was a pretty common task—replacing one tag with mutliple adjacent ones. Why does Pollen give us any simpler way to do this? But that’s the point of having a fully-programmable document. Unix doesn’t have a command line utility to do every task, but the Unix philosophy of small tools that do one thing well and can be chained means it doesn’t have to. C doesn’t give you hash tables or linked lists: it gives you the tools to write them yourself. XML doesn’t specify every conceivable semantic tag: it embraces extensibility. The discomfort felt at performing surgery on your document’s complete AST soon evaporates into relief—and perhaps joy—at being able to surgically modify your document’s AST.

### There are no newlines under the sun
One very nagging thing about the Pollen renders so far is that newlines are passed through, and that you immediately noticed when you looked at `take1.html` in a browser—it looked weird because it lacked `<p>` paragraph tags, and it was basically a single run-on paragraph.

Dealing with `<br>` and `<p>` tags, line breaks and paragraph tags, is thankfully something that you don’t have to write yourself, as Pollen comes with some [fancy functionality](http://pkg-build.racket-lang.org/doc/pollen/Decode.html#%28def._%28%28lib._pollen%2Fdecode..rkt%29._detect-paragraphs%29%29) to handle this. `detect-paragraphs` is pretty feature-rich, but to get the job done for `take2.html`, its default functionality is entirely sufficient.

It is similar to `splice`, discussed a second ago, in that it scans an X-expr without recursing and converts newlines to `<p>` and `<br>` tags appropriately. So like `splice`, we can ask `decode` to run `detect-paragraphs` on each sub-X-expr while it’s running `splice`. Here’s the expanded call to `root`:
```racket
◊(define (root . xs)
  (decode `(decoded-root ,@xs)
          #:txexpr-elements-proc (compose1 detect-paragraphs splice)
          #:exclude-tags '(pre)
          ))
```
Note that the `#:txexpr-elements-proc` keyword argument to `decode` must be a single function, not a list, but we happen to be using a functional programming language here. `(compose1 detect-paragraphs splice)` returns a single function that will apply `splice` first, then `detect-paragraphs`.

And what about that `#:exclude-tags` keyword argument? We don’t want to convert newlines in `<pre>` tags, and Pollen has thoughtfully given this high-level mechanism to prevent those from being decoded.

It may be a good exercise to figure out how to run `splice` on `pre` tags but not `detect-paragraphs`: `detect`’s high-level customizations might not be sufficient for this and one may have to write a couple of lines of Racket.

### Summary of Take Two

This take is titled "things that are harder than they appear", but having seen what it takes to splice a tag’s children into its parent, I completely appreciate how Racket’s power can make mincemeat out of complex tasks once one understands the underlying data structures—and how Pollen dramatically reduces the activation energy to whipping up some Racket code.

Then we saw that there are other things which Pollen has thought about and provides out-of-the-box solutions, like newline detection, smart punctuation (which I haven’t demonstrated here), etc. Yet even thees are steeped in the Racket ethos, and are hugely programmable.

In the next and last (planned) take, we’ll set up some infrastructure to make Pollen authoring even easier. We’ll set up a custom Nginx webserver that lets the HTML page auto-refresh whenever the Pollen markup is saved.

## Take Three, where we get all steampunk
So far, my Pollen workflow has been edit–save–compile–refresh, switching between a text editor (gvim), command line, and browser. This is tiring and here’s how I chose to streamline this.

First, I install [Node.js](https://nodejs.org), a popular cross-platform JavaScript runtime with a very large ecosystem, and run a ~100-line JavaScript program which starts a webserver and watches a single Pollen markup file for changes. When I save that file, Node calls `raco` to re-render the HTML and sends a server-sent event to any browser viewing the rendered HTML, telling it to refresh the page.

The HTML page is aware of server-sent events because of some JavaScript we embed in it, and JavaScript is also how it refreshes itself when it gets the command to do so. This is very handy while authoring, but such infrastructure code should be removed before uploading to a public webserver for general viewing. So the last thing we’ll do is make our Pollen markup aware of our desire to make a testing versus production version of the output using an environment variable. Our `template.html`, which contains HTML boilerplate, will check for a `POLLEN` environment variable, and include refresh logic only when in testing mode, otherwise leaving it out. This is the only Pollen-specific part of this take and is a snap given how much we know about Pollen now.

**Aside** I personally use Nginx with this [HTTP push stream module](https://github.com/wandenberg/nginx-push-stream-module), because Nginx is far more performant than Node when it comes to serving big webpages loading images, JavaScript libraries, JSON datasets, MathJax, etc. There’s also a lot less custom code—none, really. But Nginx doesn’t work (well) on Windows, and one has to compile it from scratch to get the HTTP push stream module (which abstracts server-sent events, WebSockets, etc.). Rather than force readers of this poor guide to front this high NRE, I made Node.js alternative. And I chose Node because of my own familiarity and its cross-platform support. It should possible to do all this in Racket.

### Setup and use

**Step 0** As a preliminary step, in the `take3/` directory, render the Pollen markup file:
```
$ POLLEN=TESTING raco pollen render take3.html
```
You could even read the input or output files, if you like. I note in passing that I’ve moved all Racket code out of the Pollen markup file into a `take3/pollen.rkt` Racket file, which Pollen loads as a module.

**Step 1** As a first step, download and install [Node.js](https://nodejs.org). Works on Mac, Linux, and Windows, ARM and x86, the lot.

**Step 2** Second, in the `take3/` directory in a terminal, run
```
$ npm install
```
`npm` is the package manager for Node. It looks at `take3/package.json` and installs a handful of dependencies in the `take3/node_modules` directory.

> **Step 2.5** If you are using Internet Explorer, Edge, Opera Mini, or any browser that doesn’t support EventServer (full list of unsupporting browsers at [Can I Use](http://caniuse.com/#feat=eventsource)), copy the `node_modules/event-source-polyfill/eventsource.min.js` shim to the `take3/public` folder:
```
cp node_modules/event-source-polyfill/eventsource.min.js public/
```

**Step 3** Third, run
```
$ node server take3.html.pm "POLLEN=TESTING raco pollen render take3.html"
```
This starts the Node application, including a webserver and a file watch on the `take3.html.pm` Pollen markup file. That string `"POLLEN=TESTING raco …"` is what will be executed when changes to `take3.html.pm` are detected.

**Step 4** Next, visit [http://localhost:3000/take3.html](http://localhost:3000/take3.html) to view the rendered HTML being served by the Express.js webserver in Node.

**Step 5** For my final trick, I position my browser so that I can see it and my text editor at the same time. I edit the `take3.html.pm` Pollen markup file and save it. In a second or three, the browser refreshes in same place, showing my changes.

***Hurrah!***

N.B. Fastidious readers may notice two browser refreshes for a single save. The [file watching API](https://nodejs.org/docs/latest/api/fs.html#fs_fs_watch_filename_options_listener) in Node (and anywhere else) is a little persnickety and may choose to detect two changes, one immediately after another, when the file changed only a single time.

### Rendering for production environments

I don’t want to get into the details of how server-sent events and their client-side counterpart, the EventSource API, are used here. The details are all in `take3/server.js` and in `take3/template.html`. Hopefully you can change the arguments to `node server.js` to work for different projects, without coding.

But do note that this auto-refresh trick works because of custom JavaScript embedded in `template.html`. We don’t want this code to be present when we publish a Pollen document for a production environment. It likely won’t cause any harm but really should be omitted if it’s not needed.

For this reason, `template.html` checks to see if a `POLLEN` environment variable is available. One can set this by prefixing the variable to raco command:  `POLLEN=TESTING raco …`. The template assumes that, if this environment varialbe is defined, Pollen is being run in a testing environment—it doesn’t care what the actual contents of the string are.

And if the template decides it is in a testing environment, it will include a couple of `<script>` tags in the HTML header which load the JavaScript that facilitates the auto-refresh feature. If no `POLLEN` environment variable is defined, these scripts are omitted.

This is classic Pollen:
```racket
◊(if (getenv "POLLEN") "
<script src='/public/eventsource.min.js'></script>
<!-- ... ... ... -->
" "")
```
We use Racket’s `if`, and choose to embed either a multi-line string containing HTML and JavaScript code, or an empty string. Happily, HTML and JavaScript can use single- and double-quotes just as easily, so I had to do no escaping of quotes in the `if` form! I can copy-and-paste HTML/JavaScript from non-Pollen sources without any problems. If I insisted on using double-quote, though, I would have had to escape them within the multiline quote.

When rendering for production, simply omit the `POLLEN=TESTING` environment variable and the resulting HTML file will not mention refresh events: simply run `$ raco pollen render take3.html` and upload the resulting file to your web host.

> **A technical note on `server.js`** The Node server sends browsers a message not only when it detects a file change, but also if it receives a POST request on `/events/ID` for some string `ID`—in this case, the Node server forwards the POST message to the browser. Therefore, one could have the server send a request to refresh via the following command in a terminal:
```
$ curl -f -s -X POST http://localhost:3000/events/refreshme -d 'change'
```
> Note how the ID of the event (or channel) is `refreshme` and the message is `change`, which is the same channel and message that the browsers are looking for. If instead of `-d 'change'` one had `-d 'hi'`, one would see `hi` in the browser JavaScript console. This provides another useful way to communicate from your shell to the browser. A script that combines Pollen rendering and POSTing a refresh request to the server (to forward to browsers) is included in the `take3/testing.sh` script.

### Summary of Take 3

In this last take of this poor guide to Pollen, we were able to use Racket’s multiline string support to effortlessly embed HTML and JavaScript in a document’s rendered output based on if/then logic.

But this take really focused on infrastructure to make the Pollen authoring process smoother. We cobbled together some JavaScript, script kiddie style, to watch a file for changes, rerun the Pollen renderer when changes were detected, and use server-sent events and the EventSource web technologies to communicate to the browser to refresh the page, getting the latest content.

## Epilogue

The first take of this poor guide revisited the basic features of Pollen that one needs to know to start being productive in it. The second looked in-depth into one situation where one needed a bit of common Racket to achieve some pedestrian results. The third and final take set up some infrastructure to auto-refresh a document in a browser when it was saved.

By the end of this guide, I hope you are comfortable writing Pollen documents and confident in Pollen’s ability to transform its markup into any HTML you want. And by extension, any other format too.

Using Pollen markup has been much more liberating than using Markdown with custom Pandoc writers written in Lua because, although Pandoc does give custom writers an AST, it is not as flexible as having the full X-exprs. Although it looks a bit more “pointy” than Markdown, I think the benefits of Pollen markup far make up for it.

