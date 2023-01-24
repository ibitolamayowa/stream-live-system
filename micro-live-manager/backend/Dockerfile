# Build stage
FROM node:10.16-slim as build

RUN mkdir -p /backend/src

WORKDIR /backend/src

COPY . .

RUN npm install

RUN npm run build

# Production stage
FROM node:10.16-slim

COPY --from=build /backend/src/dist /backend/src

CMD ["npm", "run", "start:prod"]
