FROM node:18-alpine AS scraper
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont
WORKDIR /app
COPY scraper/package.json .
RUN npm install
COPY scraper/scrape.js .
ARG SCRAPE_URL
ENV SCRAPE_URL=${SCRAPE_URL}
RUN node scrape.js

FROM python:3.10-alpine
WORKDIR /app
COPY server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY server/server.py .
COPY --from=scraper /app/scraped_data.json .
RUN adduser -D appuser && \
    chown -R appuser:appuser /app
USER appuser
EXPOSE 5000
CMD ["python", "server.py"]