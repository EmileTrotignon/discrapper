# Discrapper

This is a small bot that reads all the messages it can see in a discord server,
and put them into a sexp file.

To use it, you need to write a `config.ml` yourself. The values needed are
specified in the `config.mli` file.

- `token` this should your discord API auth token (you need to bring your own).
- `log_file` is the outgoing channel that is going to be used for logs.
- `command` is the string that will trigger the bot to start scrapping.

Then, you can compile and do : `dune exec discrapper -- data.sexp` and the
server will connect itself to server you invited it to (you also need to give
special permission to read the messages). Then type in a message the string
`Config.command` and the bot will start scrapping. Once it is done, the data
will be written to `data.sexp`, and the bot will exit.

The folder `display` contains an executable that does a demo of the data. It
will need some adaptation to be run on your server : namely to specify the id of
the channels whose information you want to display.

## Dependencies

- `ocaml-matplotlib` from here https://github.com/EmileTrotignon/ocaml-matplotlib
- `disml` from here https://github.com/EmileTrotignon/disml.
- `core`, `async`, `embedded_ocaml_templates`, `sexplib` from opam.