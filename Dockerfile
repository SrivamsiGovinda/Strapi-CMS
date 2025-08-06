FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN run build
EXPOSE 1337
CMD ["npm", "run", "start"]