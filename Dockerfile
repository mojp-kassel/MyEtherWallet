FROM node:20-bullseye

ENV HOME=/home
ENV NODE_OPTIONS="--max-old-space-size=8192"

WORKDIR /home/app

# Install system dependencies in one layer and clean apt cache
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential zip nasm \
 && rm -rf /var/lib/apt/lists/*

# Copy package manifests and install dependencies (use npm ci when lockfile present)
COPY package*.json ./
RUN if [ -f package-lock.json ]; then \
    npm ci --only=production; \
  else \
    npm install --only=production; \
  fi

# Run optional audit script if present, then remove it
COPY package-audit.js ./
RUN if [ -f package-audit.js ]; then \
    node package-audit.js || true; \
    rm -f package-audit.js; \
  fi

EXPOSE 8080

# Default start command — change if your app uses a different entrypoint
CMD ["npm", "start"]
