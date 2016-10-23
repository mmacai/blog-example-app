FROM mhart/alpine-node:6.5

# Attach files to container
ADD index.js /node-app/index.js
ADD package.json /node-app/package.json
ADD README.md /node-app/README.md

# Set working directory
WORKDIR /node-app/

# Install all dependencies
RUN npm install

RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting.txt
VOLUME /myvol

ENV PORT 4444

# Ports
EXPOSE ${PORT}

# Start
CMD ["npm", "start"]
