set -a
source ./netbox_version.env
set +a

docker compose -f docker-compose.test.yml -f docker-compose.test.override.yml up -d --build --wait --wait-timeout 900

NETBOX_PLUGINS=($(python3 -c "import json; from configuration.configuration import PLUGINS; print(json.dumps(PLUGINS))" | jq -r '.[]'))
NETBOX_STATUS=$(curl -s http://127.0.0.1:8000/api/status/)


for i in ${NETBOX_PLUGINS[@]}; do
  RESULT=$(echo $NETBOX_STATUS | jq -r --arg key "$i" '."installed-apps" | has($key)')
  if $RESULT; then
    echo "INFO: Plugin $i found"
  else
    echo "ERROR: Plugin $i was not found in /api/status/" >&2
    exit 1
  fi
done

echo "INFO: SUCCESS\!\! All tests passed"

docker compose -f docker-compose.test.yml down -v
docker compose -f docker-compose.test.yml rm
