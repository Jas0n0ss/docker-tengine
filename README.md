# 🚀 Tengine Multi-Arch Docker 

基于 [Tengine 3.1.0](https://github.com/alibaba/tengine) 构建的多架构支持镜像（支持 `amd64` 与 `arm64`），预配置 Nginx 默认配置，适用于生产、测试环境中作为高性能 Web 网关。

---

## ✅ 支持特性

- ✅ 支持多平台架构：`amd64`、`arm64`（Apple M 系、ARM 云主机等）
- ✅ 编译集成 jemalloc 以提升内存管理效率
- ✅ 编译启用常用 Tengine 模块（HTTP、SSL、Stub_Status、Stream 等）
- ✅ 默认集成健康检查接口 `/status`
- ✅ 默认运行用户 `nginx`，更安全
- ✅ 可通过 Docker Compose 快速部署

---

## 🔧 使用方法

### 1️⃣ 准备 Docker 环境

安装并启用 `buildx` 和 QEMU：

```bash
docker buildx create --name multiarch-builder --use
docker run --rm --privileged tonistiigi/binfmt --install all
```

### **2️⃣ 构建多架构镜像并推送**

```
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag yourdockerhub/tengine:3.1.0 \
  --tag yourdockerhub/tengine:latest \
  --push \
  .
```

若只构建当前平台测试：

```
docker build -t tengine:local .
```

## **🚀 快速运行**

```
docker run -it --rm -p 80:80 tengine:local
```

```
# compose.yml
services:
  tengine:
    image: yourdockerhub/tengine:latest
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
docker-compose up -d
```

## **🧱 编译参数说明（Dockerfile 中）**

```
./configure \
  --prefix=/usr/local/tengine \                       # 安装路径
  --with-jemalloc \                                   # 使用 jemalloc 提升性能
  --with-threads \                                    # 启用多线程
  --with-file-aio \                                   # 异步文件 I/O 支持
  --with-http_ssl_module \                            # HTTPS 支持
  --with-http_v2_module \                             # HTTP/2 支持
  --with-http_realip_module \                         # 获取真实客户端 IP
  --with-http_stub_status_module \                    # 状态页支持
  --with-http_gzip_static_module \                    # 预压缩 Gzip 文件支持
  --with-pcre-jit \                                   # 正则表达式加速
  --with-http_auth_request_module \                   # 认证请求支持
  --with-http_slice_module \                          # 大文件切片
  --with-http_secure_link_module \                    # 防盗链功能
  --with-http_addition_module \                       # 追加输出模块
  --with-http_degradation_module \                    # 降级处理支持
  --with-stream \                                     # TCP/UDP Stream 支持
  --with-stream_ssl_module \                          # TCP SSL 支持
  --with-stream_realip_module \                       # Stream 获取真实 IP
  --with-stream_ssl_preread_module                    # TLS SNI 预读取
```

## **🔍 健康检查接口**

默认开启 /status：

```
curl http://localhost/status
```


