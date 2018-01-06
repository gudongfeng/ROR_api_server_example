# Check the wiki for reference

API list: http://api.gdf.name/api_doc

# Run the server locally
## First time setup
1. Install Ruby, Bunlder, Rails and Postgresql
2. Create a new user in Postgresql according to [tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04)
3. Install all the necessary gems `bundle install`
  -  Install the pg dev package for pg gem `sudo apt-get install libpq-dev`
4. Go to the `ROR_api_server_example` project directory
5. Create the database `rails db:create`
6. Migrate the database `rails db:migrate`
 
## Run the server
`rails s`


# Run the server within Docker
- Install all the necessary package for `docker` and `docker-compose`
- Go to the `ROR_api_server_example` project directory
- Up the server `docker-compose up`
- (Optional) Run the server in background `docker-compose up -d`
