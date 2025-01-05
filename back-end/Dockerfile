FROM node:20.13.0-alpine as tolls-backend

WORKDIR /app

COPY package.json ./

RUN npm install -g pnpm
RUN pnpm install

COPY . .

RUN pnpm run build
RUN pnpm prune --prod

COPY src/data/tollstations2024.csv dist/data/tollstations2024.csv

CMD ["pnpm", "start"]