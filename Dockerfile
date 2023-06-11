FROM node:18.14.2-alpine AS builder

WORKDIR /build


COPY package.json package-lock.json server.js ./
COPY . .

RUN apk upgrade \
  && apk add python3 alpine-sdk

RUN npm install -g node-gyp

RUN npm install
RUN npm run build

##################################
# production stage
##################################
FROM node:18.14.2-alpine AS production

WORKDIR /app


COPY --from=builder --chown=node:node /build/package.json /app/package.json
COPY --from=builder --chown=node:node /build/package-lock.json /app/package-lock.json
COPY --from=builder --chown=node:node /build/.next /app/.next
COPY --from=builder --chown=node:node /build/server.js /app/server.js
COPY --from=builder --chown=node:node /build/public /app/public

RUN npm install --only=production

USER node
EXPOSE 3000

CMD ["npm", "run", "start"]
