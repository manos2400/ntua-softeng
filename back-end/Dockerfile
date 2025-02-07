FROM node:20.13.0-alpine as tolls-backend

WORKDIR /app

COPY package.json ./

RUN npm install

COPY . .

RUN npm run build
RUN npm prune --prod

COPY src/data/tollstations2024.csv dist/data/tollstations2024.csv

CMD ["npm", "start"]