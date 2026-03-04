FROM node:22-alpine
WORKDIR /app
COPY package.json ./package.json
COPY packages/shared ./packages/shared
COPY services/review-rating-service ./services/review-rating-service
RUN npm install
WORKDIR /app/services/review-rating-service
EXPOSE 3000
CMD ["npm", "run", "start"]
