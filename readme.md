## xawt - X11 active window trigger
[![Build Status](https://travis-ci.org/dizzib/xawt.svg?branch=master)](https://travis-ci.org/dizzib/xawt)

* run shell commands when a window receives or loses focus
* optional delay

Use it to prevent idling background applications from surreptitiously
stealing your cpu cycles.

## install globally and run

With [node.js] installed on the target [X11] box:

    $ npm install -g xawt            # might need to prefix with sudo
    $ xawt

You should see `echo` commands run whenever the window focus changes.

## configure

On its first run xawt copies the [default configuration file] to
`$XDG_CONFIG_HOME/xawt.yml` which [defaults to][$XDG_CONFIG_HOME] `$HOME/.config/xawt.yml`.
Edit this [yaml] file with one or more rules:

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
  either the shell command to run immediately, or `{delay: dly, command: cmd}`
  to run cmd after dly seconds unless the window's focus subsequently changes
  before cmd has run.

Commands can include [parenthesised substring matches] by the `$` symbol where
`$1` is the first submatch, `$2` the second, etc.

    # xawt.yml configuration example

    # freeze Firefox unless it has the focus
    /- (Mozilla Firefox|Vimperator)$/:
      in: pkill -SIGCONT firefox
      out: pkill -SIGSTOP firefox

    # unpause any virtualbox guest immediately on gaining focus
    /^(\w+) \[Paused\] - Oracle VM VirtualBox$/:
      in: vboxmanage controlvm $1 resume

    # unconditionally pause virtualbox guest 30 seconds after losing focus
    /^(HERBERT|SANDPIT) \[Running\] - Oracle VM VirtualBox$/:
      out:
        command: vboxmanage controlvm $1 pause
        delay: 30

    # pause virtualbox guest 60 seconds after losing focus unless vlc is running
    /^(SWEEP) \[Running\] - Oracle VM VirtualBox$/:
      out:
        command: (! vboxmanage guestcontrol $1 exec --wait-stdout --image /bin/pgrep -- vlc) && vboxmanage controlvm $1 pause
        delay: 60

## options

    $ xawt --help
    Usage: xawt [Options]

    Options:

      -h, --help                output usage information
      -V, --version             output the version number
      -c, --config-path [path]  path to configuration file (default:~/.config/xawt.yml)
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
[default configuration file]: ./app/default-config.yml
[node.js]: http://nodejs.org
[parenthesised substring matches]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#Using_parenthesized_substring_matches
[JavaScript regular expression]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
[X11]: https://en.wikipedia.org/wiki/X_Window_System
[yaml]: https://en.wikipedia.org/wiki/YAML
