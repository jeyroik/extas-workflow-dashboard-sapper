FROM node:14

WORKDIR /usr/src/app

COPY rollup.config.js ./
COPY package*.json ./

RUN apt-get update
RUN apt-get install build-essential gdb libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev -y
RUN npm install canvas && npm install

COPY ./src ./src
COPY ./static ./static

RUN npm run-script build

EXPOSE 5000

ENV HOST=0.0.0.0
ENV JSON_RPC__ENDPOINT=0.0.0.0:8090

CMD [ "npm", "start" ]