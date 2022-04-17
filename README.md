# Crystal Kcov

Crystal Kcov is a shard that will generate code coverage reports of crystal specs.

This shard acts as a codified version of [this blog post](https://hannes.kaeufler.net/posts/measuring-code-coverage-in-crystal-with-kcov), and uses the [kcov](https://github.com/SimonKagstrom/kcov) tool for generating coverage reports of a compiled binary.

Consider donating to kcov from their [home page](https://simonkagstrom.github.io/kcov/).

## Installation

### Installing Kcov

This shard assumes that `kcov` command is on the `$PATH`. To install it, you can follow the install directions [here](https://github.com/SimonKagstrom/kcov/blob/master/INSTALL.md), or if running on ubuntu, you can try running:

```
> sudo apt-get install cmake make binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev
> git clone https://github.com/SimonKagstrom/kcov
> cd kcov
> cmake .
> make
> sudo make install
```

The last command will place the generated `kcov` binary into `/usr/local/bin`, but the binary will already exist in `kcov/src` if you'd like to place it somewhere on your `$PATH` manually.

### Crystal Kcov

1. Add the dependency to your `shard.yml`:

   ```yaml
   developer_dependencies:
     crystal-kcov:
       github: vici37/crystal-kcov
   ```

2. Run `shards install`

## Usage / Help

NOTE: Command line arguments are liable to change. I chose silly names and didn't give them much thought.

```
> ./bin/crkcov -h
Usage: ./bin/crkcov [args]
-h, --help                       Show this message
--kcov-args ARGS                 Arguments to be passed to kcov
--executable-args ARGS           Arguments to be passed to executable
--build-args ARGS                Arguments to be passed to crystal as it's compiling the specs (i.e. compiler args could be here)
--kcov-executable PATH           Path to kcov executable to use, if not on PATH
--include-override SRC           Path override for kcovs --include-path. Will implicitly be set to 'src/' already. Use this command to change that
--output                         Outputs the basic results of the coverage tests to terminal
--output-json                    Outputs the generated coverage json file to stdout
--cleanup-coverage-after         Delete the coverage directory at the end of running. Useful when paired with --output or --output-json to maintain a clean directory
--cleanup-coverage-before        Delete the coverage directory before running. Useful to make sure only latest report exists
--coverage-dir DIRECTORY         The name of the output coverage directory, defaults to 'coverage'
--fail-below-low                 Emits a non-zero exit status if coverage is below the 'low' threshold (default 25%)
--fail-below-high                Emits a non-zero exit status if coverage is below the 'high' threshold (default 75%)
--suppress                       Don't emit spec output (still exits with non-zero if specs fail)
--build-only                     Only build the spec binary, skip running
--run-only                       Only run the spec binary (should only be run after --build-only has run)
--name NAME                      Optional name for the executable (will show up in coverage HTML)
--verbose                        Output verbose logging
```

## Contributing

1. Fork it (<https://github.com/your-github-user/crystal-kcov/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Troy Sornson](https://github.com/vici37) - creator and maintainer
