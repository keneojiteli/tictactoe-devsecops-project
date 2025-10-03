# # Use an official Node.js runtime as a parent image for building the application
# # FROM node:20-alpine as builder

# FROM node:20-alpine3.20 as builder
# RUN apk update && apk upgrade --no-cache
# RUN apk add --no-cache expat=2.7.2-r0



# # Update system packages to latest security patches
# # RUN apk update && apk upgrade --no-cache
# # RUN apk update && apk upgrade  --no-cache && apk install -y --only-upgrade libexpat1 && apk clean && rm -rf /var/lib/apt/lists/*


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

# ---- Builder stage ----
FROM node:20-alpine3.20 AS builder

# Ensure base system packages are patched (fixes expat CVE and others)
RUN apk update && apk upgrade --no-cache

WORKDIR /app

# Copy only package files first (for efficient Docker caching)
COPY package*.json ./

# Install deps (production + build)
RUN npm ci

# Copy the rest of the source code
COPY . .

# Build the React/TypeScript app
RUN npm run build

# ---- Runtime stage ----
FROM node:20-alpine3.20 AS runtime

# Upgrade OS packages here too (runtime also needs to be patched)
RUN apk update && apk upgrade --no-cache

WORKDIR /app

# Copy only built files + node_modules from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

EXPOSE 3000

# Run as non-root for security
USER node

# Adjust if you run a custom server, e.g., "server.js"
CMD ["npm", "start"]


