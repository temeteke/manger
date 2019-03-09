FROM node

ARG DEBUG=False
ARG TITLE=manger

WORKDIR /work
COPY . /work/
RUN npm install && npm run build
