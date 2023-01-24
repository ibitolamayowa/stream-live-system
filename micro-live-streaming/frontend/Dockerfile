# Build stage
FROM node:10.16-slim as build

RUN mkdir -p /frontend/src

WORKDIR /frontend/src

COPY . .

RUN npm install

RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=build /frontend/src/dist /usr/share/nginx/html
