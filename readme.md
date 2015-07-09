## xawt - X11 active window trigger
[![Build Status](https://travis-ci.org/dizzib/xawt.svg?branch=master)](https://travis-ci.org/dizzib/xawt)

- run shell commands when a window receives or loses focus.

## install globally

With [node.js] installed on the target [X11] box:

    $ npm install -g xawt            # might need to prefix with sudo

## get started

Create a configuration file at `~/.config/xawt.yml` (or wherever your
[$XDG_CONFIG_HOME] is pointing) with the following content:

    /(.*)/:             # regular expression to match any window title
      in: echo in @1    # run this command when any window receives Focus
      out: echo out @1  # run this command when any window loses Focus

Then start xawt:

    $ xawt

and you should see both `echo` commands run whenever the window focus changes.

## options

    $ xawt --help
    Usage: xawt [Options]

    Options:

      -h, --help                output usage information
      -V, --version             output the version number
      -c, --config-path [path]  path to configuration file (default:~/.config/xawt.yml)
      -d, --dry-run             bypass command execute
      -v, --verbose             emit detailed trace for debugging

## developer build and run

    $ git clone --branch=dev https://github.com/dizzib/xawt.git
    $ cd xawt
    $ npm install     # install dependencies
    $ npm start       # start the task runner
    xawt > b.a        # build all and run

## license

[MIT](./LICENSE)

[$XDG_CONFIG_HOME]: http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
[node.js]: http://nodejs.org
[X11]: https://en.wikipedia.org/wiki/X_Window_System
[yaml]: https://en.wikipedia.org/wiki/YAML
