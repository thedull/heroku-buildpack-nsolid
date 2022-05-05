NSOLID_DEFAULT_LTS=gallium
NSOLID_DEFAULT_LTS_VERSION_MAJOR=16

NSOLID_METADATA_URL=https://nsolid-download.nodesource.com/download/metadata.json
NSOLID_METADATA_FILE=/tmp/nsolid-metadata.json
NSOLID_VERSIONS_FILE=/tmp/nsolid-versions.txt
NSOLID_VERSION_FILE=/tmp/nsolid-version.txt
NODE_VERSION_FILE=./node-version.txt

install_nsolid() {
  local version=${1:-16.x}
  local dir="$2"

  echo "Resolving node version $version"

  # get the N|Solid version
  curl --output $NSOLID_METADATA_FILE --silent --retry 5 --retry-max-time 15 $NSOLID_METADATA_URL
  $JQ --raw-output 'paths | .[0]' < $NSOLID_METADATA_FILE > $NSOLID_VERSIONS_FILE
  head -n 1 $NSOLID_VERSIONS_FILE > $NSOLID_VERSION_FILE
  local nsolid_version=`cat $NSOLID_VERSION_FILE`
  echo 'Using N|Solid version ' $nsolid_version

  # get the Node.js version number, set in number
  local lts=$NSOLID_DEFAULT_LTS
  local lts_version_major=$NSOLID_DEFAULT_LTS_VERSION_MAJOR
  if [[ $version =~ ^12 ]]; then
    lts=erbium
    lts_version_major=12
  elif [[ $version =~ ^14 ]]; then
    lts=fermium
    lts_version_major=14
  fi

  $JQ --raw-output ".[\"$nsolid_version\"] | .versions | keys | map(select(startswith(\"$lts_version_major\"))) | .[0]" < $NSOLID_METADATA_FILE > $NODE_VERSION_FILE
  number=`cat $NODE_VERSION_FILE`
  echo 'Using Node.js version ' $number

  # download and unpack the runtime
  url=https://s3-us-west-2.amazonaws.com/nodesource-public-downloads/$nsolid_version/artifacts/bundles/nsolid-bundle-v$nsolid_version-linux-x64/nsolid-v$nsolid_version-$lts-linux-x64.tar.gz

  echo "Downloading and installing node $number, nsolid $lts $nsolid_version..."
  local code=$(curl "$url" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/node.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "Unable to download nsolid: $code" && false
  fi
  tar xzf /tmp/node.tar.gz -C /tmp
  rm -rf $dir/*
  mv /tmp/nsolid-v$nsolid_version-$lts-$os-$cpu/* $dir
  chmod +x $dir/bin/*
}

install_bins() {
  local node_engine=$(read_json "$BUILD_DIR/package.json" ".engines.node")
  local npm_engine=$(read_json "$BUILD_DIR/package.json" ".engines.npm")
  local yarn_engine=$(read_json "$BUILD_DIR/package.json" ".engines.yarn")

  echo "engines.node (package.json):  ${node_engine:-unspecified}"

  echo "engines.npm (package.json):   ${npm_engine:-unspecified (use default)}"
  if $YARN; then
    echo "engines.yarn (package.json):  ${yarn_engine:-unspecified (use default)}"
  fi
  echo ""

  warn_node_engine "$node_engine"
  install_nsolid "$node_engine" "$BUILD_DIR/.heroku/node"
  install_npm "$npm_engine" "$BUILD_DIR/.heroku/node" $NPM_LOCK
  mcount "version.node.$(node --version)"

  # Download yarn if there is a yarn.lock file or if the user
  # has specified a version of yarn under "engines". We'll still
  # only install using yarn if there is a yarn.lock file
  if $YARN || [ -n "$yarn_engine" ]; then
    install_yarn "$BUILD_DIR/.heroku/yarn" "$yarn_engine"
  fi

  if $YARN; then
    mcount "version.yarn.$(yarn --version)"
  else
    mcount "version.npm.$(npm --version)"
  fi

  warn_old_npm
}
