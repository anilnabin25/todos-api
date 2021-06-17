set -e

echo "=== Copy .env and database.yml  ==="
cp .env.sample .env
cp config/database.sample.yml config/database.yml
echo "=== copy is done!  ==="

echo "=== Execute docker-compose build... ==="
docker-compose build
echo "=== docker-compose build is done!! ==="

echo "=== Installing Gems ==="
docker-compose run --rm app bundle install
echo "=== Done Installing Gems ==="

echo "=== Creating DB ...==="
sleep 10
docker-compose run --rm app bundle exec rails db:create
docker-compose run --rm app bundle exec rails db:migrate
docker-compose run --rm app bundle exec rails db:seed
echo "=== Creating DB is done! ==="
