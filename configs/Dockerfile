# Use Node.js image
FROM node:latest

ENV NODE_ENV=development

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

CMD ["npm", "run", "dev"]
