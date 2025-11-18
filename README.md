# project_zero

A learning Gleam project where I make an overly complicated todo app!

## Development

There's a makefile which runs the dev server and restarts each file change. It
builds on the local project dep Olive. Olive does class reloading on file change!
Gleam is generally real fast so these reloads are almost never noticeable.
NOTE: This does mean that anything which recompiles main will need to restart
the Olive server


```sh
bin/dev-server # Run the project
bin/test  # Run the tests
```

To make a new migration and generate the sql automatically we are using a couple of different libraries
Cigogne to manage migrations, Pog to do the sql interfacing, and Squirell to auto generate the decoders
NOTE: Cigogne only supports migrations within a transaction and needs a bit more work to get working otherwise

```sh
bin/new-migration
bin/db-migrate
# Make sure we can rollback and forward
bin/db-rollback
bin/db-migrate

# Generate the new queries in our sql namespace using Squirell
bin/generate-sql-queries
```

