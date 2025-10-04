# Build stage
# Use an official Node.js runtime as a parent image for building the application
# FROM node:20-alpine AS builder
FROM node:20-alpine3.20 AS builder

# Update system packages to the latest security patches
RUN apk update && apk upgrade --no-cache 

# Set working directory, it will be created if it doesn't exist
WORKDIR /app

# Copy package files first to leverage Docker's caching mechanism to the work directory
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy other application code
COPY . .

# Build the application
RUN npm run build



# production stage
# Use an official Nginx image to serve the built application
FROM nginx:alpine

# Copy the built application from the builder stage to location Nginx serves files from
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]



