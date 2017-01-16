WORMSTAR: reborn?
=================

I put here my very old elisp script for an improved
wordstar-like mode for emacs. It was written 14/15 years ago.
My hope is that someone forks it and hacks it for new emacs
versions. It was good tested only on old versions of GNU emacs,
19.34 in particular. I think the part that needs more hacking
is the *printing* one. Personally now I use emacs very rarely.

From here on the original *README* file...

WM-MODE: a new (old) WordStar mode for GNU-emacs
------------------------------------------------

I'm obsessed by WordStar(R) and I don't know why.

To try to cure myself I've written a new WordStar mode for
emacs: its name is **WorMstar** (because WordStar is like a
worm in my head...) and the elisp file that contains it is
named `wm-mode.el`.

I'm an occasional elisp programmer so that's all at your risk!

It is an  improvement of the old WordStar mode but without that
WorMstar wouldn't be.

Main characteristics of WorMstar (from now on only "wm"...) are:

 *	Keybindings WordStar like (of course...) with little adjustements
	for new commands and functions
 *	Windowing system: split window, go next/prev window,
	enlarge/shrink etc.
 *	10 marks per buffer (set mark & goto mark)
 *	Implementation of emacs bookmarks (permanents through
	sessions).
 *	Dired editing like in emacs.
 *	One block per buffer
 *	One "global" block (the last defined or the last "activated")
	shared by all buffers
 *	Block highlighting using a face (only in X)
 *	Rectangular operations on block (local or global)
 *	Filtering of block/buffer through an external command
 *	10 global registers a la emacs shared by all buffers (you
	can copy text to/from registers and also append to them)
 *	3 ways of printing: raw printing and ps printing using emacs
	commands, and a "filter" printing using an external command
	(defaults to "nroff -ms").
 *	you can choose and change the filter during working sessions
 *	Possibility to prevent printing of lines beginning with "..":
  those are comment lines like in original WordStar (if you
  write a file for nroff or lout or Latex you can use ".." like
  beginning of comment line because wm hides those lines before
  pass buffer to the filter).
 *	Raw printing preview (if filter for printing can make an
  ascii aproximation of printing itself - like nroff or "lout -p":
  but you can also "preview" a postscript file generated for ex.
  by groff...)
 *	Indicators on mode-line for:
	-	Wordwrap on/off
	-	Rectangular operations on block
	-	Justify on/off
	-	Case searching on/off
	-	Mode of printing: R (raw); P (postscript); F (filter).

This is the left part of modeline:

~~~
---- <R>
||||  |-> R or F or P if Raw or Filter or Postscript printing
||||-> C if search is Case sensitive
|||-> J if is on right Justification of text
||-> C if operation on block are done by Columns (rectangular)
|-> W if Wordwrap is on
~~~

How to use it
-------------

Put the file wm-mode.el in the path of your elisp files and
add in your .emacs file the line:

`(autoload 'wormstar "wm-mode" "WorMstar mode" t)`

In any moment you can start wm mode by typing the command:
wormstar

My preferred way to use WorMstar is by using an old emacs
version (19.34) with an apposite init file to customize it,
a file that I called .wmrc and put in my home. So I have a
real different program...

The command for this joy is:

`emacs19 -q -l ~/.wmrc`

and you can alias it in your shell init file.

You can find here my wmrc file.

Bugs
----

First: wm-mode is good tested on the old GNU-emacs version, my
all-time preferred: 19.34. I think it runs well on new versions but I
did not control if some elisp packages, ex. for ps printing,
are massive changed.
It is not tested with Xemacs (I don't like Xemacs. Stop. :-).

Sometimes the face for highlighting block in X mess the things
up: if you see something strange in colors on your screen you
can do a command, wm-refontify (C-k,) that solve your problems
(I hope... .-)

WorMstar change keybindings globally so it can conflict with other
modes that use emacs-like bindings. This is a choice and not a bug
because I like a *new* editor and not only a "mode" and I use
it without any other mode.  Anyway something strange can sometimes
happen but not for usual keybindings in minibuffer.

WM uses an external program to filter lines of comments
beginning with dots before printing: that program is `sed` of
course. This choice is not an ideal one but it works well and
sed is quick...


