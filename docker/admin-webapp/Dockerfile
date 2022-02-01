FROM node:latest

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package.json ./
RUN npm install
# use --production for production

# Bundle app source
COPY log4js.json server.js ./
COPY webapp ./webapp

# Run server
CMD [ "node", "server.js" ]