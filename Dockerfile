FROM node:18 AS frontend-build

WORKDIR /app/frontend

COPY frontend/package*.json ./

RUN npm install

COPY frontend/ ./

RUN npm run build

FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY backend ./backend
COPY server.js ./

COPY --from=frontend-build /app/frontend/build ./frontend/build


CMD ["node", "server.js"]

