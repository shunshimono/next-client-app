FROM node:18.14.2-alpine AS builder

WORKDIR /build

ARG NODE_AUTH_TOKEN
ARG MODE

ENV NODE_AUTH_TOKEN=$NODE_AUTH_TOKEN
ENV MODE=$MODE

COPY package.json package-lock.json ./
COPY . .

RUN apk upgrade \
  && apk add python3 alpine-sdk

RUN npm install -g node-gyp

RUN npm install
RUN npm run build:${MODE}

##################################
# production stage
##################################
FROM node:18.14.2-alpine AS production

WORKDIR /app

ARG NODE_AUTH_TOKEN
ENV NODE_AUTH_TOKEN=$NODE_AUTH_TOKEN

COPY --from=builder --chown=node:node /build/package.json /app/package.json
COPY --from=builder --chown=node:node /build/package-lock.json /app/package-lock.json
COPY --from=builder --chown=node:node /build/.npmrc /app/.npmrc
COPY --from=builder --chown=node:node /build/.next /app/.next
COPY --from=builder --chown=node:node /build/public /app/public

RUN npm install --only=production

USER node
EXPOSE 3000

CMD ["npm", "run", "start"]
