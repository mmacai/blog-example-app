FROM mhart/alpine-node:6.5

# Attach files to container
COPY index.js /node-app/index.js
COPY package.json /node-app/package.json
COPY README.md /node-app/README.md

# Set working directory
WORKDIR /node-app/

# Install all dependencies
RUN npm install

RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting.txt
VOLUME /myvol

# Health check
HEALTHCHECK --interval=2m --timeout=3s \
  CMD curl -f http://localhost:4444/ || exit 1

ENV PORT 4444

# Ports
EXPOSE ${PORT}

# Start
CMD ["npm", "start"]
