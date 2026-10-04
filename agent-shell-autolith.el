;;; agent-shell-autolith.el --- Autolith Lisp agent configurations -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Joar von Arndt

;; This package is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This package is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This file includes Autolith Lisp agent-specific configurations.
;;
;; Autolith is self-modifiable common lisp agent by Lambda Symbolics.
;; See https://www.lambda-symbolics.com/autolith
;;

;;; Code:

(eval-when-compile
  (require 'cl-lib))
(require 'shell-maker)
(require 'acp)
(require 'map)
(require 'seq)

(declare-function agent-shell--indent-string "agent-shell")
(declare-function agent-shell-make-agent-config "agent-shell")
(autoload 'agent-shell-make-agent-config "agent-shell")
(declare-function agent-shell--make-acp-client "agent-shell")
(declare-function agent-shell--dwim "agent-shell")

(defcustom agent-shell-autolith-acp-command
  '("autolith" "acp")
  "Command and parameters for the Autolith ACP client.

The first element is the command name, and the rest are command parameters."
  :type '(repeat string)
  :group 'agent-shell)

(defcustom agent-shell-autolith-environment
  nil
  "Environment variables for the Autolith client.

This should be a list of environment variables to be used when
starting the Autolith client process.

Example usage to set custom environment variables:

  (setq agent-shell-autolith-environment
        (`agent-shell-make-environment-variables'
         \"OPENROUTER_API_KEY\" \"your-key\"
         \"MY_OTHER_VAR\" \"another-value\"))"
  :type '(repeat string)
  :group 'agent-shell)

(defun agent-shell-autolith-make-agent-config ()
  "Create an Autolith coding agent configuration.

Returns an agent configuration alist using `agent-shell-make-agent-config'."
  (agent-shell-make-agent-config
   :identifier 'autolith
   :mode-line-name "Autolith"
   :buffer-name "Autolith"
   :shell-prompt "Autolith> "
   :shell-prompt-regexp "Autolith> "
   :welcome-function #'agent-shell-autolith--welcome-message
   :client-maker (lambda (buffer)
                   (agent-shell-autolith-make-client :buffer buffer))
   :install-instructions "Make sure `autolith' is available in PATH. Authenticate by running
`autolith auth PROVIDER' in a terminal. For more details see
https://github.com/lambda-symbolics/autolith"))

;;;###autoload
(defun agent-shell-autolith-start-agent ()
  "Start an interactive Autolith Lisp agent shell."
  (interactive)
  (agent-shell--dwim :config (agent-shell-autolith-make-agent-config)
                     :new-shell t))

(cl-defun agent-shell-autolith-make-client (&key buffer)
  "Create a Autolith client with BUFFER as context."
  (unless buffer
    (error "Missing required argument: :buffer"))
  (agent-shell--make-acp-client :command (car agent-shell-autolith-acp-command)
                                :command-params (cdr agent-shell-autolith-acp-command)
                                :environment-variables agent-shell-autolith-environment
                                :context-buffer buffer))

(defun agent-shell-autolith--welcome-message (config)
  "Return Autolith welcome message using `shell-maker' CONFIG."
  (let ((art (agent-shell--indent-string 4 (agent-shell-autolith--ascii-art)))
        (message (string-trim-left (shell-maker-welcome-message config) "\n")))
    (concat "\n\n"
            art
            "\n\n"
            message)))

(defun agent-shell-autolith--ascii-art ()
  "Autolith ASCII art."
  (let* ((is-dark (eq (frame-parameter nil 'background-mode) 'dark))
         (text (string-trim "
  :::.      :::
  ;;`;;     ;;;
 ,[[ '[[,   [[[
c$$$cc$$$c  $$'
 888   888,o88oo,.__
 YMM   \"\"` \"\"\"\"YUMMM
" "\n")))
    (propertize text 'font-lock-face (if is-dark
                                         '(:foreground "#D7FF87" :inherit fixed-pitch)
                                       '(:foreground "#5FFF00" :inherit fixed-pitch)))))

(provide 'agent-shell-autolith)

;;; agent-shell-autolith.el ends here
