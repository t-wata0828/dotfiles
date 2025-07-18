# docker functions
dce() {
  local service="$1"
  shift
  docker compose exec "$service" bundle exec "$@"
}

dbash() {
  if [ $# -eq 1 ]; then
    docker compose exec -it $1 /bin/bash
  else
    echo "Sorry. Please enter one argument."
  fi
}
