FROM node:24-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund
COPY . .
RUN npm run build

FROM nginx:alpine AS runtime
RUN apk upgrade --no-cache \
    && rm -rf /usr/share/nginx/html && rm -f /etc/nginx/conf.d/default.conf
ENV SHADOW_NOINDEX=0
ENV NGINX_ENVSUBST_FILTER="^SHADOW_NOINDEX$"
COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -Y off -q -O /dev/null http://127.0.0.1/health || exit 1
