# Greencity project

## Project Overview

The main aim of “GreenCity” project is to teach people in a playful and challenging way to have an eco-friendly lifestyle. A user can view on the map places that have some eco-initiatives or suggest discounts for being environmentally aware (for instance, coffee shops that give a discount if a customer comes with their own cup). А user can start doing an environment-friendly habit and track their progress with a habit tracker.

There are three parts: `backcore`, `backuser`, `frontend`


### Key Features

1. **Authentication and Registration:** Users can create an account.

2. А user can **start doing an environment-friendly habit** and **track their progress** with a habit tracker..

---

## DATABASE

> Before you begin, make sure your PostgreSQL database contains a database with a name like 'greencity'.

- The ```./db/init/data.sql``` file contains a script for creating database.
- The ```./db/data/**``` files contains a snapshot of the database tables.

---

## BACK-END

### Technical Details

- **Back-end programming language:** Java
- **Database:** PostgreSQL
- **Required Tools:** Java 21, Maven 3.9.7

### **Database Configuration**

In the application's configuration files
```text
core/src/main/resources/application-dev.properties
```
the path and database connection details are obtained from the following environment variables:

- DATASOURCE_URL - connection string to the database; for example
```text
jdbc:postgresql://postgres_server:5432/greencity
```
- DATASOURCE_USER - user name;
- DATASOURCE_PASSWORD - user password;

You must also specify the following environment variables:
```text
EMAIL_ADDRESS=gcdocker@gmail.com
EMAIL_PASSWORD=GreenCity7_Docker
GOOGLE_CLIENT_ID=129513550972-ffqpdq6e5basbn9pcdvroqf20ffcg09f.apps.googleusercontent.com
GOOGLE_API_KEY=AIzaSyCN1iqS_3TcZ2d2d5SZwUnTOqDiRmwG13c
GOOGLE_CLIENT_ID_MANAGER=236387301472-5fqure34s5flqp7fl94jiem8todv64d5.apps.googleusercontent.com
CLOUD_NAME=greencity-lv448java
API_KEY=675739387883727
API_SECRET=3nJsbn28s_RWJJo67kG8OY-ywJ8
MAX_FILE_SIZE=2MB
MAX_REQUEST_SIZE=2MB
BUCKET_NAME=staging.greencity-c5a3a.appspot.com
STATIC_URL=https://storage.cloud.google.com/
GOOGLE_APPLICATION_CREDENTIALS=/app/google-creds.json
DEFAULT_PROFILE_PICTURE=https://storage.cloud.google.com/staging.greencity-c5a3a.appspot.com/3d1a4092-c31e-4a0f-814b-57a0e4de0851
AZURE_CONNECTION_STRING=DefaultEndpointsProtocol=https;AccountName=csb10032000a548f571;AccountKey=qV2VLVZlzxuEq8zGTgeiVE9puJiELNRPZcB9YgTSjZ3wKdWVA7kPjSOp6ESHlVMTJfHxB6N+iaV2TOlbe1GTvg==
EndpointSuffix=core.windows.net
AZURE_CONTAINER_NAME=allfiles
CHAT_LINK=http://chat:8030
PROFILE=docker
```

### Running the Project

**Build the Project:**

Execute the following commands in the `backcore/backuser` project part:
```bash
mvn formatter:format
mvn clean package
```

3. **Run the Project:**

After successful building, run the ```core.jar``` file from the ```./core/target``` folder:
```bash
java -jar ./core/target/core.jar
```

- The application ```'backcore'``` will start on 8080 port.
- The application ```'backuser'``` will start on 8060 port.

---

> Press CTRL+C to stop applications.

We wish you success in the "Greencity" project!

---


