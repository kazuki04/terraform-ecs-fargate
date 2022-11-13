FROM public.ecr.aws/docker/library/node:19.0-bullseye-slim

WORKDIR /app
COPY ./app/package.json .

RUN npm install yarn && yarn

COPY app/ .

CMD ["yarn", "dev"]
