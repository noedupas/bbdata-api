FROM node:latest

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package.json ./
RUN npm install
# use --production for production

# Bundle app source
COPY . .

# Run server
CMD [ "node", "server.js" ]