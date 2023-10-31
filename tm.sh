#!/usr/bin/env sh

set -e

err() {
  printf >&2 "error: %s\n" "$@"
  exit 1
}

require() {
  for arg; do
    if ! command -v "${arg}" >/dev/null; then
      missing_commands="${missing_commands}\"${arg}\" "
    fi
  done

  if [ -n "${missing_commands}" ]; then
    err "cannot find command ${missing_commands}"
  fi
}

require tmux fzf zoxide

help() {
  cat <<EOF
tm
tmux session manager using fzf and zoxide. Requires tmux, zoxide and fzf to be
available in the system path.

USAGE

	tm [<command>] [<args>] [-h | --help]

COMMANDS
	open	Open a directory to a new session or an existing session
	close	Close a session
	rename	Rename a session

OPTIONS
	-h --help	Show help

For additional help use tm <command> -h
EOF
  exit 2
}

help_open() {
  cat <<EOF
tm open
Open a fuzzy finder with all the existing sessions, including directories
recorded by zoxide. The session path consists of a list of directories returned
by 'zoxide query -l' and any existing tmux sessions, which are represented as
'session://<session_name>'.

USAGE
	open <session_path>

OPTIONS
	-h --help	Show help

EOF
  exit 2
}

help_close() {
  cat <<EOF
tm close
Close the current session, or, if given a session name, close that session
instead.

USAGE
	close [<session_name>]

OPTIONS
	-h --help	Show help

EOF
  exit 2
}

help_rename() {
  cat <<EOF
tm rename
Rename the current session with the given new name.

USAGE
	rename <new_session_name>

OPTIONS
	-h --help	Show help

EOF
  exit 2
}

new_session() {
  tmux new-session -A -d -s "$1" -c "$2"
}

switch_session() {
  tmux switch -t "$1"
}

has_session() {
  tmux has-session -t "$1"
}

close_session() {
  [ "$#" -gt 1 ] && err "Too many arguments provided, use \`tm close <session_name>\`"

  for arg; do
    case "${arg}" in
      -h | --help) help_close ;;
      -*) err "Unknown option $1" ;;
    esac
  done

  if [ -z "$1" ]; then
    tmux kill-session
  else
    tmux kill-session -t "$1"
  fi
}

open_session() {
  [ "$#" -gt 1 ] && err "Too many arguments provided, use \`tm open <session_path>\`"

  [ -z "$1" ] && session="$(basename "$(pwd)")" || session="$(basename "$1")"

  if ! has_session "${session}" 2>/dev/null; then
    new_session "${session}" "$1"
  fi

  switch_session "${session}"
}

get_existing_sessions() {
  tmux ls | sed 's/:.*$//' | sed 's/^/session:\/\//'
}

session_opener() {
  for arg; do
    case "${arg}" in
      -h | --help) help_open ;;
      -*) err "Unknown option $1" ;;
    esac
  done

  session="$(printf "%s\n%s" "$(get_existing_sessions)" "$(zoxide query -l)" | fzf --reverse)"
  open_session "${session}"
  exit 0
}

rename_session() {
  [ -z "$1" ] && err "No session name given"

  for arg; do
    case "${arg}" in
      -h | --help) help_rename ;;
      -*) err "Unknown option $1" ;;
    esac
  done

  tmux rename-session "$1"
  exit 0
}

enum() {
  enum_str="$1"
  shift
  for arg; do
    enum_str="${enum_str}|${arg}"
  done

  printf "^(%s)$" "${enum_str}"
}

parse_command() {
  if printf "%s" "$1" | grep -qE "$2"; then
    readonly CMD="$1"
  fi
}

tm() {
  [ "$#" -eq 0 ] && help

  commands="$(enum open rename close)"

  for arg; do
    if [ -z "${CMD}" ]; then
      parse_command "${arg}" "${commands}"
      shift
    fi
  done

  case "${CMD}" in
    open) session_opener "$@" ;;
    close) close_session "$@" ;;
    rename) rename_session "$@" ;;
    *)
      printf "error: %s\n" "Unknown command"
      help
      ;;
  esac
}

tm "$@"
