const puppeteer = require("puppeteer");
const fs = require("fs");

(async () => {
  const url = process.env.SCRAPE_URL || "https://example.com";
  const browser = await puppeteer.launch({
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
    executablePath: "/usr/bin/chromium"
  });

  const page = await browser.newPage();
  await page.goto(url, { waitUntil: "domcontentloaded" });

  const data = await page.evaluate(() => {
    return {
      title: document.title,
      firstHeading: document.querySelector("h1")?.innerText || "No H1 found"
    };
  });

  fs.writeFileSync("scraped_data.json", JSON.stringify(data, null, 2));
  await browser.close();
})();