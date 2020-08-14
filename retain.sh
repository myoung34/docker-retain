#!/bin/bash
user=$1

[[ ! -d tmp ]] && mkdir tmp

for repo in $(curl -sL "https://hub.docker.com/v2/repositories/${user}?page_size=100" | jq -r .results[0].name); do 
  tags=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags?page_size=100" | jq -r '.results[] | .name')
  for tag in ${tags}; do
    variant=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}" | jq -r '.images[] | select (.variant != null) |  (.os + "/" + .architecture + "/" + .variant)')
    no_variant=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}" | jq -r '.images[] | select (.variant == null) |  (.os + "/" + .architecture)')
    platforms=$(echo "${variant},${no_variant}" | tr '\n' ',' | sed 's/,$//g')
    tempdir="tmp/${variant}"
    mkdir -p "${tempdir}"
    tempfile="${tempdir}/${repo}_${tag}"
    echo "FROM ${user}/${repo}:${tag}" >"${tempfile}"
    docker buildx build -t "$(uuidgen)" --output "type=image,push=false" -f "${tempfile}" --platform "${platforms}" .
  done
done
