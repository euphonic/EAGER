# The Web of Innovation: Using Website Data to Understand How Firms Innovate

Thanks for visiting this GitHub site!  I am PI on a small NSF grant and this code and data are available to anyone who wants to use or extend the repo to study small firm innovation.  Before you read any further, I suggest reviewing the companion site @ https://www.dextr.us/nsf-eager.  Here you'll find some background on why I started this work, as well as links to some other helpful resources, including a workshop that is aimed at a pedagogical introduction to the method. 

## 1. What does the code do? 

Essentially this project is all about collecting web and search engine data to produce a cross-sectional view of a firm's online presence.  After having done similar work in the past and coming across a host of data access and data quality issues, I wanted to first build an open-source process for collecting important variables to produce a sample frame. Then, the code goes out and scrapes websites.  With some reasonable assurances that are data are of good quality (and don't cost an arm and a leg!), we are able to move to analysis.  This project covers all aspects of this journey, but not everything is automated.  Rather, what you'll find is a famework covering seven main steps in the research design, as follows.  I anticipate the first few steps to be of most interest/help to other researchers looking to extend leverage the same frame generation and data collection process for their work.

[Introduce graphic here] 

1. The code assumes you start with a frame list of firms.  I got my initial list by identifying patent assignees in three high-technology areas, nanotechnology, synthetic biology, and renewable energy.  But you could produce a frame list in some other way, e.g., a list of firms that contract with the US government (via SAM.gov) or a list of firms that have published journal articles. 
2. Next, we go out and get firm URL information by plugging in the firm name in a search engine, namely MS Bing.  How can we determine which firm URL is the right one, since the first firm URL in a search result list may produce false positives? We use machine learning methods to address this challenge. 
3. How can I tell whether a firm is small or not?  On one hand, you could purchase this information, just like firm URLs.  Or you could turn to search engines and use commonly avaialable sources.  We use this second tactic and scrape firm search results from Google's Custom Search API.  You still have to pay a nominal ammount to access Google's API, but it's much cheaper than buying these data from a propietary business database vendor. 
4. Now that we've developed our final sample frame, we can turn to web scraping using the Python open-source library, Scrapy.  We also use MongoDB community edition, a document-based database that can store webpage data using JSON. 
5. Website data are messy.  We need to improve data quality to prepare for additional analysis.  One of the things we do at this stage is develop a machine learning model to identify only certain pages of interest, e.g., firm 'about us' pages.  We can go back and recrawl these 'about us' pages as needed.  Then, we can remove code snippets, copyright information, headings, and any other text that may add unnecessary noise.  The caveat here is that noise to you may not be the same thing as noise to me.  As you'll see I'm using the unstructured text for topical analysis, so I don't care much about menu items and related text.  For your work, you may care about a website's structure. 
6. Topic model the cleaned website data by industry, and visualize those topics
7. Develop a method for analyzing topical change from one paragraph to another.  Here, I focus on entrepreneurial narratives as my theoretical framework.

Traditionally when writing research papers, we would motivate the research question (#7) and then produce a research design that helps  answer that question.  The above steps are presented somewhat backwards from a social science perspective, yet I think it follows the computer science literature in its engineering, practical-application focus.  I have learned that when presenting this work, audience definitely matters.  Feel free to contact me if you would like an in-person introduction over phone/video and screen share. I can frame the work in a way that resonates with you the most. 

## 2. How do I get started? 

The workshop materials, available at https://www.dextr.us/workshop-resources, include a getting started guide.  You can follow this from start to finish if you would like to download the course workshop slides and virtual machine and follow steps 1-7 sequentially.  Just note that the workshop doesn't have the most recent code (it dates back to December 2019). 

For those of you interested in just one or some of the steps above, e.g., collecting firm employment data or website URLs, you might want to  set up your API keys for Google and/or Microsoft and then jump straight to cloning the main branch of this repo and heading  to the code that you're interested in. In other words, because the code is organized in loosely connected modules, you can jump in at any point.  What follows is a step-by-step guide for doing exactly this. 

## 4. Installation 
Choose one of three options: 

1. Follow the workshop getting started guide linked to from the bottom of [this page](https://www.dextr.us/workshop-resources "Workshop Resources")
2. Install the supporting tools, databases, and frameworks on your local system. Mac OS or Linux strongly recommended. (Native Windows compatibility has not been tested and is not supported.) 
3. Use the Amazon Web Services AMI to spin up an EC2 instance

Generally, I've found it easier to perform most of the analysis on my local machine but scrape on the cloud using the AMI image on EC2.  This is because scraping can take a long time to complete, and you don't necessarily want to be doing that on a laptop that you open and close often.  Plus, you can parallelize scraping on the cloud with multiple virtual machines, thus saving a lot of time. See below for details. 

### 4.1. Local system installation
1. First, clone this GitHub repo in a local directory of your choosing
2. [Install](https://docs.mongodb.com/v3.2/administration/install-community/ "MongoDB installation") MongoDB community edition 
3. You may want to install a MongoDB client, such as [Robo 3T](https://robomongo.org/ "Robo 3T")
4. [Install](https://jupyter.readthedocs.io/en/latest/install.html "Jupyter") Jupyter notebook
4. Install [R]("https://www.r-project.org/" R) and [RStudio](https://www.rstudio.com/products/rstudio/download/#download "RStudio").  Any .R scripts you may wish to use will require library installation, but that is fairly easy to do via the RStudio interface  
5. [Install](https://www.seleniumhq.org/download/ "Selenium") geckodriver for use in the web scraper.  I recommend performing all web scraping via the AMI, as noted above.   
5. There are a number of Python libraries that can be installed via pip or through anaconda. I am working on a requirements.txt file which can be sourced to install all libraries at the same time.  In the meantime, before running each Python script or interactive notebook, make sure each library is installed ahead of time.  (You will get error messages if something is missing.)

If there is anything missing from this list, please let me know. 

### 4.2. Amazon Machine Image (AMI) installation
1. Here, you'll need to create an AWS account and spin up an EC2 instance from a known AMI.  See [this page](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html#finding-an-ami-console "Lookup an AMI") for general instructions.  Search for "EAGER_scraper" and continue the process of launching your EC2 instance.  (Note you only need one 100GB volume to store your collected website data in MongoDB. You can accept all other defaults.)
2. Mount your primary database volume to your new virtual machine.  See [these](https://devopscube.com/mount-ebs-volume-ec2-instance/ "Mount EBS drive to EC2") instructions. Create a symlinked directory /eager on your base virtual machine pointing to your database volume 

If there is anything missing from this list, please let me know. 

## Scaling on AWS

How can we scale up and run multiple crawlers on the cloud?  This diagram shows a simple solution.  It also highlights different configurations of EC2 image types to build a cluster of loosely connected crawlers. 

## Running code for specific steps in the research design method

### 4.1. Identifying URLs
Turn to the code/urls directory.  Start 

## Can I extend this work for other domains?  What if I don't study small firms? 
Absolutely, the crawling code was modified from a school and district scraper.  At some level of abstraction, it doesn't matter if you're crawling firm, university, hospital, government agency, or any other kind of site!  However, you'll need to modify the code to suite the unique circumstances of your research domain. 

## I need help! 
No problem.  Contact me via [this form](https://www.dextr.us/about "Contact Sanjay") please.  I will do my best to respond within a day or two.
