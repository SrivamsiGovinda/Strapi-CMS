 #use an official Node.js runtime as a parent image
 FROM node:16

 #Set the working directory in the container
 WORKDIR /app

 #copy package.json and package-lock.json to the working directory
 COPY package*.json ./

 #Install Strapi dependencies
 RUN npm install

 #Copy the rest of your application's source code
 COPY . .

 RUN npm run build 

 
 #Expose the port of strapi app
 EXPOSE 1337

 #Define the command to start your strapi application
 CMD ["npm", "run", "start"]