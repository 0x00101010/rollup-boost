FROM lukemathwalker/cargo-chef:latest AS chef
WORKDIR /app

# Prepare build plan
FROM chef AS planner
COPY ./Cargo.toml ./Cargo.lock ./
COPY ./src ./src
RUN cargo chef prepare

# Build application
FROM chef AS builder
COPY --from=planner /app/recipe.json .

# Install system dependencies
RUN apt-get update && \
    apt-get install -y openssl libclang-dev libssl3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN cargo chef cook --release
COPY . .
RUN cargo build --release

FROM chef AS final
COPY --from=builder /app/target/release/rollup-boost /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/rollup-boost"]