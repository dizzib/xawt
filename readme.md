# xawt - X11 active window trigger
[![Build Status](https://travis-ci.org/dizzib/xawt.svg?branch=master)](https://travis-ci.org/dizzib/xawt)

* run shell commands when a window receives or loses focus
* optional delay
* optional retry period for failed commands

I use it to prevent too many idling applications from surreptitiously
stealing cpu cycles, but you may find it useful in other ways.

## install globally and run

With [node.js] installed on the target [X11] box:

    $ npm install -g xawt            # might need to prefix with sudo
    $ xawt

You should see `echo` commands run whenever the window focus changes.

## configure

On its first run xawt copies the [default configuration file] to
`$XDG_CONFIG_HOME/xawt.conf` which [defaults to][$XDG_CONFIG_HOME]
`$HOME/.config/xawt.conf`. Edit this [leanconf] file with one or more rules:

    /regex/:
      in: action
      out: action

* `regex` :
  a unique [JavaScript regular expression]
* `in:` :
  (optional) action to perform when regex matches the title of a window receiving focus (activating).
* `out:` :
  (optional) action to perform when regex matches the title of a window losing focus (de-activating).
* `action` :
  either the shell command to run immediately, or

      command: shell-command
      delay: delay-secs
      retry: retry-secs

  * `delay:` : (optional) number of seconds to wait before running the shell
    command, as long as the window's focus remains unchanged.
    If not supplied, a value of 0 is used.
  * `retry:` : (optional) number of seconds to wait before retrying a failed
    shell command. If not supplied, a failed command is never retried.

Commands can include [parenthesised substring matches] by the `$` symbol where
`$1` is the first submatch, `$2` the second, etc.

    # xawt.conf example configuration

    # freeze Firefox (after 10 seconds) unless it has the focus
    /- (Mozilla Firefox|Vimperator)$/:
      in: pkill -CONT firefox
      out:
        command: pkill -STOP firefox
        delay: 10

    # unpause any virtualbox guest immediately on gaining focus
    /^(\w+) \[Paused\] - Oracle VM VirtualBox$/:
      in: vboxmanage controlvm $1 resume

    # unconditionally pause virtualbox guest 30 seconds after losing focus
    /^(HERBERT|SANDPIT) \[Running\] - Oracle VM VirtualBox$/:
      out:
        command: vboxmanage controlvm $1 pause
        delay: 30

    # pause virtualbox guest 60 seconds after losing focus unless vlc is running,
    # in which case keep retrying every 90 seconds until vlc closes.
    /^(SWEEP) \[Running\] - Oracle VM VirtualBox$/:
      out:
        command: (! vboxmanage guestcontrol $1 run --wait-stdout --exe /bin/pgrep -- arg0 vlc) && vboxmanage controlvm $1 pause
        delay: 60
        retry: 90

## options

    $ xawt --help
    Usage: xawt [Options]

    Options:

      -h, --help                output usage information
      -V, --version             output the version number
      -c, --config-path [path]  path to configuration file (default:~/.config/xawt.conf)
      -d, --dry-run             trace commands without executing
      -v, --verbose             emit detailed trace for debugging

## developer build and run

    $ git clone --branch=dev https://github.com/dizzib/xawt.git
    $ cd xawt
    $ npm install     # install dependencies
    $ npm test        # build all and run tests
    $ npm start       # start the task runner and dry-run xawt

## license

[MIT](./LICENSE)

[$XDG_CONFIG_HOME]: http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
[default configuration file]: ./app/default.conf
[leanconf]: https://github.com/dizzib/leanconf
[node.js]: http://nodejs.org
[parenthesised substring matches]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#Using_parenthesized_substring_matches
[JavaScript regular expression]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
[X11]: https://en.wikipedia.org/wiki/X_Window_System
