#!/bin/bash
user=$1
for repo in $(curl -sL "https://hub.docker.com/v2/repositories/${user}?page_size=100" | jq -r .results[0].name); do 
  tags=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags?page_size=100" | jq -r '.results[] | .name')
  for tag in ${tags}; do
    variant=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}" | jq -r '.images[] | select (.variant != null) |  (.os + "/" + .architecture + "/" + .variant)')
    tempfile1=$(mktemp)
    echo "FROM ${repo}:${tag}" >"${tempfile1}"
    echo docker buildx build -t "${user}/${repo}:${tag}" --output "type=image,push=false" -f "${tempfile1}" --platform "${variant}" .
    no_variant=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}" | jq -r '.images[] | select (.variant == null) |  (.os + "/" + .architecture)')
    for item in $no_variant; do
      tempfile2=$(mktemp)
      echo "FROM ${repo}:${tag}" >"${tempfile2}"
      echo docker buildx build -t "${user}/${repo}:${tag}" --output "type=image,push=false" -f "${tempfile2}" --platform "${item}" . -f "${tempfile2}"
    done
  done
done
