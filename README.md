# Icarus::Mod::Tools

a CLI tool for managing the Icarus Mods Database

## Requirements

To use this app, you'll need to obtain the following:

- A Github ACCESS_TOKEN (doesn't need access to any repos, this is used purely to make API calls)
- A Google Cloud Platform credentials `keyfile.json`
- Ruby 3.1 (or greater)

If you aren't sure how to obtain these credentials, please see:

- [Google Cloud Platform](https://cloud.google.com/docs/authentication/getting-started)
- [GitHub](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)

I _highly_ recommend using WSL2 on Windows, or a Linux distro on your machine. This app has not been tested on Windows.

## Installation

`gem install Icarus-Mod-Tools`

## Configuration

Create a file called `.imtconfig.json` in your home directory with the following, replacing the CAPITALIZED values with the values provided by the above links:

```json
{
  "firebase": {
    "credentials": {
      "copy your Google Cloud Platform keyfile.json here and remove this line": null
    },
    "collections": {
      "modinfo": "meta/modinfo",
      "repositories": "meta/repos",
      "mods": "mods"
    }
  },
  "github": {
    "token": "YOUR-GITHUB-TOKEN"
  }
}
```

_Hint: Copy the contents of your Google Cloud Platform `keyfile.json` into the `credentials` section of the above file._

## Usage

imt [options] [command]

### Commands

```sh
  imt add             # Adds entries to the databases
  imt list            # Lists the databases
  imt sync            # Syncs the databases
```

#### `imt add`

```sh
Commands:
  imt add help [COMMAND]  # Describe subcommands or one specific subcommand
  imt add modinfo         # Adds an entry to 'meta/modinfo/list'
  imt add repos           # Adds an entry to 'meta/repos/list'

Options:
  -v, [--verbose], [--no-verbose]  # Increase verbosity. May be repeated for even more verbosity.
                                   # Default: [true]
```

#### `imt list`

```sh
Commands:
  imt list help [COMMAND]  # Describe subcommands or one specific subcommand
  imt list modinfo         # Displays data from 'meta/modinfo/list'
  imt list mods            # Displays data from 'mods'
  imt list repos           # Displays data from 'meta/repos/list'

Options:
  -v, [--verbose], [--no-verbose]  # Increase verbosity. May be repeated for even more verbosity.
                                   # Default: [true]
```

#### `imt sync`

```sh
Commands:
  imt sync help [COMMAND]  # Describe subcommands or one specific subcommand
  imt sync modinfo         # Reads from 'meta/repos/list' and Syncs any modinfo files we find (github only for now)
  imt sync mods            # Reads from 'meta/modinfo/list' and updates the 'mods' database accordingly

Options:
  -v, [--verbose], [--no-verbose]  # Increase verbosity. May be repeated for even more verbosity.
                                   # Default: [true]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DonovanMods/icarus-mod-tools.
