## xawt - X11 active window trigger
[![Build Status](https://travis-ci.org/dizzib/xawt.svg?branch=master)](https://travis-ci.org/dizzib/xawt)

- run shell commands when a window receives or loses focus.

## install globally and run

With [node.js] installed on the target [X11] box:

    $ npm install -g xawt            # might need to prefix with sudo
    $ xawt

## configure

The configuration file is at `~/.config/xawt.yaml` unless
you've changed your [$XDG_CONFIG_HOME] variable.
This path can be overridden with the `-c` flag on the command line.

## options

    $ xawt --help
    Usage: xawt [Options]

    Options:

      -h, --help                output usage information
      -V, --version             output the version number
      -c, --config-path [path]  path to configuration file (default:~/.config/xawt.yaml)
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
