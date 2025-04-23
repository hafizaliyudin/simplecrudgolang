# Build stage
FROM golang:1.21-bullseye AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y gcc libc6-dev

# Set environment variables
ENV CGO_ENABLED=1 GOOS=linux GOARCH=amd64

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the entire project
COPY . .

# Build the Go application
RUN go build -o simplecrudgolang app.go

# Runtime stage
FROM debian:bullseye-slim

# Install runtime dependencies
    RUN apt-get update && apt-get install -y sqlite3 libsqlite3-0 && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root/

# Copy the built binary from the builder stage
COPY --from=builder /app/simplecrudgolang .

# Expose the application port
EXPOSE 8000

# Command to run the application
CMD ["./simplecrudgolang"]