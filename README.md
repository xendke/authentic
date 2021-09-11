# Authentic

A Time-based One Time Password Client (2FA) for elementary OS

## DISCLAIMER:

The "secrets" given by the user and used by this application are not saved.

## Screenshot

![screenshot](https://github.com/xendke/authentic/blob/master/screenshot.png?raw=true)

## Building, Testing, and Installation

Run `meson build` to configure the build environment:

    meson build --prefix=/usr

This command creates a `build` directory. For all following commands, change to
the build directory before running them.

To build the app, use `ninja`:

    ninja

To install, use `ninja install`

    ninja install

## TODO:

- Refreshing TOTP (working)
- QR Reader (URI needed for now)
- Saving URIs/Secrets safely.
