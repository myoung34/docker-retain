#!/bin/bash
user=$1
page_size=100

[[ ! -d tmp ]] && mkdir tmp

for repo in $(curl -sL "https://hub.docker.com/v2/repositories/${user}?page_size=${page_size}" | jq -r .results[].name); do 
  tags=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags?page_size=${page_size}" | jq -r '.results[] | .name')
  for tag in ${tags}; do
    tags=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}?page_size=${page_size}")
    variant=$(echo "${tags}" | jq -r '.images[] | select (.variant != null) |  (.os + "/" + .architecture + "/" + .variant)')
    no_variant=$(echo "${tags}" | jq -r '.images[] | select (.variant == null) |  (.os + "/" + .architecture)')
    platforms=$(echo "${variant},${no_variant}" | tr '\n' ',' | sed 's/,$//g')
    tempdir="tmp/${variant}"
    mkdir -p "${tempdir}"
    tempfile="${tempdir}/${repo}_${tag}"
    echo "FROM ${user}/${repo}:${tag}" >"${tempfile}"
    docker buildx build -t "$(uuidgen)" --output "type=image,push=false" -f "${tempfile}" --platform "${platforms}" .
  done
done
