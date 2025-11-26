# Multi-stage build for KiyuMart
# Stage 1: Build frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Build backend and serve
FROM node:18-alpine
WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --omit=dev

# Copy built frontend from stage 1
COPY --from=frontend-build /app/dist ./dist

# Copy server code
COPY server ./server
COPY shared ./shared
COPY db ./db

# Expose port
EXPOSE 5000

# Set production environment
ENV NODE_ENV=production

# Start the server
CMD ["node", "--loader=tsx", "server/index.ts"]
