# # Use an official Node.js runtime as a parent image for building the application
# FROM node:20-alpine as builder

# # Update system packages to latest security patches
# # RUN apk upgrade --no-cache

# # Set working directory, , it will be created if it doesn't exist
# WORKDIR /app

# # Copy package files first to leverage Docker's caching mechanism to the work directory
# COPY package*.json ./

# # Install dependencies
# RUN npm ci 

# # Copy other application code
# COPY . .

# # Build the application
# RUN npm run build

# # production stage
# # Use an official Nginx image to serve the built application
# FROM nginx:alpine

# # Copy the built application from the builder stage to location Nginx serves files from
# COPY --from=builder /app/dist /usr/share/nginx/html

# # Expose port 80
# EXPOSE 80

# # Start Nginx server
# CMD ["nginx", "-g", "daemon off;"]

# # trying out distroless image
# FROM gcr.io/distroless/nodejs20:nonroot

# # Set working dir
# WORKDIR /app

# # Copy built app from builder
# COPY --from=builder /app/dist ./dist
# COPY --from=builder /app/node_modules ./node_modules
# COPY --from=builder /app/package*.json ./

# # Run the app as non-root (already provided by distroless:nonroot)
# USER nonroot

# # Start the app
# CMD ["dist/index.js"]

# Stage 1: Build
# FROM node:20-alpine AS builder
# WORKDIR /app

# # Copy package files and install only prod deps
# COPY package*.json ./
# RUN npm ci --only=production

# # Copy source code
# COPY . .

# # Build your React + Tailwind app (adjust if backend only)
# RUN npm run build

# # Stage 2: Runtime (Chainguard hardened Node.js)
# FROM cgr.dev/chainguard/node:20

# WORKDIR /app

# # Copy only the built artifacts + node_modules
# COPY --from=builder /app/dist ./dist
# COPY --from=builder /app/node_modules ./node_modules

# # Use non-root user by default (Chainguard enforces this)
# USER nonroot

# # Start the app
# CMD ["dist/index.js"]

# ---- Build stage ----
FROM cgr.dev/chainguard/node:latest AS builder

WORKDIR /app
COPY package*.json ./

# Install dependencies (no root, no cache)
RUN npm ci --omit=dev

COPY . .

# Build app (if using React/Next/etc., otherwise skip)
RUN npm run build

# ---- Runtime stage ----
FROM cgr.dev/chainguard/node:latest

WORKDIR /app

# Copy only needed files
COPY --from=builder /app /app

EXPOSE 3000
USER nonroot:nonroot

CMD ["node", "server.js"]

