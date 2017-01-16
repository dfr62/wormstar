;;
;;  >>  THIS IS A VERSION OF WM-MODE THAT CHANGES *GLOBALLY* THE KEYMAP
;;  >>  IT CAN BE USED IN PLACE OF OLD WM-MODE
;;
;; $Id: wm-mode.el,v 1.1 2009/11/11 22:49:59 dan4u Exp $
;;
;;
;;   "wm-mode.el" A new WordStar(R) mode for GNU-emacs
;;   Copyright (C) 2003 Daniele Furlan jbuss@kaosmic.net
;;
;;   This program is free software; you can redistribute it and/or modify
;;   it under the terms of the GNU General Public License as published by
;;   the Free Software Foundation; either version 2 of the License, or
;;   (at your option) any later version.
;;
;;   This program is distributed in the hope that it will be useful,
;;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;   GNU General Public License for more details.
;;
;;   You should have received a copy of the GNU General Public License
;;   along with this program; if not, write to the Free Software
;;   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;;
;;
;;
;;
;          ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; CUSTOMIZABLE ;;;;;;;;;;;;;;;;;;;;
;          ;;;;;;;;;;;;;;;;;;;;

;; In this section are variables that you can customize in your
;; $HOME/.wmrc file

;; standard command for unix printing
(setq lpr-command "lpr")

;; options for raw printing
(setq lpr-switches '("-Praw"))

;;
;;;;; The next ones you can change also in WorMstar while editing ;;;;;;
;;

;; I use the next one as a "filter" for printing (emacs default is
;; "pr" but I set it to "nroff").  Hack: it's possible to set it to a
;; pipe like sed 'something' | program or similar (also a shell script
;; of course)
(setq lpr-page-header-program "nroff")

;; The next one if for switches to filter - I set "-ms" default
;; You should change it to -me or -mm -mom or what you like
(setq lpr-page-header-switches "-ms")

;; right column for wrapping
(if (null fill-column)
    (set-fill-column 0))

;; left column for wrapping
(if (null left-margin)
    (setq left-margin 0))

;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;;
;;                Now CODE begins...
;;
;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;;
;;           DON'T CHANGE IF NOT SURE...
;;
;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;

;; a syntax-table
(defvar wm-mode-syntax-table nil
  "Syntax table used in WorMstar.")

;; we define a syntax table that is like text-mode plus the comments
;; lines beginning with "."
(if wm-mode-syntax-table
    ()
  (setq wm-mode-syntax-table (make-syntax-table))
  (modify-syntax-entry ?\" "." wm-mode-syntax-table)
  (modify-syntax-entry ?\\ "." wm-mode-syntax-table)
  (modify-syntax-entry ?\. "<" wm-mode-syntax-table)
  (modify-syntax-entry ?\n ">   " wm-mode-syntax-table)
  (modify-syntax-entry ?\f ">   " wm-mode-syntax-table))


;; variable containing the  help text
(defvar wm-help-text nil "Contains the help text.")

;; variables for mode-line
(defvar wm-ml-block "-" "C if Column block operations, B if stream.")
(defvar wm-ml-wrap "-" "W if wordwrap ON.")
(defvar wm-ml-just "-" "J if justification is ON.")
(defvar wm-ml-case "-" "C if not ignoring case in search/replace.")

;; Make these vars buffer-local
(make-variable-buffer-local 'wm-ml-block)
(make-variable-buffer-local 'wm-ml-wrap)
(make-variable-buffer-local 'wm-ml-just)
(make-variable-buffer-local 'wm-ml-case)

;; this is used for mode-line and also to set the mode for printing
;; we don't make buffer-local this var (a choice... ;-)
(defvar wm-ml-print "R"
  "R for raw printing, P for emacs-Postscript, F for custom Filter")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; variables for printing (except the first, all are standard emacs
;; variables)
(defvar wm-print-buffer (concat "<P " (buffer-name) " P>")
"Standard name of buffer for printing preview.")

;; This one buffer-local
(make-variable-buffer-local 'wm-print-buffer)

(defvar wm-print-filter nil "The command for filter printing.")

;; and now we make the filter using printing variables
(setq wm-print-filter (concat lpr-page-header-program " "
			      lpr-page-header-switches " | "
			      lpr-command))

;; NB: for ps-printing using emacs functions see the docs for,
;; example, ps-print-buffer and ps-print-region (and, of course, al
;; the other ps-* function and variables)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; variables for Block
(defvar wm-block-mark-start nil "Start of block.")
(defvar wm-block-mark-end nil "End of block.")

(defvar wm-block-is nil "If T block is set.")
(defvar wm-block-rect nil "If T rectangular block operations.")
(defvar wm-block-show nil "If T block is showed in blockface face.")

;; We make these vars buffer-local
(make-variable-buffer-local 'wm-block-mark-start)
(make-variable-buffer-local 'wm-block-mark-end)

(make-variable-buffer-local 'wm-block-is)
(make-variable-buffer-local 'wm-block-rect)
(make-variable-buffer-local 'wm-block-show)

;; Block variables "Global": they contain the last defined Block as
;; stream of lines and rectangle
(defvar wm-stream nil "Contains last defined Block. Stream.")
(defvar wm-rect nil "Contains last defined Block. Rectangle.")


;; boolean variables for editing
(defvar wm-wordwrap nil "If T wordwrap is on.")
(defvar wm-justify nil "If T filling paragraph justify as well.")
(defvar wm-search-string nil "String of last search in WR mode.")
(defvar wm-search-direction t 
  "Direction of last search in WR mode. T if forward, NIL if backward.")
(defvar wm-search-start nil "Position before last search o replace.")

;; these too buffer-local
(make-variable-buffer-local 'wm-wordwrap)
(make-variable-buffer-local 'wm-justify)
(make-variable-buffer-local 'wm-search-string)
(make-variable-buffer-local 'wm-search-direction)
(make-variable-buffer-local 'wm-search-start)

;; mark points variables (10)
(defvar wm-mark-0 nil "Position of mark 0")
(defvar wm-mark-1 nil "Position of mark 1")
(defvar wm-mark-2 nil "Position of mark 2")
(defvar wm-mark-3 nil "Position of mark 3")
(defvar wm-mark-4 nil "Position of mark 4")
(defvar wm-mark-5 nil "Position of mark 5")
(defvar wm-mark-6 nil "Position of mark 6")
(defvar wm-mark-7 nil "Position of mark 7")
(defvar wm-mark-8 nil "Position of mark 8")
(defvar wm-mark-9 nil "Position of mark 9")

;; set buffer-local the mark points
(make-variable-buffer-local 'wm-mark-0)
(make-variable-buffer-local 'wm-mark-1)
(make-variable-buffer-local 'wm-mark-2)
(make-variable-buffer-local 'wm-mark-3)
(make-variable-buffer-local 'wm-mark-4)
(make-variable-buffer-local 'wm-mark-5)
(make-variable-buffer-local 'wm-mark-6)
(make-variable-buffer-local 'wm-mark-7)
(make-variable-buffer-local 'wm-mark-8)
(make-variable-buffer-local 'wm-mark-9)

;; and now the help text string in wm-help-text (actually only the
;; keybindings)
(setq wm-help-text
      "Standard Keybindings for WorMstar.
Not yet implemented.
See the wm_kbindings file in wm-mode.el package.")


;;;;;;;;;;;;;;; GENERAL FUNCTIONS ;;;;;;;;;;;;;;;;;


(defun wormstar ()
  "A new wordstarish mode for emacs..."
  (interactive)
  (kill-all-local-variables)
;;  (use-local-map wm-mode-map)
  (setq mode-name "WorMstar")
  (setq major-mode 'wm-mode)
  (set-syntax-table wm-mode-syntax-table)
;; we define the string "." as comment start
  (make-local-variable 'comment-start)
  (make-local-variable 'comment-end)
  (make-local-variable 'comment-start-skip)
  (make-local-variable 'paragraph-separate)
;; We match "dot" lines for nroff/groff
  (setq comment-start "\\.")
  (setq comment-end "")
;; We try to match also nroff commands beginning with dot
  (setq comment-start-skip "\\.[.\\]*[\"]*[\t ]*")
  (setq paragraph-separate "[ \n\t\f]*$\\|[ \t]*\\..*\n.*")
  (setq paragraph-start "[ \n\t\f]\\|[ \t]*\\..*\n.*")
  (wm-custom))
	
(defun wm-custom ()
  "Customize mode-line in wm-mode"
;; some customization of modeline
  (setq frame-title-format "WorMstar"
	mode-line-modified '("-%1*%1+-")
	mode-line-buffer-identification '(" WorM: %12b")
;; this define modeline with new variables
	mode-line-format (cons
			  '(" " wm-ml-wrap wm-ml-block
			    wm-ml-just wm-ml-case " <" wm-ml-print "> ")
			  mode-line-format)))


(defun wm-help-me ()
  "Show Help: keybindings."
  (interactive)
  (switch-to-buffer-other-window "*WorM-Help*")
  (if (> (buffer-size) 1)
      ()
    (insert wm-help-text)
    (goto-char (point-min))
    (toggle-read-only 1)))


;;;;;;;;;;;;;;;;;;;; MARKS FUNCTIONS ;;;;;;;;;;;;;;;;;;

(defun wm-set-mark-0 ()
  "Set mark 0 to current cursor position."
  (interactive)
  (setq wm-mark-0 (point-marker))
  (message "Mark 0 set"))

(defun wm-set-mark-1 ()
  "Set mark 1 to current cursor position."
  (interactive)
  (setq wm-mark-1 (point-marker))
  (message "Mark 1 set"))

(defun wm-set-mark-2 ()
  "Set mark 2 to current cursor position."
  (interactive)
  (setq wm-mark-2 (point-marker))
  (message "Mark 2 set"))

(defun wm-set-mark-3 ()
  "Set mark 3 to current cursor position."
  (interactive)
  (setq wm-mark-3 (point-marker))
  (message "Mark 3 set"))

(defun wm-set-mark-4 ()
  "Set mark 4 to current cursor position."
  (interactive)
  (setq wm-mark-4 (point-marker))
  (message "Mark 4 set"))

(defun wm-set-mark-5 ()
  "Set mark 5 to current cursor position."
  (interactive)
  (setq wm-mark-5 (point-marker))
  (message "Mark 5 set"))

(defun wm-set-mark-6 ()
  "Set mark 6 to current cursor position."
  (interactive)
  (setq wm-mark-6 (point-marker))
  (message "Mark 6 set"))

(defun wm-set-mark-7 ()
  "Set mark 7 to current cursor position."
  (interactive)
  (setq wm-mark-7 (point-marker))
  (message "Mark 7 set"))

(defun wm-set-mark-8 ()
  "Set mark 8 to current cursor position."
  (interactive)
  (setq wm-mark-8 (point-marker))
  (message "Mark 8 set"))

(defun wm-set-mark-9 ()
  "Set mark 9 to current cursor position."
  (interactive)
  (setq wm-mark-9 (point-marker))
  (message "Mark 9 set"))


;          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; MOVEMENT & WINDOW FUNCTIONS ;;;;;;;;;;;;;;;
;          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun wm-jump-ring (&optional arg)
  "Jump at previous position using emacs mark-ring.
If argument uses global mark ring through buffers."
  (interactive "P")
  (if (null arg)
      (set-mark-command 1)
    (pop-global-mark)))

(defun wm-continuous-down (num)
  "Scroll one line down. With arg scroll arg lines."
  (interactive "p")
  (scroll-down num))

(defun wm-continuous-up (num)
  "Scroll one line up. With arg scroll arg lines."
  (interactive "p")
  (scroll-up num))

(defun wm-scroll-up-line (num)
  "Scroll text continuously Up."
  (interactive "p")
    (scroll-up num)
    (forward-line num))

(defun wm-scroll-down-line (num)
  "Scroll text continuously Down."
  (interactive "p")
    (scroll-down num)
    (forward-line (- num)))

(defun wm-point-top (&optional arg)
  "Line at point to top of screen. With arg point to top."
  (interactive "P")
  (if arg
      (let ((column (current-column)))
      (move-to-window-line 0)
      (move-to-column column))
    (recenter 0)))

(defun wm-point-bottom (&optional arg)
  "Line at point to bottom of screen. With arg point at bottom."
  (interactive "P")
  (if arg
      (let ((column (current-column)))
      (move-to-window-line -1)
      (move-to-column column))
    (recenter -1)))

(defun wm-point-center (&optional arg)
  "Line at point to middle of screen. With arg point at middle."
  (interactive "P")
  (if arg
    (let ((column (current-column)))
      (move-to-window-line (/ (window-height) 2))
      (move-to-column column))
    (recenter)))

(defun wm-forward-paragraph (&optional arg)
  "Forward to START of next paragraph. With arg forward arg paragraphs."
  (interactive "p")
;; we use a little hack...
  (forward-paragraph (* arg 2))
  (backward-paragraph (* arg 1)))

;;;;;;;;;; SEARCH/REPLACE FUNCTIONS ;;;;;;;;;;

;; We use this function for search: no "forward/backward" mechanism!
;; You can search backwards with prefix argument (^U)

(defun wm-search-2 (&optional arg)
  "Search regexp string, remember string for repetition.
With argument search backwards"
  (interactive "P")
;; Remember starting place in local var & string to search
  (let ((string (read-from-minibuffer "String or regexp to search: ")))
    (setq wm-search-start (point-marker)
	  wm-search-string string)
    (if (null arg)
	(progn
	  (message "Searching forward...")
	  (setq wm-search-direction t)
	  (search-forward-regexp string))
      (message "Searching backward...")
      (setq wm-search-direction nil)
      (search-backward-regexp string))))

(defun wm-repeat-search (&optional arg)
  "Repeat last search using regexp string from search or search/replace.
With arg inverts direction of search."
  (interactive "P")
  (if arg
      (setq wm-search-direction (not wm-search-direction)))
  (if wm-search-string
      (if wm-search-direction
	  (progn
	    (message "Searching forward...")
	    (search-forward-regexp wm-search-string))
	(message "Searching backward...")
	(search-backward-regexp wm-search-string))
    (error "No string to repeat search")))


(defun wm-query-replace (old new)
  "Search regexp string, remember string for repetition."
  (interactive "sReplace_regexp: \nsWith: " )
  (setq wm-search-start (point-marker)
	wm-search-string old
	wm-search-direction t)
  (query-replace-regexp old new))


(defun wm-goto-search-start ()
  "Goto start position of last search or replace."
  (interactive)
  (if (null wm-search-start)
      (error "No place to go")
    (push-mark)
    (goto-char wm-search-start)))


;;;;;;;;;; TO MARKS ;;;;;;;;;;


(defun wm-goto-mark-0 ()
  "Go to mark 0."
  (interactive)
  (if wm-mark-0
      (progn
	(push-mark)
	(goto-char wm-mark-0))
    (error "Mark 0 not set")))

(defun wm-goto-mark-1 ()
  "Go to mark 1."
  (interactive)
  (if wm-mark-1
      (progn
	(push-mark)
	(goto-char wm-mark-1))
    (error "Mark 1 not set")))

(defun wm-goto-mark-2 ()
  "Go to mark 2."
  (interactive)
  (if wm-mark-2
      (progn
	(push-mark)
	(goto-char wm-mark-2))
    (error "Mark 2 not set")))

(defun wm-goto-mark-3 ()
  "Go to mark 3."
  (interactive)
  (if wm-mark-3
      (progn
	(push-mark)
	(goto-char wm-mark-3))
    (error "Mark 3 not set")))

(defun wm-goto-mark-4 ()
  "Go to mark 4."
  (interactive)
  (if wm-mark-4
      (progn
	(push-mark)
	(goto-char wm-mark-4))
    (error "Mark 4 not set")))

(defun wm-goto-mark-5 ()
  "Go to mark 5."
  (interactive)
  (if wm-mark-5
      (progn
	(push-mark)
	(goto-char wm-mark-5))
    (error "Mark 5 not set")))

(defun wm-goto-mark-6 ()
  "Go to mark 6."
  (interactive)
  (if wm-mark-6
      (progn
	(push-mark)
	(goto-char wm-mark-6))
    (error "Mark 6 not set")))

(defun wm-goto-mark-7 ()
  "Go to mark 7."
  (interactive)
  (if wm-mark-7
      (progn
	(push-mark)
	(goto-char wm-mark-7))
    (error "Mark 7 not set")))

(defun wm-goto-mark-8 ()
  "Go to mark 8."
  (interactive)
  (if wm-mark-8
      (progn
	(push-mark)
	(goto-char wm-mark-8))
    (error "Mark 8 not set")))

(defun wm-goto-mark-9 ()
  "Go to mark 9."
  (interactive)
  (if wm-mark-9
      (progn
	(push-mark)
	(goto-char wm-mark-9))
    (error "Mark 9 not set")))



;;;;;;;;;;;;;;; WINDOW FUNCS ;;;;;;;;;;;;;;;


(defun wm-next-window ()
  "Go to next window (down or right)."
  (interactive)
  (other-window 1))

(defun wm-prev-window ()
  "Go to prev window (up or left)."
  (interactive)
  (other-window -1))


;          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; BLOCK FUNCTIONS ;;;;;;;;;;;;;;;;;;;;
;          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; How "Block" is used...
;;
;; "Block" is a stream of text defined by a Start mark and an End
;; mark in a buffer. A Block can be copied, moved and deleted in its
;; buffer as a stream or rectangular piece of text. Also, when
;; defined, it is copied in global variable "wm-stream" as normal
;; text and also in global variable "wm-rect" as a rectangular block
;; of text.  So the last Block defined in some buffer is "global",
;; it can be copied in every buffer. Because Start and End of Block
;; are local to buffers, every buffer can have its own Block and so
;; more than one Block can be defined at the same time in different
;; buffers (one per buffer). Only the last defined is "global": for
;; a Block defined before the last one is possible to became the
;; global one by "activating" it, when in its buffer it can be
;; copied with a command in global variables replacing the last
;; Block defined. A block can also be highlighted by a command using
;; a face, (named "blockface").
;;
;; More: 10 registers from 0 to 9 are defined for using with
;; blocks. It's possible to copy block into them (rect or stream) or
;; append to them (only stream): registers are global and are normal
;; emacs registers from 0 to 9. So registers can be used for
;; accumulate text and copy through buffers.
;;


;; Before all we need a face for highlighting block
(make-face 'blockface)
;; and now attributes for this face
(set-face-background 'blockface "black")
(set-face-foreground 'blockface "yellow")
;; without underline
(set-face-underline-p 'blockface nil)


;;;;;;;;;;;; Some NON interactive used by command functions

;; this tests if there is a block or a block start or a block end
;; in current buffer: if length of block is zero deletes it.
(defun wm-block-test ()
  "Test if there is a Block or Start/End in current buffer."
  (if (and wm-block-mark-start wm-block-mark-end)
      (if (not (= (- wm-block-mark-end wm-block-mark-start) 0))
	  ()
	(message "Zero length Block..."))
    (if wm-block-mark-start
	(error "End of Block not set.")
      (if wm-block-mark-end
	  (error "Start of Block not set.")
	(error "No Block")))))



;;;;;;;;;; Block Command Functions ;;;;;;;;;;
;;

(defun wm-block-unset ()
  "Unset Block in current buffer."
  (interactive)
;; normal face
  (if (and wm-block-mark-start wm-block-mark-end)
      (facemenu-add-face 'default wm-block-mark-start wm-block-mark-end))
  (setq wm-block-mark-start nil
	wm-block-mark-end nil
	wm-block-is nil
	wm-block-show nil)
  (wm-refontify)
  (message "Block unset."))



(defun wm-block-toggle-rect ()
  "Toggles stream/rectangular operations on block."
 (interactive)
 (if wm-block-rect
     (progn
       (setq wm-block-rect nil
	     wm-ml-block "-")
       (force-mode-line-update)
       (message "Column Block OFF."))
   (setq wm-block-rect t
	 wm-ml-block "C")
   (force-mode-line-update)
   (message "Column Block ON.")))



(defun wm-block-show-hide (&optional arg)
  "Show/hide Block in blockface face."
  (interactive "P")
  (wm-block-test)
  (cond ((null arg)
	 (if wm-block-show
	     (progn
	       (facemenu-add-face 'default
				  wm-block-mark-start wm-block-mark-end)
	       (setq wm-block-show nil))
	   (facemenu-add-face 'blockface
			      wm-block-mark-start wm-block-mark-end)
	   (setq wm-block-show t)))
	((> (prefix-numeric-value arg) 0)
	 (facemenu-add-face 'blockface
			    wm-block-mark-start wm-block-mark-end)
	 (setq wm-block-show t))
	((< (prefix-numeric-value arg) 1)
	 (facemenu-add-face 'default
			    wm-block-mark-start wm-block-mark-end)
	 (setq wm-block-show nil))))
    

(defun wm-block-start (&optional arg)
  "Start of block. With arg redefine Start of Block."
  (interactive "P")
  (if arg
      (wm-block-new-start)
    (if wm-block-is
      (wm-block-unset))
    (if (null wm-block-mark-end)
	(progn
	  (setq wm-block-mark-start (point-marker))
	  (message "Block Start marked. Not End."))
      (if ( < (point-marker) wm-block-mark-end)
	    (setq wm-block-mark-start (point-marker))
	(setq wm-block-mark-start wm-block-mark-end
	      wm-block-mark-end (point-marker)))
      (setq wm-rect (extract-rectangle wm-block-mark-start wm-block-mark-end)
	    wm-stream (buffer-substring wm-block-mark-start wm-block-mark-end)
	    wm-block-is t
	    wm-block-show t)
;; default Block is highlighted in blockface face
      (facemenu-add-face 'blockface wm-block-mark-start wm-block-mark-end)
      (message "Block defined. Copied in global register."))))



(defun wm-block-end (&optional arg)
  "End of block. With arg redefine End of Block."
  (interactive "P")
  (if arg
      (wm-block-new-end)
; unset of prev block
    (if wm-block-is
	(wm-block-unset))
    (if (null wm-block-mark-start)
	(progn
	  (setq wm-block-mark-end (point-marker))
	  (message "Block End marked. Not Start."))
      (if ( > (point-marker) wm-block-mark-start)
	  (setq wm-block-mark-end (point-marker))
	(setq wm-block-mark-end wm-block-mark-start
	      wm-block-mark-start (point-marker)))
      (setq wm-rect (extract-rectangle wm-block-mark-start wm-block-mark-end)
	    wm-stream (buffer-substring wm-block-mark-start wm-block-mark-end)
	    wm-block-is t
	    wm-block-show t)
      (facemenu-add-face 'blockface wm-block-mark-start wm-block-mark-end)
      (message "Block defined. Copied in global register."))))


(defun wm-block-goto-start ()
  "Jump to start of block."
  (interactive)
  (if (null wm-block-mark-start)
      (error "Start of Block not set")
    (if (= (point-marker) (or wm-block-mark-end wm-block-mark-start))
	(goto-char wm-block-mark-start)
      (push-mark)
      (goto-char wm-block-mark-start))))


(defun wm-block-new-start ()
  "Extend Block."
;  (interactive)
  (wm-block-test)
  (if (= (point) (or wm-block-mark-start wm-block-mark-end))
      (error "Same Block")
    (if ( < (point) wm-block-mark-end)
	(setq wm-block-mark-start (point-marker))
      (setq wm-block-mark-start wm-block-mark-end
	    wm-block-mark-end (point-marker)))
    (setq wm-rect (extract-rectangle wm-block-mark-start wm-block-mark-end)
	wm-stream (buffer-substring wm-block-mark-start wm-block-mark-end)
	wm-block-is t)
    (wm-refontify)
    (message "Block redefined. Copied to global register.")))
  
(defun wm-block-new-end ()
  "Extend Block."
;  (interactive)
  (wm-block-test)
  (if (= (point) (or wm-block-mark-start wm-block-mark-end))
      (error "Same Block")
    (if ( > (point) wm-block-mark-start)
	(setq wm-block-mark-end (point-marker))
      (setq wm-block-mark-end wm-block-mark-start
	    wm-block-mark-start (point-marker)))
    (setq wm-rect (extract-rectangle wm-block-mark-start wm-block-mark-end)
	wm-stream (buffer-substring wm-block-mark-start wm-block-mark-end)
	wm-block-is t)
    (wm-refontify)
    (message "Block redefined. Copied to global register.")))


(defun wm-block-goto-end ()
  "Jump to end of block."
  (interactive)
  (if (null wm-block-mark-end)
    (error "End of Block not set.")
    (if (= (point-marker) (or wm-block-mark-start wm-block-mark-end))
	(goto-char wm-block-mark-end)
      (push-mark)
      (goto-char wm-block-mark-end))))


;; With arg copy in buffer the global block, else local block
(defun wm-block-copy (&optional arg)
  "Copy block to current cursor position.
With arg copy the last Block defined in any buffer or active Block."
  (interactive "P")
  (if arg
      (if (null (and wm-stream wm-rect))
	  (error "No global Block defined")
	(if wm-block-rect
	    (insert-rectangle wm-rect)
	  (insert wm-stream))
	(wm-refontify))
    (wm-block-test)
    (if wm-block-show
	(facemenu-add-face 'default
			   wm-block-mark-start wm-block-mark-end))
    (if wm-block-rect
	(insert-rectangle
	 (extract-rectangle wm-block-mark-start wm-block-mark-end))
      (copy-region-as-kill wm-block-mark-start wm-block-mark-end)
      (yank))
    (if wm-block-show
	(facemenu-add-face 'blockface
			   wm-block-mark-start wm-block-mark-end))))

    

(defun wm-block-move ()
  "Move block to current cursor position."
  (interactive)
  (wm-block-test)
  (if wm-block-show
      (wm-block-show-hide 0))
  (push-mark wm-block-mark-start)
  (if wm-block-rect
      (progn
	(kill-rectangle wm-block-mark-start wm-block-mark-end)
	(yank-rectangle))
    (kill-region wm-block-mark-start wm-block-mark-end)
    (yank))
;; Unset block: no problems!
  (wm-block-unset))


(defun wm-block-delete (&optional arg)
  "Delete block. With arg fill with blanks if rect ON."
  (interactive "P")
  (wm-block-test)
  (if wm-block-show
      (wm-block-show-hide 0))
  (push-mark wm-block-mark-start)
  (if wm-block-rect
      (if arg
	  (clear-rectangle wm-block-mark-start wm-block-mark-end)
	(delete-extract-rectangle wm-block-mark-start wm-block-mark-end))
    (kill-region wm-block-mark-start wm-block-mark-end))
  (wm-block-unset))


(defun wm-block-write ()
  "Write block to file."
  (interactive)
  (wm-block-test)
  (let ((filename (read-file-name "Write Block to file: ")))
    (write-region wm-block-mark-start wm-block-mark-end filename)))


(defun wm-block-append ()
  "Append Block to file."
  (interactive)
  (wm-block-test)
  (let ((filename (read-file-name "Append Block to file: ")))
    (append-to-file wm-block-mark-start wm-block-mark-end filename)))



(defun wm-block-pipe (&optional arg)
  "Pipe block through external command.
If arg or null Block, pipe entire buffer."
  (interactive "P")
  (if (or arg (null wm-block-is))
      (save-excursion
	(let ((cmd (read-from-minibuffer "Filter for Buffer: ")))
	  (if (equal cmd "")
	      (error "No command")
	    (shell-command-on-region (point-min) (point-max) cmd nil 1))))
    (wm-block-test)
    (save-excursion
      (let ((cmd (read-from-minibuffer "Filter for Block: ")))
	(if (equal cmd "")
	    (error "No command")
	  (shell-command-on-region wm-block-mark-start wm-block-mark-end
				   cmd nil 1)))))
  (wm-block-unset))
	

;; With this one the block in curbuf is set "global" (i.e. copied
;; stream and rectangular in the two global registers) also if it is
;; not the last defined Block.  With argument append instead (only
;; stream).
(defun wm-block-active (&optional arg)
  "Copy Block in global register replacing the last Block defined.
With arg append (only stream)."
  (interactive "P")
  (wm-block-test)
  (if arg
      (setq wm-stream (concat wm-stream "\n"
			      (buffer-substring
			       wm-block-mark-start wm-block-mark-end)))
    (setq wm-rect (extract-rectangle
		   wm-block-mark-start wm-block-mark-end)
	  wm-stream (buffer-substring
		     wm-block-mark-start wm-block-mark-end))))



;; this one rearrange buffer faces in wormstar [and in font-lock-mode].
(defun wm-refontify ()
  "Rearrange faces."
  (interactive)
  (facemenu-add-face 'default (point-min) (point-max))
;  (if (and (symbolp 'font-lock-mode) (null font-lock-mode))
;      ()
;    (font-lock-fontify-buffer))
  (if wm-block-is
      (progn
	(facemenu-add-face 'blockface
			   wm-block-mark-start wm-block-mark-end)
	(setq wm-block-show t))))
      


;;;;;;;;;; Block INTO Registers ;;;;;;;;;;


(defun wm-block-reg-0 (&optional arg)
  "Copy Block into register 0. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?0 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 0."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?0 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 0."))
      (copy-to-register ?0 wm-block-mark-start wm-block-mark-end)
      (message "Copied to 0."))))

(defun wm-block-reg-1 (&optional arg)
  "Copy Block into register 1. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?1 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 1."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?1 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 1."))
    (copy-to-register ?1 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 1."))))


(defun wm-block-reg-2 (&optional arg)
  "Copy Block into register 2. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?2 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 2."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?2 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 2."))
    (copy-to-register ?2 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 2."))))


(defun wm-block-reg-3 (&optional arg)
  "Copy Block into register 3. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?3 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 3."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?3 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 3."))
    (copy-to-register ?3 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 3."))))


(defun wm-block-reg-4 (&optional arg)
  "Copy Block into register 4. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?4 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 4."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?4 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 4."))
    (copy-to-register ?4 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 4."))))


(defun wm-block-reg-5 (&optional arg)
  "Copy Block into register 5. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?5 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 5."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?5 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 5."))
    (copy-to-register ?5 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 5."))))


(defun wm-block-reg-6 (&optional arg)
  "Copy Block into register 6. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?6 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 6."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?6 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 6."))
    (copy-to-register ?6 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 6."))))


(defun wm-block-reg-7 (&optional arg)
  "Copy Block into register 7. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?7 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 7."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?7 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 7."))
    (copy-to-register ?7 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 7."))))


(defun wm-block-reg-8 (&optional arg)
  "Copy Block into register 8. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?8 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 8."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?8 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 8."))
    (copy-to-register ?8 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 8."))))


(defun wm-block-reg-9 (arg)
  "Copy Block into register 9. With argument append."
  (interactive "P")
  (wm-block-test)
  (if arg
      (progn
	(append-to-register ?9 wm-block-mark-start wm-block-mark-end)
	(message "Appended to 9."))
    (if wm-block-rect
	(progn
	  (copy-rectangle-to-register ?9 wm-block-mark-start wm-block-mark-end)
	  (message "Rect copied to 9."))
    (copy-to-register ?9 wm-block-mark-start wm-block-mark-end)
    (message "Copied to 9."))))

  

;;;;;;;;;; Block COPY FROM Registers ;;;;;;;;;;


(defun wm-get-reg-0 ()
  "Insert text from register 0."
  (interactive)
  (insert-register ?0)
  (message "Inserted from 0.")
  (wm-refontify))


(defun wm-get-reg-1 ()
  "Insert text from register 1."
  (interactive)
  (insert-register ?1)
  (message "Inserted from 1.")
  (wm-refontify))

(defun wm-get-reg-2 ()
  "Insert text from register 2."
  (interactive)
  (insert-register ?2)
  (message "Inserted from 2.")
  (wm-refontify))

(defun wm-get-reg-3 ()
  "Insert text from register 3."
  (interactive)
  (insert-register ?3)
  (message "Inserted from 3.")
  (wm-refontify))

(defun wm-get-reg-4 ()
  "Insert text from register 4."
  (interactive)
  (insert-register ?4)
  (message "Inserted from 4.")
  (wm-refontify))

(defun wm-get-reg-5 ()
  "Insert text from register 5."
  (interactive)
  (insert-register ?5)
  (message "Inserted from 5.")
  (wm-refontify))

(defun wm-get-reg-6 ()
  "Insert text from register 6."
  (interactive)
  (insert-register ?6)
  (message "Inserted from 6.")
  (wm-refontify))

(defun wm-get-reg-7 ()
  "Insert text from register 7."
  (interactive)
  (insert-register ?7)
  (message "Inserted from 7.")
  (wm-refontify))

(defun wm-get-reg-8 ()
  "Insert text from register 8."
  (interactive)
  (insert-register ?8)
  (message "Inserted from 8.")
  (wm-refontify))

(defun wm-get-reg-9 ()
  "Insert text from register 9."
  (interactive)
  (insert-register ?9)
  (message "Inserted from 9.")
  (wm-refontify))




;;;;;;;;;;;;;;; SPECIALIZED BLOCKS ;;;;;;;;;;;;;;;


(defun wm-mark-word ()
  "Mark current word as block."
  (interactive)
  (save-excursion
    (forward-word 1)
    (wm-block-end)
    (forward-word -1)
    (wm-block-start)
    (message "Word marked as Block.")))

(defun wm-mark-line ()
  "Mark current line as block."
  (interactive)
  (save-excursion
;    (end-of-line 1)
    (beginning-of-line 1)
    (wm-block-start)
    (next-line 1)
    (wm-block-end)
    (message "Line marked as Block.")))

(defun wm-mark-paragraph ()
  "Mark current paragraph as Block."
  (interactive)
  (save-excursion
    (forward-paragraph)
    (wm-block-end)
    (backward-paragraph)
    (wm-block-start)
    (message "Paragraph marked as Block.")))

(defun wm-indent-block ()
  "Indent block (not yet implemented)."
  (interactive)
  (error "Indent Block not yet implemented"))


(defun wm-exdent-block ()
  "I don't know what this (C-k u) should do."
  (interactive)
  (error "Exdent Block not yet implemented."))


;;;;;;;;;; SOME COMMAND FUNCTIONS FOR EDITING ;;;;;;;;;;


(defun wm-undo ()
  "Undoes trying to not mess up with block and face..."
  (interactive)
  (push-mark (point-marker))
  (undo)
  (wm-refontify))


(defun wm-kill-bol ()
  "Kill to beginning of line."
  (interactive)
  (let ((p (point)))
    (beginning-of-line)
    (kill-region (point) p)))

(defun wm-kill-line ()
  "Kill the complete line."
  (interactive)
  (beginning-of-line)
  (if (eobp) (error "End of buffer"))
  (let ((beg (point)))
    (forward-line 1)
    (kill-region beg (point))))


(defun wm-center-line ()
  "Center the line point is on, within the width specified by `fill-column'.
This means adjusting the indentation to match
the distance between the end of the text and `fill-column'."
  (interactive)
  (save-excursion
    (let (line-length)
      (beginning-of-line)
      (delete-horizontal-space)
      (end-of-line)
      (delete-horizontal-space)
      (setq line-length (current-column))
      (beginning-of-line)
      (indent-to 
       (+ left-margin 
	  (/ (- fill-column left-margin line-length) 2))))))


(defun wm-center-region (from to)
  "Center each line starting in the region.
See `wm-center-line' for more info."
  (interactive "r")
  (if (> from to)
      (let ((tem to))
	(setq to from from tem)))
  (save-excursion
    (save-restriction
      (narrow-to-region from to)
      (goto-char from)
      (while (not (eobp))
	(wm-center-line)
	(forward-line 1)))))

(defun wm-center-block ()
  "Center lines of Block. Lines!"
  (interactive)
  (wm-block-test)
  (save-excursion
    (goto-char wm-block-mark-start)
    (beginning-of-line)
    (let ((inizio (point-marker)))
      (goto-char wm-block-mark-end)
      (end-of-line)
      (wm-center-region inizio (point)))))


(defun wm-center-paragraph ()
  "Center each line in the paragraph at or after point.
See `wm-center-line' for more info."
  (interactive)
  (save-excursion
    (forward-paragraph)
    (or (bolp) (newline 1))
    (let ((end (point)))
      (backward-paragraph)
      (wm-center-region (point) end))))



(defun wm-right-margin (num)
  "Set column right margin for wrapping."
  (interactive "nRight margin at column number: ")
  (set-fill-column num)
  (message "Right margin at column %s." num))

(defun wm-left-margin (num)
  "Set column left margin for wrapping."
  (interactive "nLeft margin at column number: ")
  (setq left-margin num)
  (message "Left margin at column %s." num))

(defun wm-toggle-wrap ()
  "Toggle wordwrapping."
  (interactive)
  (if wm-wordwrap
      (progn
	(auto-fill-mode -1)
	(setq wm-wordwrap nil
	      wm-ml-wrap "-")
	(message "Wordwrap OFF."))
    (auto-fill-mode 1)
    (setq wm-wordwrap t
	  wm-ml-wrap "W")
    (message "Wordwrap ON.")))

(defun wm-toggle-just ()
  "Toggle justification of filling paragraphs."
  (interactive)
  (if wm-justify
      (progn
	(setq wm-justify nil
	      wm-ml-just "-")
	(force-mode-line-update)
	(message "Justification OFF."))
    (setq wm-justify t
	  wm-ml-just "J")
    (force-mode-line-update)
    (message "Justification ON.")))

(defun wm-toggle-case ()
  "Toggles ignoring case in searching."
  (interactive)
  (if case-fold-search
      (progn
	(setq case-fold-search nil
	      wm-ml-case "C")
	(force-mode-line-update)
	(message "Search CASE sensitive."))
    (setq case-fold-search t
	  wm-ml-case "-")
    (force-mode-line-update)
    (message "Search Case Insensitive.")))


(defun wm-block-fill (&optional arg)
  "Fill Block. If wm-justify is T, justify as well.
With arg fill Block as one paragraph."
  (interactive "P")
  (wm-block-test)
  (let ((last (point-marker)))
    (if arg
        (if wm-justify
            (fill-region-as-paragraph wm-block-mark-start wm-block-mark-end t)
          (fill-region-as-paragraph wm-block-mark-start wm-block-mark-end))
      (if wm-justify
            (fill-region wm-block-mark-start wm-block-mark-end t)
          (fill-region wm-block-mark-start wm-block-mark-end)))
	(goto-char last)))

(defun wm-fill-par (&optional arg)
  "Fill paragraph. If wm-justify is T, justify as well.
With arg fill Block."
  (interactive "P")
  (if arg
      (wm-block-fill)
    (if wm-justify
        (fill-paragraph 1)
      (fill-paragraph t))))


;;;;;;;;;;;;;;;;; PRINTING FUNCTIONS ;;;;;;;;;;;;;;;
;;
;; Important emacs variables and commands for printing (see docs):
;; lpr-switches, lpr-command, lpr-region, lpr-buffer.
;; For Postscript:
;; ps-print-region, ps-print-buffer (and all the ps-* cmds & vars!)

;; interactive function for set the printing filter string
;; Filtering works well with *roff family
(defun wm-print-set-filter ()
  "Set the string for filter printing."
  (interactive)
  (setq lpr-page-header-program
	(read-from-minibuffer
	 "Filter command for printing (no args): "))
  (message "Filter command for printing set to: %s" lpr-page-header-program)
  (setq lpr-page-header-switches
	(read-from-minibuffer
	 "Args to filter: "))
  (message "Args for %s set to: %s" lpr-page-header-program
	   lpr-page-header-switches)
  (setq wm-print-filter (concat lpr-page-header-program " "
				lpr-page-header-switches " | "
				lpr-command))
  (message "Filter set to: %s" wm-print-filter))


;; Three possible values for printing: sets one fo them in a ring of choices.
;; "R" for Raw, "P" for emacs Postscript, "F" for custom Filter
(defun wm-print-mode ()
  "Run the ring of the 3 printing modes."
  (interactive)
  (cond ((equal wm-ml-print "R")
	 (setq wm-ml-print "F")
	 (message "Filter printing ON."))
	((equal wm-ml-print "P")
	 (setq wm-ml-print "R")
	 (message "Raw printing ON."))
	((equal wm-ml-print "F")
	 (setq wm-ml-print "P")
	 (message "Postscript printing ON."))
	((not (equal wm-ml-print (or "R" "F" "P")))
	 (setq wm-ml-print "R")
	 (message "Raw printing ON.")))
  (force-mode-line-update))

;; prints Block or Buffer, Raw, Postscript or Filtering
;; a non interactive func used by wm-print
(defun wm-print-what (block)
  "What printing: Block or Buffer."
  (let ((tempbuf (concat "*" (buffer-name) "*")))
;; print Block if block = 1
    (if (= block 1)
; we must delete, before printing, comment lines beginning with
; two dots. I use external sed... (not the best choice I know
; but it does well the dirty thing)
	  (shell-command-on-region wm-block-mark-start
				   wm-block-mark-end
; The regexp matches also lines beginning with spaces or tabs
; before two dots, so we can indenting comment lines.
				   "sed -e '/^[ 	]*\\.\\./d'"
				   tempbuf
				   nil)
      (shell-command-on-region (point-min)
			       (point-max)
			       "sed -e '/^[ 	]*\\.\\./d'"
			       tempbuf
			       nil))
    (save-excursion
      (set-buffer tempbuf)
      (cond ((equal wm-ml-print "R")
	     (lpr-buffer))
	    ((equal wm-ml-print "P")
	     (ps-print-buffer))
	    ((equal wm-ml-print "F")
	     (if wm-print-filter
             (progn
               (shell-command-on-region (point-min)
                                        (point-max)
                                        wm-print-filter
                                        nil nil)
               (message "Printing with filter: %s" wm-print-filter))
	       (wm-print-set-filter)
	       (shell-command-on-region (point-min)
                                    (point-max)
                                    wm-print-filter
                                    nil nil)
	       (message "Printing with filter: %s" wm-print-filter)))
	    ((not (equal wm-ml-print (or "R" "P" "F")))
	     (error "Set printing mode first!"))))
    (kill-buffer tempbuf)
    (delete-other-windows)))

    

;; Printing preview for all buffer - uses the filter program for
;; preview: this hack works great using *roff family filters to obtain an
;; ascii preview or the postscript code (ex. using groff)
;; Perhaps it is util also with "lout -p"
(defun wm-print-preview ()
  "Print preview of the buffer."
  (interactive)
  (if (null wm-print-filter)
      (wm-print-set-filter))
  (message "Preparing Preview...")
  (let ((preview (concat "<PREVIEW> "(buffer-name))))
;; before all strip out comment lines
    (shell-command-on-region (point-min)
			     (point-max)
			     "sed -e '/^[ 	]*\\.\\./d'"
;;			     "cat"
			     preview nil)
    (save-excursion
      (set-buffer preview)
;; And now: if printing is F (filtering) we use that filter
;; for generating preview else we'll have only deleted comment
;; lines (those beginning with two dots)
      (if (equal wm-ml-print "F")
          (progn (shell-command-on-region (point-min)
                                        (point-max)
                                        (concat lpr-page-header-program " "
                                                lpr-page-header-switches)
                                        t nil)
            (goto-char (point-min))
;; we strip out every control char that defines bold or
;; underline/italic, not ot mess up printing buffer, it's a
;; preview...
            (replace-regexp "." "")))
      (wormstar)
      (toggle-read-only 1))
      (message "Printing Preview for %s... done" (buffer-name))))

;; skeleton of main printing function
(defun wm-print (&optional arg)
  "Print Buffer or Block."
  (interactive "P")
;  (if arg
;      (let (file (read-file-name "Write Postscript to file: "))))
  (if wm-block-is
       (let ((char (read-from-minibuffer "Print bLock or bUffer? (l or u): "
			     "l")))
	 (cond ((equal char "l")
		(wm-print-what 1))
	       ((equal char "u")
		(wm-print-what 0))
	       ((not (equal char (or "l" "u")))
		(error "Please answer <l> or <u>"))))
    (let ((char (read-from-minibuffer "Print entire Buffer? (y): " "y")))
       (if (not (equal char "y"))
	   (error "Please answer <y> for buffer printing")
	 (wm-print-what 0)))))

;; Now some shortcuts for nroff/groff/troff commands

;; Roman, Bold, Italic, Bold-Italic
(defun wm-troff-roman ()
  "Print Roman command."
  (interactive)
  (insert "\\fR"))

(defun wm-troff-bold ()
  "Print Bold command."
  (interactive)
  (insert "\\fB"))

(defun wm-troff-italic ()
  "Print Italic command."
  (interactive)
  (insert "\\fI"))

(defun wm-troff-bold-italic ()
  "Print Bold-Italic command."
  (interactive)
  (insert "\\f[BI]"))

(defun wm-font-size (size)
  "Set font size in troff way."
  (interactive "sSet Font Size: ")
  (insert "\\s[" size "]"))


;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;;
;;                     KEYBINDINGS
;;
;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;; Before all: in WorM (like in original WordStar) there isn't a
;; Control cmd for "yank" (C-y in emacs):
;; so in wm we assign yaNk to ^Q^N and yankpOp to ^Q^O

(global-unset-key "\C-a")
(global-unset-key "\C-b")
(global-unset-key "\C-c")
(global-unset-key "\C-d")
(global-unset-key "\C-e")
(global-unset-key "\C-f")
(global-unset-key "\C-g")
(global-unset-key "\C-h")
(global-unset-key "\C-i")
(global-unset-key "\C-j")
(global-unset-key "\C-k")
(global-unset-key "\C-l")
(global-unset-key "\C-n")
(global-unset-key "\C-o")
(global-unset-key "\C-p")
(global-unset-key "\C-q")
(global-unset-key "\C-r")
(global-unset-key "\C-s")
(global-unset-key "\C-t")
(global-unset-key "\C-u")
(global-unset-key "\C-v")
(global-unset-key "\C-w")
(global-unset-key "\C-x")
(global-unset-key "\C-y")
(global-unset-key "\C-z")
(global-unset-key "\C-_")
(global-unset-key [?\C- ])


(global-set-key "\C-a" 'backward-word)
(global-set-key "\C-b" 'wm-fill-par)
(global-set-key "\C-c" 'scroll-up)
(global-set-key "\C-d" 'forward-char)
(global-set-key "\C-e" 'previous-line)
(global-set-key "\C-f" 'forward-word)
(global-set-key "\C-g" 'delete-char)
(global-set-key "\C-h" 'backward-delete-char)
(global-set-key "\C-i" 'indent-for-tab-command)
;;(global-set-key "\C-j" wormstar-C-j-map)
;;(global-set-key "\C-k" wormstar-C-k-map)
(global-set-key "\C-l" 'wm-repeat-search)
(global-set-key "\C-n" 'open-line)
;;(global-set-key "\C-o" wormstar-C-o-map)
;;(global-set-key "\C-p" wormstar-C-p-map)
;;(global-set-key "\C-q" wormstar-C-q-map)
(global-set-key "\C-r" 'scroll-down)
(global-set-key "\C-s" 'backward-char)
(global-set-key "\C-t" 'kill-word)
(global-set-key "\C-u" 'universal-argument)
(global-set-key "\C-v" 'overwrite-mode)
(global-set-key "\C-w" 'wm-scroll-down-line)
(global-set-key "\C-x" 'next-line)
(global-set-key "\C-y" 'wm-kill-line)
(global-set-key "\C-z" 'wm-scroll-up-line)
(global-set-key "\C-_" 'undo)
(global-set-key [?\C- ] 'keyboard-escape-quit) ; C-SPC
; 
;; ^J for windows
(global-set-key "\C-jb" 'switch-to-buffer)
(global-set-key "\C-j\C-b" 'switch-to-buffer)
(global-set-key "\C-je" 'wm-prev-window)
(global-set-key "\C-j\C-e" 'wm-prev-window)
(global-set-key "\C-jj" 'wm-help-me)
(global-set-key "\C-j\C-j" 'wm-help-me)
(global-set-key "\C-jx" 'wm-next-window)
(global-set-key "\C-j\C-x" 'wm-next-window)
(global-set-key "\C-ju" 'list-buffers)
(global-set-key "\C-j\C-u" 'list-buffers)
(global-set-key "\C-j0" 'delete-window)
(global-set-key "\C-j1" 'delete-other-windows)
(global-set-key "\C-j2" 'split-window-vertically)
(global-set-key "\C-j/" 'split-window-horizontally)
(global-set-key "\C-j+" 'enlarge-window)
(global-set-key "\C-j-" 'shrink-window)
(global-set-key "\C-j!" 'shell)

;; ^K map
(global-set-key "\C-k0" 'wm-set-mark-0)
(global-set-key "\C-k1" 'wm-set-mark-1)
(global-set-key "\C-k2" 'wm-set-mark-2)
(global-set-key "\C-k3" 'wm-set-mark-3)
(global-set-key "\C-k4" 'wm-set-mark-4)
(global-set-key "\C-k5" 'wm-set-mark-5)
(global-set-key "\C-k6" 'wm-set-mark-6)
(global-set-key "\C-k7" 'wm-set-mark-7)
(global-set-key "\C-k8" 'wm-set-mark-8)
(global-set-key "\C-k9" 'wm-set-mark-9)
(global-set-key "\C-ka" 'wm-mark-paragraph)
(global-set-key "\C-k\C-a" 'wm-mark-paragraph)
(global-set-key "\C-kb" 'wm-block-start)
(global-set-key "\C-k\C-b" 'wm-block-start)
(global-set-key "\C-kc" 'wm-block-copy)
(global-set-key "\C-k\C-c" 'wm-block-copy)
(global-set-key "\C-kd" 'write-file)
(global-set-key "\C-k\C-d" 'write-file)
(global-set-key "\C-ke" 'find-file)
(global-set-key "\C-k\C-e" 'find-file)

;; A little function to use dired on default directory...
(defun wm-dired ()
  "Use dired on default directory."
(interactive)
(dired default-directory))

(global-set-key "\C-kf" 'wm-dired)
(global-set-key "\C-k\C-f" 'wm-dired)

(global-set-key "\C-kg" 'wm-block-show-hide)
(global-set-key "\C-k\C-g" 'wm-block-show-hide)

;; Text _I_nsert from Registers (0-9)
(global-set-key "\C-ki0" 'wm-get-reg-0)
(global-set-key "\C-k\C-i0" 'wm-get-reg-0)
(global-set-key "\C-ki1" 'wm-get-reg-1)
(global-set-key "\C-k\C-i1" 'wm-get-reg-1)
(global-set-key "\C-ki2" 'wm-get-reg-2)
(global-set-key "\C-k\C-i2" 'wm-get-reg-2)
(global-set-key "\C-ki3" 'wm-get-reg-3)
(global-set-key "\C-k\C-i3" 'wm-get-reg-3)
(global-set-key "\C-ki4" 'wm-get-reg-4)
(global-set-key "\C-k\C-i4" 'wm-get-reg-4)
(global-set-key "\C-ki5" 'wm-get-reg-5)
(global-set-key "\C-k\C-i5" 'wm-get-reg-5)
(global-set-key "\C-ki6" 'wm-get-reg-6)
(global-set-key "\C-k\C-i6" 'wm-get-reg-6)
(global-set-key "\C-ki7" 'wm-get-reg-7)
(global-set-key "\C-k\C-i7" 'wm-get-reg-7)
(global-set-key "\C-ki8" 'wm-get-reg-8)
(global-set-key "\C-k\C-i8" 'wm-get-reg-8)
(global-set-key "\C-ki9" 'wm-get-reg-9)
(global-set-key "\C-k\C-i9" 'wm-get-reg-9)

(global-set-key "\C-kj" 'wm-block-fill)
(global-set-key "\C-k\C-j" 'wm-block-fill)
(global-set-key "\C-kk" 'wm-block-end)
(global-set-key "\C-k\C-k" 'wm-block-end)
(global-set-key "\C-kl" 'wm-mark-line)
(global-set-key "\C-k\C-l" 'wm-mark-line)

;; Block _M_ove to Registers (0-9)
(global-set-key "\C-km0" 'wm-block-reg-0)
(global-set-key "\C-k\C-m0" 'wm-block-reg-0)
(global-set-key "\C-km1" 'wm-block-reg-1)
(global-set-key "\C-k\C-m1" 'wm-block-reg-1)
(global-set-key "\C-km2" 'wm-block-reg-2)
(global-set-key "\C-k\C-m2" 'wm-block-reg-2)
(global-set-key "\C-km3" 'wm-block-reg-3)
(global-set-key "\C-k\C-m3" 'wm-block-reg-3)
(global-set-key "\C-km4" 'wm-block-reg-4)
(global-set-key "\C-k\C-m4" 'wm-block-reg-4)
(global-set-key "\C-km5" 'wm-block-reg-5)
(global-set-key "\C-k\C-m5" 'wm-block-reg-5)
(global-set-key "\C-km6" 'wm-block-reg-6)
(global-set-key "\C-k\C-m6" 'wm-block-reg-6)
(global-set-key "\C-km7" 'wm-block-reg-7)
(global-set-key "\C-k\C-m7" 'wm-block-reg-7)
(global-set-key "\C-km8" 'wm-block-reg-8)
(global-set-key "\C-k\C-m8" 'wm-block-reg-8)
(global-set-key "\C-km9" 'wm-block-reg-9)
(global-set-key "\C-k\C-m9" 'wm-block-reg-9)

(global-set-key "\C-kn" 'wm-block-toggle-rect)
(global-set-key "\C-k\C-n" 'wm-block-toggle-rect)
(global-set-key "\C-ko" 'find-file-other-window)
(global-set-key "\C-k\C-o" 'find-file-other-window)
(global-set-key "\C-kp" 'wm-print)
(global-set-key "\C-k\C-p" 'wm-print)
(global-set-key "\C-kq" 'kill-buffer)
(global-set-key "\C-k\C-q" 'kill-buffer)
(global-set-key "\C-kr" 'insert-file)
(global-set-key "\C-k\C-r" 'insert-file)
(global-set-key "\C-ks" 'save-buffer)
(global-set-key "\C-k\C-s" 'save-buffer)
(global-set-key "\C-kt" 'wm-mark-word)
(global-set-key "\C-k\C-t" 'wm-mark-word)
(global-set-key "\C-ku" 'wm-block-unset)
(global-set-key "\C-k\C-u" 'wm-block-unset)
(global-set-key "\C-kv" 'wm-block-move)
(global-set-key "\C-k\C-v" 'wm-block-move)
(global-set-key "\C-kw" 'wm-block-write)
(global-set-key "\C-k\C-w" 'wm-block-write)
(global-set-key "\C-kx" 'save-buffers-kill-emacs)
(global-set-key "\C-k\C-x" 'save-buffers-kill-emacs)
(global-set-key "\C-ky" 'wm-block-delete)
(global-set-key "\C-k\C-y" 'wm-block-delete)
(global-set-key "\C-kz" 'suspend-emacs)
(global-set-key "\C-k\C-z" 'suspend-emacs)
(global-set-key "\C-k/" 'wm-block-pipe)
(global-set-key "\C-k>" 'wm-block-append)
(global-set-key "\C-k~" 'wm-block-active)
(global-set-key "\C-k[" 'backward-kill-sentence)
(global-set-key "\C-k]" 'kill-sentence)
(global-set-key "\C-k{" 'backward-kill-paragraph)
(global-set-key "\C-k}" 'kill-paragraph)
(global-set-key "\C-k," 'wm-refontify)

;; ^O map
(global-set-key "\C-oa" 'wm-center-paragraph)
(global-set-key "\C-o\C-a" 'wm-center-paragraph)
(global-set-key "\C-ob" 'wm-center-block)
(global-set-key "\C-o\C-b" 'wm-center-block)
(global-set-key "\C-oc" 'wm-center-line)
(global-set-key "\C-o\C-c" 'wm-center-line)
(global-set-key "\C-od" 'downcase-word)
(global-set-key "\C-o\C-d" 'downcase-word)
(global-set-key "\C-of" 'wm-toggle-case)
(global-set-key "\C-o\C-f" 'wm-toggle-case)
(global-set-key "\C-oj" 'wm-toggle-just)
(global-set-key "\C-o\C-j" 'wm-toggle-just)
(global-set-key "\C-ok" 'wm-block-fill)
(global-set-key "\C-o\C-k" 'wm-block-fill)
(global-set-key "\C-ol" 'wm-left-margin)
(global-set-key "\C-o\C-l" 'wm-left-margin)

;; Two commands for emacs "bookmarks"...

(global-set-key "\C-om" 'bookmark-set)
(global-set-key "\C-o\C-m" 'bookmark-set)
(global-set-key "\C-og" 'bookmark-jump)
(global-set-key "\C-o\C-g" 'bookmark-jump)

(global-set-key "\C-oo" 'toggle-read-only)
(global-set-key "\C-o\C-o" 'toggle-read-only)
(global-set-key "\C-op" 'capitalize-word)
(global-set-key "\C-o\C-p" 'capitalize-word)
(global-set-key "\C-or" 'wm-right-margin)
(global-set-key "\C-o\C-r" 'wm-right-margin)
(global-set-key "\C-ou" 'upcase-word)
(global-set-key "\C-o\C-u" 'upcase-word)
(global-set-key "\C-ow" 'wm-toggle-wrap)
(global-set-key "\C-o\C-w" 'wm-toggle-wrap)

;; ^P map
;;
(global-set-key "\C-p\C-i" 'wm-print-set-filter)
(global-set-key "\C-p\C-o" 'wm-troff-bold)
(global-set-key "\C-p\C-q" 'wm-print-mode)
(global-set-key "\C-p\C-r" 'wm-troff-roman)
(global-set-key "\C-p\C-n" 'wm-font-size)
(global-set-key "\C-p\C-t" 'wm-troff-italic)
(global-set-key "\C-p\C-v" 'wm-print-preview)
(global-set-key "\C-p\C-z" 'wm-troff-bold-italic)
(global-set-key "\C-pi" 'wm-print-set-filter)
(global-set-key "\C-po" 'wm-troff-bold)
(global-set-key "\C-pq" 'wm-print-mode)
(global-set-key "\C-pr" 'wm-troff-roman)
(global-set-key "\C-pn" 'wm-font-size)
(global-set-key "\C-pt" 'wm-troff-italic)
(global-set-key "\C-pv" 'wm-print-preview)
(global-set-key "\C-pz" 'wm-troff-bold-italic)


;; ^Q map
;;
;; To marks (0-9)
(global-set-key "\C-q0" 'wm-goto-mark-0)
(global-set-key "\C-q1" 'wm-goto-mark-1)
(global-set-key "\C-q2" 'wm-goto-mark-2)
(global-set-key "\C-q3" 'wm-goto-mark-3)
(global-set-key "\C-q4" 'wm-goto-mark-4)
(global-set-key "\C-q5" 'wm-goto-mark-5)
(global-set-key "\C-q6" 'wm-goto-mark-6)
(global-set-key "\C-q7" 'wm-goto-mark-7)
(global-set-key "\C-q8" 'wm-goto-mark-8)
(global-set-key "\C-q9" 'wm-goto-mark-9)
(global-set-key "\C-qa" 'wm-query-replace)
(global-set-key "\C-q\C-a" 'wm-query-replace)
(global-set-key "\C-qb" 'wm-block-goto-start)
(global-set-key "\C-q\C-b" 'wm-block-goto-start)
(global-set-key "\C-qc" 'end-of-buffer)
(global-set-key "\C-q\C-c" 'end-of-buffer)
(global-set-key "\C-qd" 'end-of-line)
(global-set-key "\C-q\C-d" 'end-of-line)
(global-set-key "\C-qe" 'wm-point-top)
(global-set-key "\C-q\C-e" 'wm-point-top)
(global-set-key "\C-qf" 'wm-search-2)
(global-set-key "\C-q\C-f" 'wm-search-2)
(global-set-key "\C-qg" 'wm-kill-bol)
(global-set-key "\C-q\C-g" 'wm-kill-bol)

(global-set-key "\C-qi" 'goto-line)
(global-set-key "\C-q\C-i" 'goto-line)
(global-set-key "\C-qj" 'quoted-insert)
(global-set-key "\C-q\C-j" 'quoted-insert)
(global-set-key "\C-qk" 'wm-block-goto-end)
(global-set-key "\C-q\C-k" 'wm-block-goto-end)
(global-set-key "\C-ql" 'wm-point-center)
(global-set-key "\C-q\C-l" 'wm-point-center)


(global-set-key "\C-qn" 'yank)
(global-set-key "\C-q\C-n" 'yank)
(global-set-key "\C-qo" 'yank-pop)
(global-set-key "\C-q\C-o" 'yank-pop)
(global-set-key "\C-qp" 'wm-jump-ring)
(global-set-key "\C-q\C-p" 'wm-jump-ring)

(global-set-key "\C-qr" 'beginning-of-buffer)
(global-set-key "\C-q\C-r" 'beginning-of-buffer)
(global-set-key "\C-qs" 'beginning-of-line)
(global-set-key "\C-q\C-s" 'beginning-of-line)
(global-set-key "\C-qt" 'backward-kill-word)
(global-set-key "\C-q\C-t" 'backward-kill-word)
(global-set-key "\C-qu" 'wm-undo)
(global-set-key "\C-q\C-u" 'wm-undo)
(global-set-key "\C-qv" 'wm-goto-search-start)
(global-set-key "\C-q\C-v" 'wm-goto-search-start)
(global-set-key "\C-qw" 'wm-continuous-up)
(global-set-key "\C-q\C-w" 'wm-continuous-up)
(global-set-key "\C-qx" 'wm-point-bottom)
(global-set-key "\C-q\C-x" 'wm-point-bottom)
(global-set-key "\C-qy" 'kill-line)
(global-set-key "\C-q\C-y" 'kill-line)
(global-set-key "\C-qz" 'wm-continuous-down)
(global-set-key "\C-q\C-z" 'wm-continuous-down)
(global-set-key "\C-q\177" 'wm-kill-bol)
(global-set-key "\C-q[" 'backward-sentence)
(global-set-key "\C-q]" 'forward-sentence)
(global-set-key "\C-q{" 'backward-paragraph)
(global-set-key "\C-q}" 'wm-forward-paragraph)


;;;;;;;;;;;;;;; MOUSE EVENTS ;;;;;;;;;;
;;
;; To not have problems with region defined by normal mouse clicks
;; we bind them to define Start/End of Block.  Anyway we have the
;; Alt+Mouse commands to select text and copy/move it across windows
;; in X. These commands don't define a region and are not influenced
;; by the transient-mark-mode command
;;
;; Before we unset start of region
(local-unset-key [down-mouse-1])
;;
(local-set-key [down-mouse-1] 'mouse-drag-secondary)
(local-set-key [mouse-2] 'mouse-yank-secondary)
(local-set-key [mouse-3] 'mouse-secondary-save-then-kill)

;;; END OF GAME

