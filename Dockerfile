
FROM node:10
#RUN mkdir -p /home/node/rearc_test/node_modules && chown -R node:node /home/node/rearc_test
WORKDIR /home/node/rearc_test
COPY package*.json ./
#USER node
RUN npm install
COPY . .
EXPOSE 3000
CMD [ "node", "./src/000.js" ]
ENV SECRET_WORD=TwelveFactor
