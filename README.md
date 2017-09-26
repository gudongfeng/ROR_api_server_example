# Helper commands

- Docker
  - Start the server
    - `docker-compose up web`
  - Run the rspec test
    - `docker-compose run test`
  - Run the generate the apipie test
    - `docker-compose run apipie_test`
  - Create the database
    - `docker-compose run web rails db:create`
  - Migrate the database
    - `docker-compose run web rails db:migrate`
  - Point the docker cli to docker virutal machine
    - `eval $(docker-machine env talkwithsam)`

- HTTP Code

```
  400 :bad_request
  401 :unauthorized
  403 :forbidden
  404 :not_found
  412 :precondition_failed
  422 :unprocessable_entity
```

- APIPIE
  - Generate the APIPIE examples according to the rspec test
    - `APIPIE_RECORD=examples rspec`
  - Url for checking the API
    - `http://localhost:3000/api_doc`

- Controller
  - General controller errors
    - `error 400, 'parameter missing'`
    - `error 401, 'unauthorized, account not found'`
    - `error 412, 'account not activate'`
    - `error 422, 'parameter value error'`

- Sidekiq
  - Run sidekiq in test environment
    - `bundle exec sidekiq --environment test`

- Postgres
  - Start the local postgresql server
    - `brew services start postgresql`
  - Stop the local postgresql server
    - `brew services stop postgresql`

- Redis
  - Run redis server
    - `brew services start redis`
  - Stop redis server
    - `brew services stop redis`

- ActionCable
  - Process for making a call
    1. TUTOR: At least one tutor need to subscribe the tutor channel: `app/cable_client/tutor_subscribe`
    2. STUDENT: Student subscribe to the student channel **and** make a request: `app/cable_client/student_request`
    3. TUTOR: Response to the student request
    4. SYSTEM: Send notification to both student and tutor saying that call will start in several seconds
    4. SYSTEM: Initialize a twilio video conference call **and** send the credential informations to both tutor and student
    5. SYSTEM: Initialize the end calling active job that terminate the conference call in certain minutes
    6. SYSTEM: Notify student and tutor before the call end
    7. STUDENT: (OPTION) Renew the call
    8. SYSTEM: Terminate the conference room

