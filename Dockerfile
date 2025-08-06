FROM strapi/strapi:latest
WORKDIR /srv/app
COPY ./config /srv/app/config
RUN npm install --legacy-peer-deps
RUN npm run build
EXPOSE 1337
CMD ["strapi", "start"]