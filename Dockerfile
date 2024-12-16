FROM node:18-slim AS builder

WORKDIR /build

# Install pnpm
RUN corepack enable pnpm

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source files
COPY src ./src
COPY build.js ./

# Build the application
RUN pnpm build

# Show the contents of dist for debugging
RUN ls -la dist/

FROM misskey/misskey:13.14.2

WORKDIR /misskey

# Install jq
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the built file from builder stage
COPY --from=builder /build/dist/index.js /railway/

# Modify package.json for Railway compatibility
RUN jq '.scripts.migrateandstart = "node /railway/index.js && " + .scripts.migrateandstart' package.json > package.json.tmp && \
    mv package.json.tmp package.json

# Set environment variables
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Show the contents of /railway for debugging
RUN ls -la /railway/

CMD ["pnpm", "run", "migrateandstart"]
