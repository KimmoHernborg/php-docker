#!/usr/bin/env bash

# Log oneliner
log () { LOG_LEVEL=$2; if [ ! $LOG_LEVEL ]; then LOG_LEVEL="info"; fi; echo -e "\033[38;5;131m[${LOG_LEVEL}] \033[38;5;147m$1\033[0m"; }

# Variables
IMAGE_NAME="kimmohernborg/php-docker"
DOCKER_CMD="docker"
if [[ $1 != "" ]]; then EXECUTE=true; else EXECUTE=false; fi
#echo "EXECUTE = $EXECUTE"

log "Make sure you are logged in to Docker before running this script..."
echo

for folder in */ ; do
  TAG=$(echo "$folder" | grep -oE '[0-9.]+')
  if [[ $TAG == "5.6" || $TAG == "7.2" || $TAG == "7.3" || $TAG == "7.4" ]]; then continue; fi # Skip 5.6, 7.2, 7.3 and 7.4 (@todo remove from repo)

  pushd "$folder" || exit
  echo
  log "Build '$IMAGE_NAME:$TAG'" "build"
  log "$DOCKER_CMD build --pull -t \"$IMAGE_NAME:$TAG\" ." "cmd"
  if $EXECUTE; then $DOCKER_CMD build -t "$IMAGE_NAME:$TAG" .; fi
  echo
  log "Push '$IMAGE_NAME:$TAG'" "push"
  log "$DOCKER_CMD push \"$IMAGE_NAME:$TAG\"" "cmd"
  if $EXECUTE; then $DOCKER_CMD push "$IMAGE_NAME:$TAG"; fi
  popd || exit
done

echo
log "Tag LATEST image and push"
log "$DOCKER_CMD tag \"$IMAGE_NAME:$TAG\" \"$IMAGE_NAME:latest\"" "cmd"
if $EXECUTE; then $DOCKER_CMD tag "$IMAGE_NAME:$TAG" "$IMAGE_NAME:latest"; fi
log "$DOCKER_CMD push \"$IMAGE_NAME:latest\"" "cmd"
if $EXECUTE; then $DOCKER_CMD push "$IMAGE_NAME:latest"; fi
echo
log "Done!"
