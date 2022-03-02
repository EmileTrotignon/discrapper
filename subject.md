# Web data managment project : Update discord API lib for OCaml

Discord is an instant messaging and digital distribution platform. It is very
popular, and features an API over HTTP that allow oneself to write bots.

OCaml is a very nice functionnal language, and there is a library called `Disml`
that provides OCaml abstractions to access the discord API. However, this
library has not been updated for 2 years, and the Discord API has moved quite a
bit since. My goal is therefore to fork this library and write an updated
version, both in term of OCaml abstractions and

## Async

OCaml has two libraries that provides asyncronous capabilities : `Async` and
`Lwt`.

Disml uses the least popular of the two : `Async`. One the objective of this
project would be to switch to `Lwt`, which would make it a lot easier to make
`Disml` interact with the wider OCaml environment.
It would also be possible to make `Disml` work with any of the two async libs,
as an extra objective.

## Safety

I have been using `Disml` for my own purposes for a while now, and sometimes
issues happen. For instance, it has happened to me that the bot triggers the
anti DOS security and gets banned for sending reapeated requests to the same
route too fast, even though there is a security against it in Disml. I plan to
try and understand why, and make it impossible for that to happen.

## New discord functionnality

I plan to support new discord functionnality, for instance threads. Threads
allows users to have sub-discussions inside a channel, and for now, bots written
with Disml offer no ways to interact with threads.
There may be other discord functionnality that Disml cannot access, and I plan
to support them.

## Documentation

I also plan to have more documentation than is currently available, both visible
for user, and for potential contributors.