# ---- Build stage ----
FROM node:16-bullseye AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npx ng build --prod

# ---- Run stage ----
FROM nginx:1.25-alpine
COPY --from=build /app/dist/GreenCityClient /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

