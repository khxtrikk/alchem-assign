FROM node:20-slim
WORKDIR /app

# Install dependencies first for Docker caching
COPY workers/caller-worker/package*.json ./
RUN npm ci

# Copy the rest of the source code
COPY workers/caller-worker/ .

# Run the worker
CMD ["npx", "tsx", "src/worker.ts"]
