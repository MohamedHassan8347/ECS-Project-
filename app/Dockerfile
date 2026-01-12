ARG NODE_IMAGE_VERSION="22-alpine"

# ---------- deps stage ----------
FROM node:${NODE_IMAGE_VERSION} AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile

# ---------- builder stage ----------
FROM node:${NODE_IMAGE_VERSION} AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .
COPY docker/middleware.ts ./src

ARG BASE_PATH
ARG DATABASE_URL="postgresql://user:pass@localhost:5432/dummy"

ENV BASE_PATH="${BASE_PATH}"
ENV DATABASE_URL="${DATABASE_URL}"
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

RUN npm run build-docker

# ---------- production stage ----------
FROM node:${NODE_IMAGE_VERSION} AS runner
WORKDIR /app

ARG PRISMA_VERSION="6.19.0"
ARG NODE_OPTIONS

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS=$NODE_OPTIONS

RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 nextjs \
 && apk add --no-cache curl \
 && npm install -g pnpm

RUN pnpm --allow-build='@prisma/engines' add \
    npm-run-all dotenv chalk semver \
    prisma@${PRISMA_VERSION} \
    @prisma/adapter-pg@${PRISMA_VERSION}

COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/generated ./generated
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000
ENV HOSTNAME=0.0.0.0
ENV PORT=3000

CMD ["pnpm", "start-docker"]
