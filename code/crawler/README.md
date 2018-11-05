## FirmScraper
A web-scraper designed to extract firm websites, written in Python 3, based on Scrapy.

#### How to use this program
The following spiders are available:

FirmSpider.py: pulls all web pages from a domain, and saves in a CSV file. 

The crawler allows for the following options: 
```powershell
-o output.json
--set="DEPTH_LIMIT=2"
--set="ROBOTSTXT_OBEY=False"
```
To run the crawler without options:
```powershell
scrapy crawl HTML
```
Or, with options:
```powershell
scrapy crawl HTML --set="DEPTH_LIMIT=1" --set="ROBOTSTXT_OBEY=False"
``` 


#### Requirements
This program runs on Python 3 and requires Scrapy and its dependencies.
To install:
```bash
git clone https://github.com/datascience-air/EAGER.git
cd code/crawler
pip install -r requirements.txt
```

If you are using Windows, install requirements using ```windows.txt``` instead of ```requirements.txt```:
```bash
pip install -r windows.txt
```

