# develop stage
FROM node:18-alpine

RUN npm install -g http-server

RUN mkdir /app

WORKDIR /app

COPY package*.json ./
COPY yarn.lock ./

RUN npm install -g @vue/cli
RUN npm install -g @quasar/cli
RUN npm install -g pinia
RUN yarn add vue@3
RUN yarn add @quasar/extras@latest
RUN npm install -g esbuild

RUN yarn install

COPY . .
# COPY .pruebas.env .env

# en caso de build
# RUN quasar build
# en caso de arrancar en linea...
EXPOSE 9000
CMD ["quasar", "dev", "--hostname", "0.0.0.0", "--port", "9000"]

# RUN mv dist build

