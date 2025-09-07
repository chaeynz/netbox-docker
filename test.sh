#!/bin/bash

echo "▶️ $0 $*"

teardown() {
  docker compose -f docker-compose.test.yml down -v
}

_BOLD=$(tput bold)
_RED=$(tput setaf 1)
_GREEN=$(tput setaf 2)
_YELLOW=$(tput setaf 3)
_CYAN=$(tput setaf 6)
_CLEAR=$(tput sgr0)

set -a
source ./netbox_version.env
set +a

NETBOX_PLUGINS=($(python3 -c "import json; from configuration.configuration import PLUGINS; print(json.dumps(PLUGINS))" | jq -r '.[]'))

echo "${_GREEN}INFO: Detected the following plugins in config: ${NETBOX_PLUGINS[@]}${_CLEAR}"

echo "${_GREEN}INFO: Dumping plugin_requirements.txt:${_CLEAR}"
cat ./plugin_requirements.txt

docker compose -f docker-compose.test.yml -f docker-compose.test.override.yml up -d --build --wait --wait-timeout 900

NETBOX_STATUS=$(curl -s http://127.0.0.1:8000/api/status/)
echo "${_CYAN}DEBUG: NETBOX_STATUS=$NETBOX_STATUS${_CLEAR}"

FAILED=""

for plugin in ${NETBOX_PLUGINS[@]}; do
  RESULT=$(echo $NETBOX_STATUS | jq -r --arg key "$plugin" '."installed_apps" | has($key)')
  echo "${_CYAN}DEBUG: RESULT=$RESULT${_CLEAR}"
  if [ "$RESULT" == "" ]; then
    echo "${_RED}ERROR: The application didn't come up {_CLEAR}" >&2
    teardown
    exit 1
  fi
  if [ "$RESULT" == "true" ]; then
    echo "${_GREEN}INFO: Plugin $plugin found in Netbox deployment${_CLEAR}"
  else
    FAILED=true
    if [ "${1}" == "--release" ]; then
      echo "${_RED}ERROR: Plugin $plugin was not found in /api/status/${_CLEAR}" >&2
      teardown
      exit 1
    else
      echo "${_YELLOW}WARNING: Plugin $plugin was not found in /api/status/ | IGNORING because --release is not set${_CLEAR}" >&2
    fi
  fi
done

if [ "$FAILED" != "true" ]; then
  echo "${_GREEN}INFO: SUCCESS!! All tests passed${_CLEAR}"
fi

teardown
