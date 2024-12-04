FROM node:22-slim AS base
WORKDIR /app

FROM base as dev
ENV NODE_ENV=development
COPY package.json .
RUN npm install

FROM base as build
COPY package.json .
COPY package-lock.json .
RUN npm ci
COPY . .
RUN npm run build

FROM base as prod
COPY --from=build /app/build .
COPY --from=build /app/build.info .
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json .
COPY --from=build /app/package-lock.json .
ENV NODE_ENV=production
EXPOSE 3000
CMD npm run start