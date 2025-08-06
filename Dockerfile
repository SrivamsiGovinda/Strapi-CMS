FROM strapi/strapi:latest
WORKDIR /srv/app
COPY . .
RUN npm install --legacy-peer-deps
RUN npm run build
EXPOSE 1337
CMD ["npm", "run", "start"]