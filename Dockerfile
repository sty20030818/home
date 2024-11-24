# 构建应用
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm config set registry https://registry.npm.taobao.org
RUN npm cache clean --force
RUN npm config set strict-ssl false
RUN npm install -g cnpm
RUN cnpm install
COPY . .
RUN [ ! -e ".env" ] && cp .env.example .env || true
RUN npm run build

# 最小化镜像
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
RUN npm install -g cnpm && cnpm install -g http-server

EXPOSE 12445
CMD ["http-server", "dist", "-p", "12445"]
