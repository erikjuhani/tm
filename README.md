# tm

tmux session manager using `fzf` and `zoxide`. Requires
[tmux](https://github.com/tmux/tmux/wiki/Installing),
[zoxide](https://github.com/ajeetdsouza/zoxide#installation) and
[fzf](https://github.com/junegunn/fzf#installation) to be available in the
system path.

The name abbreviation is from words *t*mux *m*anager.

## Installation

Easiest way to install `tm` is with [shm](https://github.com/erikjuhani/shm).

To install `shm` run either one of these oneliners:

curl:

```sh
curl -sSL https://raw.githubusercontent.com/erikjuhani/shm/main/shm.sh | sh
```

wget:

```sh
wget -qO- https://raw.githubusercontent.com/erikjuhani/shm/main/shm.sh | sh
```

then run:

```sh
shm get erikjuhani/tm
```

to get the latest version of `tm`.

## Usage

`tm` is best used as a popup for tmux. To use the `tm` opener with tmux, add
the following line to your `.tmux.conf` file (usually located in `~/.tmux.conf`):

```
bind-key -n C-f run-shell "tmux popup -E 'tm open || exit 0'"
```

In the above snippet, we bind the key Control+f to run a popup with the `tm open` command.

The `exit 0` code is used to prevent displaying errors if the exit code is
anything other than zero.

After saving the configuration file, you should source the configuration using
the tmux Command Key and run `:source ~/.tmux.conf`.

Now you should be ready to use `tm` with a tmux popup.

```sh
tm [<command>] [<args>] [-h | --help]
```

### Open

Open a fuzzy finder with all the existing sessions, including directories
recorded by zoxide. The session path consists of a list of directories returned
by `zoxide query -l` and any existing tmux sessions, which are represented as
`session://<session_name>`.

```
tm open <session_path>
```

### Close

Close the current session, or, if given a session name, close that session
instead.

```
tm close [<session_name>]
```

### Rename

Rename the current tmux session with the provided new name, or alternatively,
use the basename of the current working directory.

```
tm rename [<new_session_name>]
```
