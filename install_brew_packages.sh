run() {
    # Run the compilation process.
    # cd $PLATFORM_CACHE_DIR || exit 1;

    # if .linuxbrew folder exists, we can assume everything is installed
    cache_folder="${PLATFORM_CACHE_DIR}/.linuxbrew"
    cache_file="$cache_folder/cached_components"
    echo "Cache folder $cache_folder"
    echo "Cache file $cache_file"
    echo "Current folder $(pwd)"
    install_brew
    load_brew

    install_components $@

}

copy_lib_to_cache() {
    echo "Copy to cache..."
    #cp -Rf $PLATFORM_APP_DIR/.linuxbrew $PLATFORM_CACHE_DIR
}

copy_lib_from_cache() {
    echo "Copy from cache..."
    #cp -Rf $PLATFORM_CACHE_DIR/.linuxbrew $PLATFORM_APP_DIR
}

install_brew() {
    echo "Installing homebrew"
    mkdir -p $PLATFORM_APP_DIR/.linuxbrew

    echo "Downloading tarball from master repository"
    curl -SsL https://github.com/Homebrew/brew/tarball/master -o brew.tar.gz
    
    echo "Unpacking into .linuxbrew folder"
    tar xzf brew.tar.gz --strip-components 1 -C $PLATFORM_APP_DIR/.linuxbrew/
    rm brew.tar.gz
}

load_brew() {
    eval $($PLATFORM_APP_DIR/.linuxbrew/bin/brew shellenv)
    brew analytics off
}

install_components() {
  components_to_install="$@"
  echo "Installing components: '$components_to_install'"
  for f in $components_to_install
  do
      echo "Installing component: '$f'"
      install_component $f
  done
}

install_component() {
    brew install --build-bottle $1
    brew bottle $1
}

write_profile() {
  touch $PLATFORM_APP_DIR/.profile
  echo 'export HOMEBREW_CELLAR="$PLATFORM_APP_DIR/.linuxbrew/Cellar";' >> $PLATFORM_APP_DIR/.profile
  echo 'export HOMEBREW_REPOSITORY="$PLATFORM_APP_DIR/.linuxbrew/Homebrew";' >> $PLATFORM_APP_DIR/.profile
  echo 'export PATH="$PLATFORM_APP_DIR/.linuxbrew/bin:$PLATFORM_APP_DIR/.linuxbrew/sbin${PATH+:$PATH}";' >> $PLATFORM_APP_DIR/.profile
  echo 'export MANPATH="$PLATFORM_APP_DIR/.linuxbrew/share/man${MANPATH+:$MANPATH}:";' >> $PLATFORM_APP_DIR/.profile
  echo 'export INFOPATH="$PLATFORM_APP_DIR/.linuxbrew/share/info:${INFOPATH:-}";' >> $PLATFORM_APP_DIR/.profile
}

echo "Installing: $@"
run $@
