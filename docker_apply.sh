#!/bin/bash
# This script accepts a saved base image and a saved top layer produced
# with the docker_strip.sh script and produces a working docker image
print_help(){
  echo "Usage: ./docker_apply.sh <Base tar> <Patch tar>"
  exit 1
}
if [ -z $1 ] || [ -z $2 ]; then
  print_help
fi
base_tar=$1
patch_tar=$2

mkdir tmp 
cd tmp

tar_fetch_layer(){
  local tar=$1
  local layer=$(echo $2 | cut -d'/' -f1)
  tar xf ../$tar $layer
}

tar_fetch_all(){
  local tar=$1
  tar xf ../$tar
}

tar_contains(){
  local tar=$1
  local file=$2
  tar -tf ../$tar $file >/dev/null 2>&1
}

tar_make_img(){
  echo "Type name of new image:"
  read name
  tar cf ../${name} *
}

tar_fetch_all $patch_tar

IFS=', ' read -a layers <<< $(cat manifest.json | sed -e 's/^.*Layers//' | tr -d '"':\[\]\})
for i in ${!layers[@]}; do
  if ! tar_contains $patch_tar ${layers[$i]} ; then
    tar_fetch_layer $base_tar ${layers[$i]}
  fi
done

tar_make_img

cd ../
rm -r tmp
