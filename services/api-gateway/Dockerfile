FROM node:22-alpine
WORKDIR /app
COPY package.json ./package.json
COPY packages/shared ./packages/shared
COPY services/api-gateway ./services/api-gateway
RUN npm install
WORKDIR /app/services/api-gateway
EXPOSE 3000
CMD ["npm", "run", "start"]
