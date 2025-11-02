# Use the official Dart SDK image as the base image
FROM dart:stable AS build

# Set the working directory
WORKDIR /app

# Copy pubspec files to cache dependencies
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN dart pub get

# Copy the rest of the application code
COPY . .

# Build the application
RUN dart compile exe bin/main.dart -o bin/main

# Create a minimal runtime image
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the compiled binary from the build stage
COPY --from=build /app/bin/main /app/bin/main

# Copy environment example (optional, can be overridden)
COPY --from=build /app/.env.example /app/.env.example

# Expose the port
EXPOSE 8080

# Set environment variables
ENV PORT=8080
ENV HOST=0.0.0.0
ENV CACHE_TTL_SECONDS=60
ENV LOG_LEVEL=info

# Run the application
CMD ["./bin/main"]

