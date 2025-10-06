# project_zero

A learning Gleam project where I make an overly complicated todo app!

## Development

There's a makefile which runs the dev server and restarts each file change. It
builds on the local project dep Olive. Olive does class reloading on file change!
Gleam is generally real fast so these reloads are almost never noticeable.
NOTE: This does mean that anything which recompiles main will need to restart
the Olive server


```sh
make run   # Run the project
gleam test  # Run the tests
```
