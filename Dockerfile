
# Stage 1: Build the Go binary
# -----------------------------
FROM golang:1.22.5 AS builder

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod .

# Download dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go binary for Linux (static)
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o main .

# -----------------------------
# Stage 2: Create a distroless image
# -----------------------------
FROM gcr.io/distroless/base 

# Set working directory
WORKDIR /app

# Copy binary and static files from the builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/static ./static

# Expose application port
EXPOSE 8080

# Run the compiled binary
CMD ["./main"]
