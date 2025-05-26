# Stage 1: Build
FROM node:18 AS build

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build

# Stage 2: Production runtime
FROM node:18

WORKDIR /app

# Copy only necessary files from build stage
COPY --from=build /app/build ./build
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./

EXPOSE 3000

CMD ["node", "start"]  # Or your start command
