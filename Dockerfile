FROM misskey/misskey:13.14.2

WORKDIR /misskey

# Copy configuration
COPY .config /misskey/.config

# Install dependencies and build
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Modify package.json for Railway compatibility
RUN jq '.scripts.migrateandstart = "node /railway/index.js && " + .scripts.migrateandstart' package.json > package.json.tmp && \
    mv package.json.tmp package.json

# Copy Railway-specific files
COPY dist/index.js /railway/

# Set environment variables
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

CMD ["pnpm", "run", "migrateandstart"]
