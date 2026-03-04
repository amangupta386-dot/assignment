FROM node:22-alpine
WORKDIR /app
COPY package.json ./package.json
COPY packages/shared ./packages/shared
COPY services/job-service ./services/job-service
RUN npm install
WORKDIR /app/services/job-service
EXPOSE 3000
CMD ["npm", "run", "start"]
