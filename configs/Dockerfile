FROM node:22

ENV NODE_ENV=development

WORKDIR /usr/src/app

ARG SERVICE_PATH
COPY ${SERVICE_PATH}/ /usr/src/app/

COPY bsCommonLibrary/ /usr/src/app/src/shared

COPY package*.json ./

RUN npm install

RUN npm run build

EXPOSE 3000

LABEL Name=node-image-base \
    Version=1.0.0 \
    Maintainer="Derek <ducanh.2206@gmail.com>" \
    Description="Base image for Node.js applications"
    
CMD ["npm", "run", "dev"]