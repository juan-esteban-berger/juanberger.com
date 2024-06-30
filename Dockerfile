# Dockerfile

FROM node:20.11.1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN npm install
RUN npm run build

EXPOSE 8080

CMD ["npm", "run", "start", "--", "-p", "8080"]
