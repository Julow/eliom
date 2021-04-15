# Eliom

Eliom is a framework for building client/server Web and mobile
applications in OCaml.
It transforms OCaml into a multi-tier language, making it possible to
implement both the server and client parts of a Web and mobile app
as a single program.
This simplifies a lot the communication between server and client.
Applications can run on any Web browser or mobile device (iOS,
Android), saving from the need to develop one version for each
platform.

Eliom has support for reactive pages (generated on server or client),
advanced session mechanism, server to client communication,
continuation based Web programming, etc.

Eliom is part of the [Ocsigen project][ocsigen].

## Installation Instructions

We recommend that you use the [OPAM package manager][opam] to install
Eliom. Once you [have installed OPAM][opaminst], all you have to do is
type:

    opam install eliom

If you want to compile manually,

 * run `make` to compile;
 * run `make PREFIX=${YOURPREFIX} install` (as root if necessary) to
   install; and
 * run `make PREFIX=${YOURPREFIX} uninstall` to uninstall everything.

## Testing locally

* Install Eliom.

* DEPRECATED Run `make run.local` or `make run.opt.local` in the Eliom source
  directory.

* DEPRECATED Open <http://localhost:8080/miniwiki> in your browser.

* DEPRECATED If the above does not work, look at the logs (see `local/var/log/`
  in the Eliom source directory) or run Eliom with either of the
  options `-v`, `-V` (verbose and debug mode, respectively).

* DEPRECATED Sources for this example may be found in the directory
  `tests/miniwiki`. A complete tutorial is
  [available online][tutorial]. For a testsuite, see
  <http://localhost:8080/>.

## Authors

* Vincent Balat
* Jérôme Vouillon
* Grégoire Henry
* Pierre Chambart
* Benedikt Becker
* Boris Yakobowski
* Hugo Heuzard
* Raphaël Proust
* Stéphane Glondu
* Gabriel Kerneis
* Denis Berthod
* Jaap Boender
* Simon Castellan
* Mauricio Fernandez
* Archibald Pontier
* Simon Castellan
* Jacques-Pascal Deplaix

[ocsigen]: https://www.ocsigen.org/
[tutorial]: https://ocsigen.org/tuto/
[opam]: https://opam.ocaml.org/
[opaminst]: https://opam.ocaml.org/doc/Install.html
