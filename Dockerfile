# 构建阶段
FROM node:18 AS builder
WORKDIR /app

# 复制 package.json 和 package-lock.json，仅安装依赖
COPY package*.json ./
RUN npm config set registry https://registry.npm.taobao.org && \
    npm install --no-cache

# 复制项目文件，设置环境变量，构建项目
COPY . .
RUN cp .env.example .env 2>/dev/null || true && \
    npm run build

# 生产阶段：使用更小的基础镜像
FROM node:18-alpine
WORKDIR /app

# 复制构建后的文件
COPY --from=builder /app/dist ./dist

# 安装必要的工具，仅安装 http-server
RUN npm config set registry https://registry.npm.taobao.org && \
    npm install -g http-server --no-cache

# 暴露端口
EXPOSE 12445

# 设置默认运行命令
CMD ["http-server", "dist", "-p", "12445"]
