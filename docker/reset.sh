read -p "Are you sure to initialize docker image?  (y/n)" initialize < /dev/tty
case $initialize in
  y|Y) docker-compose down --rmi all || true ;;
esac
