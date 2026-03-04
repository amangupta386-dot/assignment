FROM node:22-alpine
WORKDIR /app
COPY package.json ./package.json
COPY packages/shared ./packages/shared
COPY services/auth-service ./services/auth-service
RUN npm install
WORKDIR /app/services/auth-service
EXPOSE 3000
CMD ["npm", "run", "start"]
