# frozen_string_literal: true

# .gitignore
GITIGNORED_FILES = <<~HEREDOC.strip_heredoc
    config/database.yml
    .env
  #{'  '}
    # MacOS
    .DS_Store
HEREDOC

append_file '.gitignore', GITIGNORED_FILES

create_file '.dockerignore', <<~HEREDOC.strip_heredoc
  /tmp/pids
  /public/assets
  /public/packs
  /public/packs-test
  .env
  .DS_Store
  .bin
  .git
  .gitignore
  .bundleignore
  .bundle
  .byebug_history
  .rspec
  tmp
  log
  test
  config/deploy
  node_modules
  yarn-error.log
  coverage/
HEREDOC

file '.rubocop.yml', <<~HEREDOC.strip_heredoc
    require:
      - rubocop-rails
      - rubocop-performance
      - rubocop-rspec
  #{'  '}
    AllCops:
      TargetRubyVersion: 3.0.1
      NewCops: enable
      Exclude:
        - db/schema.rb
        - bin/**/*
        - vendor/**/*
        - log/**/*
        - tmp/**/*
        - node_modules/**/*
        - template.rb
        - template-api.rb
  #{'  '}
    # Allowed environments
    Rails/UnknownEnv:
      Environments:
        - production
        - staging
        - development
        - test
  #{'  '}
    # Nested module syntax is fine, just be careful with
    # scoping, i.e. on include
    Style/ClassAndModuleChildren:
      Enabled: false
  #{'  '}
    # Never break line due to length, except in data
    # vim: set wrap
    Layout/LineLength:
      Max: 120
      Exclude:
        - spec/**/*
  #{'  '}
    # Rails controllers and such
    Metrics/MethodLength:
      Max: 30
  #{'  '}
    # Disable BlockLength cop only for spec directory
    Metrics/BlockLength:
      Exclude:
        - spec/**/*
        - app/admin/**/*
        - config/**/*
  #{'  '}
    # Use and/or for flow control, but not in boolean assignments
    # http://devblog.avdi.org/2010/08/02/using-and-and-or-in-ruby/
    Style/AndOr:
      Enabled: false
  #{'  '}
    # Use not with .select and flow control
    Style/Not:
      Enabled: false
  #{'  '}
    # Use { only for single line blocks, but allow block content on its own line to keep line length short
    # each { |l|
    #   l.apply_long_method_name
    # }
    Style/BlockDelimiters:
      Enabled: false
  #{'  '}
    # Do not use lambda
    Style/Lambda:
      Enabled: false
  #{'  '}
    # Allow TODO instead of requiring TODO:
    Style/CommentAnnotation:
      Enabled: false
  #{'  '}
    # Do not write 1234 as 1_234
    Style/NumericLiterals:
      Enabled: false
  #{'  '}
    # Relax for controllers with multiple formats
    Metrics/AbcSize:
      Max: 40
  #{'  '}
    # Too spammy
    Style/Documentation:
      Enabled: false
  #{'  '}
    # Will probably be default in ruby 3
    Style/FrozenStringLiteralComment:
      Enabled: false
  #{'  '}
    # Use raise if you expect to catch the expception
    Style/SignalException:
      Enabled: false
  #{'  '}
    # False positive for if var = value
    Lint/AssignmentInCondition:
      Enabled: false
  #{'  '}
    # Too much manual horizontal alignment
    Layout/HashAlignment:
      Enabled: false
  #{'  '}
    Layout/ArrayAlignment:
      Enabled: false
  #{'  '}
    Layout/EmptyLineAfterMagicComment:
      Enabled: false
  #{'  '}
    # Vim prefers fixed indent, avoid manual vertical alignment
    Layout/ParameterAlignment:
      Enabled: true
      EnforcedStyle: with_fixed_indentation
  #{'  '}
    Layout/MultilineMethodCallIndentation:
      EnforcedStyle: indented
  #{'  '}
    # Load order is important
    Bundler/OrderedGems:
      Enabled: false
  #{'  '}
    Rails/HttpPositionalArguments:
      Enabled: false
  #{'  '}
    Metrics/ClassLength:
      Max: 150
  #{'  '}
    RSpec/ImplicitExpect:
      EnforcedStyle: should
  #{'  '}
    Layout/SpaceInsideHashLiteralBraces:
      EnforcedStyle: no_space
  #{'  '}
    Naming/VariableNumber:
      EnforcedStyle: snake_case
  #{'  '}
    RSpec/NestedGroups:
      Max: 4
HEREDOC

# copy database.yml to sample file
run 'cp config/database.yml config/database.sample.yml'

# Create directory for github workflows and add deploy script
run 'mkdir -p .github/workflows'
file '.github/workflows/tests.yml', <<~HEREDOC.strip_heredoc
    name: PROJECT_NAME Lint and Tests
    on:
      push:
        branches:
          - develop
      pull_request:
        types: [opened, synchronize, reopened]
  #{'  '}
    jobs:
      rubocop-test:
        name: Rubocop
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v2
  #{'  '}
          - uses: ruby/setup-ruby@v1
            with:
              bundler-cache: true
  #{'  '}
          - name: Check code
            run: bundle exec rubocop
  #{'  '}
      rspec-test:
        name: RSpec
        needs: rubocop-test
        runs-on: ubuntu-latest
        env:
          RAILS_ENV: test
          DB_HOST: 127.0.0.1
          DB_USER: root
          DB_PASSWORD: msql_strong_password
          DB_NAME: PROJECT_NAME_app_test
        services:
          mysql:
            image: mysql:5.7
            env:
              MYSQL_ROOT_PASSWORD: msql_strong_password
            ports:
              - 3306
            options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
        steps:
          - uses: actions/checkout@v2
  #{'  '}
          - name: Copy database yml
            run: mv ./config/database.ci.yml ./config/database.yml
  #{'  '}
          - name: Copy env file
            run: mv .env.sample .env
  #{'  '}
          - uses: ruby/setup-ruby@v1
            with:
              bundler-cache: true
  #{'  '}
          - name: Get Yarn Cache
            id: yarn-cache
            run: echo "::set-output name=dir::$(yarn cache dir)"
  #{'  '}
          - name: Cache Node Modules
            id: node-modules-cache
            uses: actions/cache@v2
            with:
              path: ${{ steps.yarn-cache.outputs.dir }}
              key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
              restore-keys: |
                ${{ runner.os }}-yarn-
          - name: Cache Assets
            id: assets-cache
            uses: actions/cache@v2
            with:
              path: public/packs-test
              key: ${{ runner.os }}-assets-${{ steps.extract_branch.outputs.branch }}
              restore-keys: |
                ${{ runner.os }}-assets-
          - name: Yarn Install
            run: bin/rails yarn:install
  #{'  '}
          - name: Compile Assets
            shell: bash
            run: |
              if [[ ! -d public/packs-test ]]; then
                bin/rails webpacker:compile
              else
                echo "No need to compile assets."
              fi
          - name: Setup DB
            run: bin/rails db:create db:migrate
            env:
              DB_PORT: ${{ job.services.mysql.ports[3306] }}
  #{'  '}
          - name: Run tests
            env:
              DB_PORT: ${{ job.services.mysql.ports[3306] }}
            run: bundle exec rspec
HEREDOC

file '.github/workflows/staging_deployment.yml', <<~HEREDOC.strip_heredoc
    name: PROJECT_NAME Staging Deployment
    on:
      workflow_run:
        workflows:
          - PROJECT_NAME Lint and Tests
        branches:
          - develop
        types:
          - completed
      workflow_dispatch:
        inputs:
          deploy:
            description: Deploy to staging
            required: true
  #{'  '}
    jobs:
      deploy-to-staging:
        name: Deploy to Staging
        runs-on: ubuntu-latest
        if: ${{ github.event.workflow_run.conclusion == 'success' }}
        steps:
        - uses: actions/checkout@v2
  #{'  '}
        - name: Copy database.yml
          run: cp ./config/database.sample.yml ./config/database.yml
  #{'  '}
        - name: Login to Github Registry
          run: echo ${{ secrets.GITHUB_TOKEN }} | docker login docker.pkg.github.com -u ${{ secrets.GIT_USER_NAME }} --password-stdin
  #{'  '}
        - name: Pull Image from Github Registry
          run: docker pull docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_stag || true
  #{'  '}
        - name: Build Docker Image
          run: |
            docker build \\
            --build-arg PRE_COMPILE=true \\
            --build-arg RAILS_ENV=staging \\
            --build-arg SECRET_KEY_BASE=${{ secrets.SECRET_KEY_BASE_STAG }} \\
            --build-arg DATABASE_URL=${{ secrets.DATABASE_URL_STAG }} \\
            --build-arg LANG=${{ secrets.LANG }} \\
            --build-arg RAILS_LOG_TO_STDOUT=${{ secrets.RAILS_LOG_TO_STDOUT }} \\
            --build-arg TZ=${{ secrets.TZ }} \\
            -f docker/Dockerfile.prod \\
            -t docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_stag .
        - name: Push To Git Registry
          run: docker push docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_stag
  #{'  '}
        - name: Login to heroku registry
          run: echo ${{ secrets.HEROKU_API_KEY }} | docker login registry.heroku.com -u ${{ secrets.HEROKU_LOGIN }} --password-stdin
  #{'  '}
        - name: Push Docker Image to Heroku Registry
          run: |
            docker tag docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_stag registry.heroku.com/${{secrets.HEROKU_APP_NAME_STAG}}/web
            docker push registry.heroku.com/${{ secrets.HEROKU_APP_NAME_STAG }}/web
        - name: Release App
          run: |
            echo machine api.heroku.com >> ~/.netrc
            echo "  login ${{ secrets.HEROKU_LOGIN }}" >> ~/.netrc
            echo "  password ${{ secrets.HEROKU_API_KEY }}" >> ~/.netrc
            heroku container:release web --app ${{ secrets.HEROKU_APP_NAME_STAG }}
            heroku run rails db:migrate --app ${{ secrets.HEROKU_APP_NAME_STAG }}
        - name: Notify slack on success
          if: success()
          uses: rtCamp/action-slack-notify@v2
          env:
            SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
            SLACK_CHANNEL: ${{ secrets.SLACK_CHANNEL }}
            SLACK_MESSAGE: "Deployment to staging succeded"
            SLACK_ICON: ":namespace:"
            SLACK_USERNAME: "Deployer"
  #{'  '}
        - name: Notify slack on failure
          if: failure()
          uses: rtCamp/action-slack-notify@v2
          env:
            SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
            SLACK_CHANNEL: ${{ secrets.SLACK_CHANNEL }}
            SLACK_MESSAGE: "Deployment to staging failed"
            SLACK_ICON: ":namespace:"
            SLACK_USERNAME: "Deployer"
            SLACK_COLOR: "#FF0000"
HEREDOC

file '.github/workflows/release.yml', <<~HEREDOC.strip_heredoc
    name: PROJECT_NAME Production deployment
    on:
      push:
        branches:
          - master
  #{'  '}
    jobs:
      deploy-to-production:
        name: Deploy to Production
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v2
  #{'  '}
        - name: Copy database.yml
          run: mv ./config/database.sample.yml ./config/database.yml
  #{'  '}
        - name: Login To GitHub Registry
          run: echo ${{ secrets.GITHUB_TOKEN }} | docker login docker.pkg.github.com -u ${{ secrets.GIT_USER_NAME }} --password-stdin
  #{'  '}
        - name: Pull Image from Github Registry
          run: docker pull docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_prod || true
  #{'  '}
        - name: Build Docker Image
          run: |
            docker build \\
            --build-arg PRE_COMPILE=true \\
            --build-arg RAILS_ENV=production \\
            --build-arg SECRET_KEY_BASE=${{ secrets.SECRET_KEY_BASE_PROD }} \\
            --build-arg DATABASE_URL=${{ secrets.DATABASE_URL_PROD }} \\
            --build-arg LANG=${{ secrets.LANG }} \\
            --build-arg RAILS_LOG_TO_STDOUT=${{ secrets.RAILS_LOG_TO_STDOUT }} \\
            --build-arg TZ=${{ secrets.TZ }} \\
            --cache-from=docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_prod \\
            -f docker/Dockerfile.prod \\
            -t docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_prod .
        - name: Push To Git Registry
          run: docker push docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_prod
  #{'  '}
        - name: Login to Heroku Registry
          run: echo ${{ secrets.HEROKU_API_KEY }} | docker login registry.heroku.com -u ${{ secrets.HEROKU_LOGIN }} --password-stdin
  #{'  '}
        - name: Push Docker Image to Heroku Registry
          run: |
            docker tag docker.pkg.github.com/$GITHUB_REPOSITORY/PROJECT_NAME_prod registry.heroku.com/${{secrets.HEROKU_APP_NAME_PROD}}/web
            docker push registry.heroku.com/${{ secrets.HEROKU_APP_NAME_PROD }}/web
        - name: Release App
          run: |
            echo machine api.heroku.com >> ~/.netrc
            echo "  login ${{ secrets.HEROKU_LOGIN }}" >> ~/.netrc
            echo "  password ${{ secrets.HEROKU_API_KEY }}" >> ~/.netrc
            heroku container:release web --app ${{ secrets.HEROKU_APP_NAME_PROD }}
            heroku run rails db:migrate --app ${{ secrets.HEROKU_APP_NAME_PROD }}
        - name: Notify slack on success
          if: success()
          uses: rtCamp/action-slack-notify@v2
          env:
            SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
            SLACK_CHANNEL: ${{ secrets.SLACK_CHANNEL }}
            SLACK_MESSAGE: "Deployment to production succeded"
            SLACK_ICON: ":namespace:"
            SLACK_USERNAME: "Deployer"
  #{'  '}
        - name: Notify slack on failure
          if: failure()
          uses: rtCamp/action-slack-notify@v2
          env:
            SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
            SLACK_CHANNEL: ${{ secrets.SLACK_CHANNEL }}
            SLACK_MESSAGE: "Deployment to production failed"
            SLACK_ICON: ":namespace:"
            SLACK_USERNAME: "Deployer"
            SLACK_COLOR: "#FF0000"
HEREDOC

# create docker directory and add required files
run 'mkdir -p docker'

# add Dockerfile.dev
create_file './docker/Dockerfile.dev', <<~HEREDOC.strip_heredoc
    FROM docker.pkg.github.com/namespace-team/ruby-alpine-mysql/ruby3.0.1-alpine-mysql:latest
    LABEL maintainer="Namespace Inc"
  #{'  '}
    ENV LANG=C.UTF-8 \\
        LC_ALL=C.UTF-8 \\
        LC_CTYPE="utf-8"
  #{'  '}
    ENV APP="/PROJECT_NAME" \\
        CONTAINER_ROOT="./" \\
        NOKOGIRI_OPTION="--use-system-libraries \\
                         --with-xml2-config=/usr/bin/xml2-config \\
                         --with-xslt-config=/usr/bin/xslt-config" \\
        MYSQL_PORT=3307 \\
        SERVER_PORT=3000 \\
        WEBPACKER_PORT=3035
  #{'  '}
    WORKDIR $APP
  #{'  '}
    COPY Gemfile Gemfile.lock $CONTAINER_ROOT
  #{'  '}
    COPY package.json yarn.lock $CONTAINER_ROOT
    RUN yarn
  #{'  '}
    COPY . $CONTAINER_ROOT
  #{'  '}
    ENV RAILS_SERVE_STATIC_FILES=true \\
        PORT=$SERVER_PORT \\
        TERM=xterm \\
        RAILS_ENV=development
  #{'  '}
    EXPOSE $SERVER_PORT
    EXPOSE $MYSQL_PORT
    EXPOSE $WEBPACKER_PORT
HEREDOC

# add Dockerfile.prod
create_file './docker/Dockerfile.prod', <<~HEREDOC
    FROM docker.pkg.github.com/namespace-team/ruby-alpine-mysql/ruby3.0.1-alpine-mysql:latest
    LABEL maintainer="Namespace Inc"
  #{'  '}
    WORKDIR "/PROJECT_NAME"
  #{'  '}
    COPY Gemfile Gemfile.lock ./
    RUN bundle install --jobs=4 --retry=9
  #{'  '}
    COPY package.json yarn.lock ./
    RUN yarn
  #{'  '}
    COPY . ./
  #{'  '}
    ARG RAILS_ENV=development
    ARG SECRET_KEY_BASE
    ARG RAILS_LOG_TO_STDOUT
    ARG PRE_COMPILE=false
    ARG DATABASE_URL
    ARG LANG
    ARG TZ
  #{'  '}
    ENV LANG=C.UTF-8 \\
        LC_ALL=C.UTF-8 \\
        LC_CTYPE="utf-8" \\
        RAILS_SERVE_STATIC_FILES=true \\
        PORT=$SERVER_PORT \\
        TERM=xterm \\
        RAILS_ENV=$RAILS_ENV \\
        SECRET_KEY_BASE=$SECRET_KEY_BASE \\
        DATABASE_URL=$DATABASE_URL \\
        LANG=$LANG \\
        RAILS_LOG_TO_STDOUT=$RAILS_LOG_TO_STDOUT \\
        TZ=$TZ \\
        NOKOGIRI_OPTION="--use-system-libraries \\
                         --with-xml2-config=/usr/bin/xml2-config \\
                         --with-xslt-config=/usr/bin/xslt-config" \\
        MYSQL_PORT=3307 \\
        SERVER_PORT=3000 \\
        WEBPACKER_PORT=3035
  #{'  '}
    RUN bundle exec rake assets:precompile --trace
  #{'  '}
    EXPOSE $SERVER_PORT
    EXPOSE $MYSQL_PORT
    EXPOSE $WEBPACKER_PORT
    CMD ["rails", "server", "-b", "0.0.0.0"]
HEREDOC

# create bootstrap template for docker
create_file './docker/bootstrap.sh', <<~CODE
    set -e
  #{'  '}
    echo "=== Copy .env and database.yml  ==="
    cp .env.sample .env
    cp config/database.sample.yml config/database.yml
    echo "=== copy is done!  ==="
  #{'  '}
    echo "=== Execute docker-compose build... ==="
    docker-compose build
    echo "=== docker-compose build is done!! ==="
  #{'  '}
    echo "=== Installing Gems ==="
    docker-compose run --rm app bundle install
    echo "=== Done Installing Gems ==="
  #{'  '}
    echo "=== Creating DB ...==="
    sleep 10
    docker-compose run --rm app bundle exec rails db:create
    docker-compose run --rm app bundle exec rails db:migrate
    docker-compose run --rm app bundle exec rails db:seed
    echo "=== Creating DB is done! ==="
CODE

# create mysql configs
create_file './docker/my.cnf', <<~CODE
    [mysql]
    default-character-set=utf8
  #{'  '}
    [mysqld]
    character-set-server=utf8
    collation-server=utf8_general_ci
  #{'  '}
    [client]
    default-character-set=utf8
CODE

create_file './docker/mysql.env', <<~CODE
  MYSQL_ROOT_PASSWORD=root
  MYSQL_DATABASE=PROJECT_NAME_development
  MYSQL_USER=root
  MYSQL_PASSWORD=password
CODE

# create database.ci.yml
create_file 'config/database.ci.yml', <<~HEREDOC.strip_heredoc
  test:
    adapter: mysql2
    encoding: utf8mb4
    collation: utf8mb4_unicode_ci
    database: <%= ENV['DB_NAME'] || 'PROJECT_NAME_test' %>
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    host: <%= ENV['DB_HOST'] || 'localhost' %>
    username: <%= ENV['DB_USER'] %>
    password: <%= ENV['DB_PASSWORD'] %>
    port: <%= ENV['DB_PORT'] || 3306 %>
HEREDOC

create_file './docker/reset.sh', <<~CODE
  read -p "Are you sure to initialize docker image?  (y/n)" initialize < /dev/tty
  case $initialize in
    y|Y) docker-compose down --rmi all || true ;;
  esac
CODE

create_file 'docker-compose.yml', <<~CODE
    version: '3.2'
  #{'  '}
    services:
      database:
        restart: always
        image: mysql:5.7
        ports:
          - 3307:3306
        volumes:
          - mysql-volume:/var/lib/mysql
          - ./docker/my.cnf:/etc/mysql/conf.d/my.conf
        env_file:
          - docker/mysql.env
  #{'  '}
      app: &application_base
        build:
          context: .
          dockerfile: ./docker/Dockerfile.dev
        command: >
          bash -c "
            rm -f tmp/pids/server.pid &&
            bundle exec rails s -p 3000 -b '0.0.0.0'
          "
        ports:
          - "3000:3000"
        volumes:
          - .:/PROJECT_NAME
          - "bundle:/usr/local/bundle"
          - node_modules:/PROJECT_NAME/node_modules
        depends_on:
          - database
        tty: true
        stdin_open: true
  #{'  '}
      webpacker:
        <<: *application_base
        command: "bin/webpack-dev-server"
        ports:
          - "3035:3035"
        depends_on:
          - app
  #{'  '}
    volumes:
      bundle:
        driver: local
      node_modules:
        driver: local
      mysql-volume:
        driver: local
CODE

# # Add design files
# # rename application.css to application.css.scss
# run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"

# # add spacing variables in custom scss file
# run "mkdir -p app/assets/stylesheets/custom"
# create_file 'app/assets/stylesheets/custom/spacing.scss', <<-CODE
# $spacing-xxs: 4px;
# $spacing-xs: 8px;
# $spacing-s: 12px;
# $spacing-m: 16px;
# $spacing-l: 20px;
# $spacing-xl: 24px;
# $spacing-xxl: 28px;
# $spacing-xxl-2: 32px;
# $spacing-xxl-3: 36px;
# $spacing-xxl-4: 40px;
# $spacing-xxl-5: 44px;
# $spacing-xxl-6: 48px;
# $spacing-xxl-7: 52px;
# $spacing-xxl-8: 56px;
# $spacing-xxl-9: 60px;
# CODE

# # append importing spacing to application.css.scss
# append_file 'app/assets/stylesheets/application.css.scss', "@import 'custom/spacing';\n"

# # Generate a static controller
# generate(:controller, "static_pages", "index")
# route "root 'static_pages#index'"

after_bundle do
  run 'spring stop'
  run 'bundle add dotenv-rails --group "development, test" --skip-install'
  run 'bundle add rspec-rails --group "development, test" --skip-install'
  run 'bundle add rubocop --group "development" --skip-install'
  run 'bundle add rubocop-performance --group "development" --skip-install'
  run 'bundle add rubocop-rails --group "development" --skip-install'
  run 'bundle add rubocop-rspec --group "development" --skip-install'
  run 'bundle add annotate --group "development" --skip-install'
  run 'bundle add factory_bot_rails --group "development, test" --skip-install'
  run 'bundle add rubycritic --group "development, test" --skip-install'
  run 'bundle add ffaker --group "development, test" --skip-install'
  run 'bundle add pry-rails --group "development, test" --skip-install'
  run 'bundle add simplecov --group "development, test" --skip-install'
end

create_file '.env.sample'

run 'cp .env.sample .env'

after_bundle do
  run 'bundle install'
  run 'bundle exec rails generate rspec:install'
  run 'bundle exec rubocop --auto-correct'
  # add default url in localhost
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
  # random rspec run
  append_file '.rspec', <<~HEREDOC.strip_heredoc
    --order random
  HEREDOC
end

after_bundle do
  project_name = @app_name.classify
  run "ruby -pi.bak -e 'gsub(/password:/, \"password: root\")' config/database.sample.yml"
  run "ruby -pi.bak -e 'gsub(/adapter: mysql2/, \"adapter: mysql2\n  host: database\n  collation: utf8mb4_unicode_ci\")' config/database.sample.yml"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' .github/workflows/tests.yml"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' .github/workflows/release.yml"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' .github/workflows/staging_deployment.yml"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' ./docker/Dockerfile.dev"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' ./docker/Dockerfile.prod"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' ./docker/mysql.env"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' docker-compose.yml"
  run "ruby -pi.bak -e 'gsub(/PROJECT_NAME/, \"#{project_name}\")' config/database.ci.yml"
  run "ruby -pi.bak -e 'gsub(/host: localhost/, \"host: webpacker\")' ./config/webpacker.yml"
  run "ruby -pi.bak -e 'gsub(/check_yarn_integrity: true/, \"check_yarn_integrity: false\")' ./config/webpacker.yml"
  run 'rm ./config/database.sample.yml.bak'
  run 'rm ./config/webpacker.yml.bak'
  run 'rm ./config/database.ci.yml.bak'
  run 'rm ./.github/workflows/tests.yml.bak'
  run 'rm ./.github/workflows/release.yml.bak'
  run 'rm ./.github/workflows/staging_deployment.yml.bak'
  run 'rm ./docker/Dockerfile.dev.bak'
  run 'rm ./docker/Dockerfile.prod.bak'
  run 'rm ./docker/mysql.env.bak'
  run 'rm docker-compose.yml.bak'
end
