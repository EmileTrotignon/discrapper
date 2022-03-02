(lang dune 2.9)

(name discrapper)

(generate_opam_files true)

(package
 (name discrapper)
 (synopsis "A discord bot")
 (description "Gets all the messages from the server into an archive.")
 (depends
  (dune
   (>= 2.9))))

(using menhir 2.1)
