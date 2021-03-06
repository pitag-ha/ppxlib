#!/bin/bash
set -euo pipefail


pull () {
  case $1 in
    janestreet|js)
      JS_GREP_ARG=""
      ;;
    *)
      JS_GREP_ARG="-v"
      ;;
  esac

  # Get a first list of revdeps candidate
  REVDEPS=$(opam list -s --depends-on ppxlib.0.13.0 --coinstallable-with ocaml.4.10.0)

  TRUE_REVDEPS=""
  for d in $REVDEPS
  do
    ALL_VERS=$(opam show --field=all-versions $d)
    LATEST_VER=${ALL_VERS##* }
    deps=$(opam show --field=depends: $d.$LATEST_VER)
    # Filter out packages that come from Janestreet mono repo and
    # packages whose latest version isn't a rev dep anymore
    if (opam show --field=maintainer: $d.$LATEST_VER | grep $JS_GREP_ARG "janestreet" > /dev/null) &&
      (echo "$deps" | grep "ppxlib" > /dev/null) &&
      (echo "$deps" | grep "dune" > /dev/null)
    then
      TRUE_REVDEPS="$TRUE_REVDEPS $d.$LATEST_VER"
    fi
  done

  if [ -z "$TRUE_REVDEPS" ]
  then
    echo "No revdeps found for ppxlib"
    exit 1
  fi

  mkdir -p dunireverse
  cd dunireverse

  for d in $TRUE_REVDEPS
  do
    echo "$d" >> .deps
  done

  cat .deps

  for d in $TRUE_REVDEPS
  do
    basename=${d%%.*}
    ver=${d#*.}
    tmp=$(opam show --field=dev-repo: $d)
    tmp=${tmp%\"}
    tmp=${tmp#\"}
    DEV_REPO=${tmp#git+}
    git clone $DEV_REPO $basename
    case $1 in
      janestreet|js)
        # To checkout to the latest released version
        cd $basename
        git checkout $ver || git checkout v$ver
        cd ..
        ;;
      *)
        :
        ;;
    esac
  done
  cd ..
}

install_deps_opam () {
  cd dunireverse
  for dir in */
  do
    basename=${dir%/}
    echo "Installing $basename dependencies"
    opam install --deps-only $basename/$basename.opam -y || opam install --deps-only $basename/opam -y
  done
}

install_deps_duniverse () {
  # Generate a dummy opam file
  echo 'opam-version: "2.0"' > dunireverse.opam
  echo "depends: [" >> dunireverse.opam
  echo "  \"ocaml\" {=\"4.10.0\"}" >> dunireverse.opam
  cat dunireverse/.deps | while read line
  do
    basename=${line%%.*}
    ver=${line#*.}
    echo "  \"$basename\" {=\"$ver\"}" >> dunireverse.opam
  done
  echo "]" >> dunireverse.opam
  duniverse init
  duniverse opam-install || true
  duniverse pull --no-cache

  cat dunireverse/.deps | while read line
  do
    rm -r duniverse/$line
  done
}

install_deps () {
  case $1 in
    duniverse)
      install_deps_duniverse
      ;;
    opam|*)
      install_deps_opam
      ;;
  esac
}

build () {
  PACKAGES="ppxlib"
  cd dunireverse
  for dir in */
  do
    basename=${dir%/}
    PACKAGES="$PACKAGES,$basename"
  done
  cd ..
  dune build -p $PACKAGES
}

if [ $# -ne 2 ]
then
  SND_ARG=""
else
  SND_ARG="$2"
fi

case $1 in
  "")
    pull
    install_deps
    build
    ;;
  pull)
    pull "$SND_ARG"
    ;;
  install-deps)
    install_deps "$SND_ARG"
    ;;
  build)
    build
    ;;
  *)
    echo "invalid subcommand $1"
    exit 1
esac
