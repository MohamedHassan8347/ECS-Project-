# ---------- build stage ----------
FROM node:22-alpine AS build
WORKDIR /app

# Copy only dependency manifests first (better caching)
COPY app/package.json app/yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy the source
COPY app/ ./

ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL


# Umami build normally runs check-db; skip it in CI builds
RUN yarn build-db && yarn build-tracker && yarn build-geo && yarn build-app


# ---------- production stage ----------
FROM node:22-alpine AS production
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy only what we need at runtime
COPY --from=build /app ./

# Install only production deps (reduces image size)
RUN yarn install --frozen-lockfile --production && yarn cache clean

EXPOSE 3000

# Umami typically runs via yarn start
CMD ["yarn", "start"]
