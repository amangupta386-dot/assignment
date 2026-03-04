FROM node:22-alpine
WORKDIR /app
COPY package.json ./package.json
COPY packages/shared ./packages/shared
COPY services/notification-service ./services/notification-service
RUN npm install
WORKDIR /app/services/notification-service
EXPOSE 3000
CMD ["npm", "run", "start"]
