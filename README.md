# Heroku Buildpack for N|Solid

![N|Solid](NSolid.png)

This is the official Heroku buildpack for
[N|Solid](https://nodesource.com/products/nsolid)
apps.

The buildpack is based on the
[Heroku buildpack for Node.js](https://github.com/heroku/heroku-buildpack-nodejs).

For more information on the
[N|Solid product](https://nodesource.com/products/nsolid)
from
[NodeSource](https://nodesource.com/),
visit the
[N|Solid documentation site](https://docs.nodesource.com/nsolid).

## Documentation

To use this buildpack with your Node.js application, run the following command:

```
heroku buildpacks:set https://github.com/nodesource/heroku-buildpack-nsolid -a my-app-name
```

Since this buildpack is based on the
[Heroku buildpack for Node.js](https://github.com/heroku/heroku-buildpack-nodejs),
most of the documentation for that buildpack applies to this one. For more
information about using the Node.js buildpack on Heroku, see these Heroku Dev
Center articles:

- [Heroku Node.js Support](https://devcenter.heroku.com/articles/nodejs-support)
- [Getting Started with Node.js on Heroku](https://devcenter.heroku.com/articles/nodejs)

For more general information about buildpacks on Heroku:

- [Buildpacks](https://devcenter.heroku.com/articles/buildpacks)
- [Buildpack API](https://devcenter.heroku.com/articles/buildpack-api)


## Differences from the Heroku buildpack for Node.js

The primary difference between this buildpack and the Heroku buildpack for Node.js,
is that this buildpack will install N|Solid runtimes instead of Node.js runtimes.

The most current version of N|Solid runtimes is always selected, and the LTS
version (eg, 4.x, 6.x, 8.x) can be selected by setting the `engines.node`
property as described in the
[Heroku docs for specifying a Node.js version][engines.node].  To select a
particular LTS version, the `engines.node` property should be a string that
starts with the specific version.  For example, the following property values
all select the LTS 4.x version of N|Solid:

* `4`
* `4.x`
* `4.8.4`

If the first characters of the `engines.node` property do not match an existing
LTS version available, or if `engines.node` not specified at all, the most
recent supported LTS version will be selected.  For example, if LTS 4 and 6
versions are available, version 6 will be used unless the `engines.node`
property is to a string that starts with 4.

[engines.node]: https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version

## Locking to a buildpack version

In production, you frequently want to lock all of your dependencies - including
buildpacks - to a specific version. That way, you can regularly update and
test them, upgrading with confidence.

First, find the version you want from
[the list of buildpack tags](https://github.com/nodesource/heroku-buildpack-nsolid/tags)
which include `nsolid` in the tag name.
Then, specify that version with `buildpacks:set`:

```
heroku buildpacks:set https://github.com/nodesource/heroku-buildpack-nsolid#v111-nsolid-1 -a my-app-name
```

If you have trouble upgrading to the latest version of the buildpack, please
open an
[issue in the GitHub repo](https://github.com/nodesource/heroku-buildpack-nsolid/issues)
so we can assist.

### Chain Node with multiple buildpacks

This buildpack automatically exports node, npm, and any node_modules binaries
into the `$PATH` for easy use in subsequent buildpacks.

## Changes made to the Heroku Buildpack for Node.js files

The following files have been changed from the Heroku Buildpack for Node.js,
for this buildpack:

* `bin/compile` - calls `lib/nsolid.sh` to replace the `install_bins` function
  so that an N|Solid runtime is installed instead of Node.js
* `lib/nsolid.sh` - implements a new `install_bins` function to install the
  N|Solid runtime
* `test/run` - commented out some tests not applicable to this buildpack,
  and changed a few expectations of runtime versions installed
* `test/utils` - removed messages from graceful-fs in stderr

## Feedback

Having trouble? Dig it? Feature request?

- [GitHub issues](https://github.com/nodesource/heroku-buildpack-nsolid/issues)

## Hacking

To make changes to this buildpack, fork it on GitHub.
Push up changes to your fork, then create a new Heroku app to test it,
or configure an existing app to use your buildpack:

```
# Create a new Heroku app that uses your buildpack
heroku create --buildpack <your-github-url>

# Configure an existing Heroku app to use your buildpack
heroku buildpacks:set <your-github-url>

# You can also use a git branch!
heroku buildpacks:set <your-github-url>#your-branch
```

## Tests

The buildpack tests use [Docker](https://www.docker.com/) to simulate
Heroku's Cedar-14 and Heroku-16 containers.

To run the test suite:

```
make test
```

Or to just test in cedar or cedar-14:

```
make test-cedar-14
make test-heroku-16
```

The tests are run via the vendored
[shunit2](https://github.com/kward/shunit2)
test framework.
