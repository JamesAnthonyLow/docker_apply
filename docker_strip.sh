#!/bin/bash
print_help(){
  echo "Usage: ./docker_strip.sh <Base tar> <Patch tar>"
  exit 1
}
if [ -z $1 ] || [ -z $2 ]; then
  print_help
fi
base_tar=$1
child_tar=$2

mkdir tmp 
cd tmp

tar_fetch_all(){
  local tar=$1
  tar xf ../$tar
}

tar_contains(){
  local tar=$1
  local file=$2
  tar -tf ../$tar $file >/dev/null 2>&1
}

tar_make_patch(){
  echo "Type name of patch:"
  read name
  tar cf ../${name} *
}

tar_fetch_all $child_tar

IFS=', ' read -a layers <<< $(cat manifest.json | sed -e 's/^.*Layers//' | tr -d '"':\[\]\})

for l in ${layers[@]}; do
  if tar_contains $base_tar $l; then
    rm -r $(echo $l | cut -d'/' -f1)
  fi
done

tar_make_patch

cd ../
rm -r tmp
