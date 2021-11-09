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

## Usage

NOTE: Command line arguments are liable to change. I chose silly names and didn't give them much thought.

```
> ./bin/crkcov -h # get usage info
> ./bin/crkcov --output # Runs tests, generates coverage report under `coverage` by default
> ./bin/crkcov --kcov-args '--limits=75,90' # pass arguments to kcov command, this one sets low and high limits to 75% and 90%, respctively
> ./bin/crkcov --fail-below-low # runs tests and outputs non-zero exit code if coverage is below low threshold
```

## Contributing

1. Fork it (<https://github.com/your-github-user/crystal-kcov/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Troy Sornson](https://github.com/vici37) - creator and maintainer
