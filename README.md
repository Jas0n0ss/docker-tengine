# 🚀 Tengine Multi-Arch Docker

A multi-architecture Docker image based on [Tengine 3.1.0](https://github.com/alibaba/tengine), supporting both `amd64` and `arm64` architectures. Pre-configured with a default Nginx-like setup, it's ideal for production or testing environments as a high-performance web gateway.

------

## ✅ Features

- ✅ **Multi-platform support**: `amd64` and `arm64` (Apple M series, ARM cloud servers, etc.)
- ✅ **Integrated jemalloc** for improved memory management
- ✅ **Common Tengine modules enabled** (HTTP, SSL, Stub_Status, Stream, etc.)
- ✅ **Built-in health check endpoint** at `/status`
- ✅ Runs as user `nginx` by default for security
- ✅ Easy deployment via **Docker Compose**

------

## 🔧 How to Use

### 1️⃣ Set Up Docker Environment

Install and enable `buildx` and QEMU:

```bash
docker buildx create --name multiarch-builder --use
docker run --rm --privileged tonistiigi/binfmt --install all
```

------

### 2️⃣ Build and Push Multi-Architecture Image

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag yourdockerhub/tengine:3.1.0 \
  --tag yourdockerhub/tengine:latest \
  --push \
  .
```

To build for the current platform only (for local testing):

```bash
docker build -t tengine:local .
```

------

## 🚀 Quick Run

```bash
docker run -it --rm -p 80:80 tengine:local
docker run -it --rm -p 80:80 jas0n0ss/tengine:amd64
docker run -it --rm -p 80:80 jas0n0ss/tengine:arm64
```

### Docker Compose

```yaml
# compose.yml
services:
  tengine:
    image: jas0n0ss/tengine:amd64
    container_name: tengine
    ports:
      - "80:80"
      - "443:443"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/status"]
      interval: 30s
      timeout: 5s
      retries: 3
```

Then run:

```bash
docker-compose up -d
```

------

## 🧱 Build Configuration (in Dockerfile)

```bash
./configure \
  --prefix=/usr/local/tengine \                       # Installation path
  --with-jemalloc \                                   # Use jemalloc for better performance
  --with-threads \                                    # Enable threading
  --with-file-aio \                                   # Async file I/O
  --with-http_ssl_module \                            # HTTPS support
  --with-http_v2_module \                             # HTTP/2 support
  --with-http_realip_module \                         # Real client IP
  --with-http_stub_status_module \                    # Status page support
  --with-http_gzip_static_module \                    # Gzip static file support
  --with-pcre-jit \                                   # Regex JIT optimization
  --with-http_auth_request_module \                   # Authentication request
  --with-http_slice_module \                          # Large file slicing
  --with-http_secure_link_module \                    # Anti-leech
  --with-http_addition_module \                       # Add content to response
  --with-http_degradation_module \                    # Graceful degradation
  --with-stream \                                     # TCP/UDP stream support
  --with-stream_ssl_module \                          # SSL for stream
  --with-stream_realip_module \                       # Real IP in stream
  --with-stream_ssl_preread_module                    # TLS SNI pre-reading
```

------

## 🔍 Health Check Endpoint

Enabled by default at `/status`:

```bash
curl http://localhost/status
```
