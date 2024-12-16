FROM node:18-slim AS builder

WORKDIR /build
COPY package*.json ./
COPY pnpm-lock.yaml ./
RUN corepack enable pnpm && pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

FROM misskey/misskey:13.14.2

WORKDIR /misskey

# Copy built files from builder
COPY --from=builder /build/dist/index.js /railway/

# Install jq for package.json modification
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Modify package.json for Railway compatibility
RUN jq '.scripts.migrateandstart = "node /railway/index.js && " + .scripts.migrateandstart' package.json > package.json.tmp && \
    mv package.json.tmp package.json

# Set environment variables
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

CMD ["pnpm", "run", "migrateandstart"]
