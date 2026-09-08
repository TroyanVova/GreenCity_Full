# Greencity project

## Project Overview

The main aim of “GreenCity” project is to teach people in a playful and challenging way to have an eco-friendly lifestyle. A user can view on the map places that have some eco-initiatives or suggest discounts for being environmentally aware (for instance, coffee shops that give a discount if a customer comes with their own cup). А user can start doing an environment-friendly habit and track their progress with a habit tracker.

There are three parts: `backcore`, `backuser`, and `frontend`


### Key Features

1. **Authentication and Registration:** Users can create an account.

2. А user can **start doing an environment-friendly habit** and **track their progress** with a habit tracker..

---

## FRONT-END

### Technical Details

- **Front-end written on:** Angular CLI: 9.1.15;
- **Required Tools:** nodejs 14 version.

### Running the Project

**Download Dependencies:**

Execute the following commands:
```bash
npm install -g @angular/cli@9.1.15
npm install --save-dev @angular-devkit/build-angular
npm install
```

**Write the path to the backend servers** into the `'environment.ts'` file
```text
src/environments/environment.ts 
```
for example
```text
backendLink: 'http://localhost:8080/',
backendUserLink: 'http://localhost:8060/',
frontendLink: 'http://localhost:4200/',
socket: 'http://localhost:8080/socket',
```

**Run the Project:**

After successful building you could run the front-end in dev mode:

```bash
ng serve --aot=false --host 0.0.0.0 --disableHostCheck
```
```text
The application will start on 4200 port.
```

Notes

The project is at an early stage of development, at the moment the functionality works partially.
---

> Press CTRL+C to stop applications.

We wish you success in the "Greencity" project!

---


