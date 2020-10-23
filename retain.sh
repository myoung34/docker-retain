#!/bin/bash
user=$1
starting_char=$2
page_size=100

[[ ! -d tmp ]] && mkdir tmp

for repo in $(curl -sL "https://hub.docker.com/v2/repositories/${user}?page_size=${page_size}" | jq -r ".results[] | select(.name | startswith(\"$starting_char\")) | .name"); do 
  tags=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags?page_size=${page_size}" | jq -r '.results[] | .name')
  for tag in ${tags}; do
    _tags=$(curl -sL "https://hub.docker.com/v2/repositories/${user}/${repo}/tags/${tag}?page_size=${page_size}")
    variant=$(echo "${_tags}" | jq -r '.images[] | select (.variant != null) |  (.os + "/" + .architecture + "/" + .variant)')
    no_variant=$(echo "${_tags}" | jq -r '.images[] | select (.variant == null) |  (.os + "/" + .architecture)')
    platforms=$(echo "${variant},${no_variant}" | tr '\n' ',' | sed 's/^,//g'  | sed 's/,$//g' | tr -d '\n')
    tempfile=$(uuidgen)
    echo "FROM ${user}/${repo}:${tag}" >"${tempfile}"
    echo "Pulling ${user}/${repo}:${tag} with platforms ${platforms}"
    docker buildx build -f ${tempfile} -t $user/$repo:$tag --output "type=image,push=false" --platform ${platforms} . || :
  done
done
