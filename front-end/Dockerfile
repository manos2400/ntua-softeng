FROM node:20.13.0-alpine as tolls-frontend

WORKDIR /app

COPY package.json ./

RUN npm install

COPY . .

CMD ["npm", "start"]