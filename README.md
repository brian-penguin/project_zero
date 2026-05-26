# project_zero

A learning Gleam project where I make an overly complicated todo app!

## Development

I've removed olive and the makefile now so the new methodology is to use a dev specific version of the server which will
automatically reload the app with the exception of anything inside the main function. This won't need a separate process and
can be run with `gleam dev`

```sh
bin/dev-server # Run the project
bin/test  # Run the tests
```

To make a new migration and generate the sql automatically we are using a couple of different libraries
golang-migrate to manage migrations, Pog to do the sql interfacing, and Squirell to auto generate the decoders https://github.com/golang-migrate/migrate

the `migrate` cli tool comes from this package. I haven't yet figured out how to manage that in production so we shall see
```sh
brew install golang-migrate
```


```sh
bin/new-migration
bin/db-migrate
# Make sure we can rollback and forward
bin/db-rollback
bin/db-migrate

# Generate the new queries in our sql namespace using Squirell
bin/generate-sql-queries
```

