FROM alpine:3.19 AS builder

ARG TENGINE_VERSION=3.1.0
ARG JEMALLOC_VERSION=5.3.0

RUN apk add --no-cache build-base pcre-dev zlib-dev openssl-dev linux-headers wget tar jemalloc-dev bash curl

WORKDIR /build

# jemalloc
RUN wget https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2 \
    && tar -xjf jemalloc-${JEMALLOC_VERSION}.tar.bz2 \
    && cd jemalloc-${JEMALLOC_VERSION} \
    && ./configure && make -j$(nproc) && make install

# tengine
RUN wget https://github.com/alibaba/tengine/archive/refs/tags/${TENGINE_VERSION}.tar.gz \
    && tar -xzf ${TENGINE_VERSION}.tar.gz

WORKDIR /build/tengine-${TENGINE_VERSION}

RUN ./configure \
    --prefix=/opt/tengine \
    --with-jemalloc \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    --with-pcre-jit \
    --with-http_auth_request_module \
    --with-http_slice_module \
    --with-http_secure_link_module \
    --with-http_addition_module \
    --with-http_degradation_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    && make -j$(nproc) && make install


# ========== 运行阶段 ==========
FROM alpine:3.19

RUN apk add --no-cache libstdc++ openssl pcre zlib jemalloc bash curl

RUN addgroup -S nginx && adduser -S -G nginx -s /sbin/nologin nginx

COPY --from=builder /opt/tengine /opt/tengine
COPY nginx.conf /opt/tengine/conf/nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ⚠️ 创建所有必须的目录（防止权限问题）
RUN mkdir -p /opt/tengine/logs \
    /opt/tengine/html \
    /opt/tengine/client_body_temp \
    /opt/tengine/proxy_temp \
    /opt/tengine/fastcgi_temp \
    && touch /opt/tengine/logs/access.log /opt/tengine/logs/error.log \
    && chown -R nginx:nginx /opt/tengine

ENV PATH="/opt/tengine/sbin:$PATH"

WORKDIR /opt/tengine

USER nginx

EXPOSE 80 443

CMD ["/start.sh"]
