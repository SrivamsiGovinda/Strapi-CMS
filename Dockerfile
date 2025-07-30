FROM strapi/strapi:latest
WORKDIR /srv/app
COPY ./config /srv/app/config
EXPOSE 1337
CMD ["strapi", "start"]