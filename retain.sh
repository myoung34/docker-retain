#!/bin/bash
user=$1

mkdir tmp

for repo in $(curl -sL "https://hub.docker.com/v2/repositories/${user}?page_size=100" | jq -r .results[0].name); do 
  tags=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags?page_size=100" | jq -r '.results[] | .name')
  for tag in ${tags}; do
    variant=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}" | jq -r '.images[] | select (.variant != null) |  (.os + "/" + .architecture + "/" + .variant)')
    tempdir1="tmp/${variant}"
    mkdir -p "${tempdir1}"
    tempfile1="${tempdir1}/${repo}_${tag}"
    echo "FROM ${user}/${repo}:${tag}" >"${tempfile1}"
    docker buildx build -t "$(uuidgen)" --output "type=image,push=false" -f "${tempfile1}" --platform "${variant}" .
    no_variant=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}" | jq -r '.images[] | select (.variant == null) |  (.os + "/" + .architecture)')
    for item in $no_variant; do
      tempdir2="tmp/${variant}"
      mkdir -p "${tempdir2}"
      tempfile2="${tempdir2}/${repo}_${tag}"
      echo "FROM ${user}/${repo}:${tag}" >"${tempfile2}"
      docker buildx build -t "$(uuidgen)" --output "type=image,push=false" -f "${tempfile2}" --platform "${item}" . -f "${tempfile2}"
    done
  done
done
