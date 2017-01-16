
** NOTES ON BLOCK **

"Block" is a stream of text defined by a Start mark and an End
mark in a buffer. A Block can be copied, moved and deleted in
its buffer as a stream or rectangular piece of text. Also,
when defined, it is copied in global variable "wm-stream" as
normal text and also in global variable "wm-rect" as a
rectangular block of text. So the last Block defined in some
buffer is "global", and it can be copied in every buffer.

Because Start and End of Block are local to buffers, every
buffer can have its own Block and so more than one Block can
be defined at the same time in different buffers (one per
buffer). Only the last defined is "global": for a Block
defined before the last one in another buffer is possible to
became the global one by "activating" it, practically moving
in its buffer and doing a command it can be copied in global
variables replacing the last Block defined. A block can also
be highlighted by a command using a face, (named "blockface").

More: 10 registers from 0 to 9 are defined for using with
blocks. It's possible to copy block into them (rect or stream) or
append to them (only stream): registers are global and are normal
emacs registers from 0 to 9. So registers can be used for
accumulate text and copy through buffers.


** NOTES ON PRINTING **

You can use WorMstar for printing in raw mode: text is printed
without any formatting apart the one that you apply directly
by wrapping, justifing, right margin ecc. Also in RAW mode
lines beginning with 2 dots are discarded from printing, they
are considered comments. For deleting these lines Wormstar
uses an external program, sed (I know this is not a good
choice but it does well the dirty work and sed is ubiquitary
on unix, and perhaps it's faster than an elisp function...)
There are some commands to do a not so bad formatting work for
raw printing: you can choose column of wordwrapping and also a
left margin if you want. You can choose also to right justify
lines, but I think this is not a good idea if you print with
fixed font. There also commands for center lines, paragraph
and block: all they are centered by lines not like a single
object.

Another mode for printing is by using the postscript function
of emacs: text is printed with an header and page number (all
customizable by ps-* variables of emacs). This printing is raw
text in postscript form: formatting is the one you directly
apply to ascii text.

WARNING: If you use my wmrc file to customize your WorMstar you have
to do some changes in ps-* variables to adapt them for your emacs
version and ps-print package.

It's better to print raw or emacs postscript from the
"preview" buffer: in this one there are no comment lines that
can mess up things up with raw formatting. You can select as a
block all buffer an fill it (it's a readonly buffer but you
can change situation with a command: ^O^O)

Third and more powerful tool for printing is "filter" mode.
With a command you can define an external program and switches
to filter buffer (or block) through: it works well with *roff
family but I think it can work well with LaTeX too or Lout.
Also in this mode, like raw and postscript, lines beginning with
2 dots are deleted before printing. I think this is a good
choice because you can write your raw text first with your
line comments ("two dots" lines like in original Wordstar) and
then decide to use markup commands for formatting without
change those lines.

