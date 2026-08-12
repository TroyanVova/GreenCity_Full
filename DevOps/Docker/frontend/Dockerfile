FROM node:14-alpine

WORKDIR /app

COPY apps/frontend/package*.json ./
RUN npm install
RUN npm install --save-dev @angular-devkit/build-angular

COPY apps/frontend/ ./

EXPOSE 4200

# Dev-режим з live reload (код монтується як volume у docker-compose.yml)
CMD ["npx", "ng", "serve", "--host", "0.0.0.0", "--disable-host-check", "--aot=false"]
