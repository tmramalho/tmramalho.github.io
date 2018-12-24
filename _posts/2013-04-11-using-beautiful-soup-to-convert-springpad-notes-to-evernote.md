---
id: 234
title: Using Beautiful Soup to convert Springpad notes to Evernote
date: 2013-04-11T20:00:20+00:00
author: Tiago Ramalho
layout: post
guid: http://www.nehalemlabs.net/prototype/?p=234
permalink: /blog/2013/04/11/using-beautiful-soup-to-convert-springpad-notes-to-evernote/
categories:
  - Development
tags:
  - code
  - computing
  - web
---
A few months back I decided to migrate all my work notes from springpad to evernote because I found evernote more robust and simpler.
I still keep my recipe collection on springpad though! Looks yummy.

Anyway, surprisingly there were some scripts going from evernote to springpad but not the other way around, which is a bit suprising because both services use a sort of HTML notation to export their notes so it's pretty simple to convert notes from one format to another.
So I used the nice python library <a href="http://www.crummy.com/software/BeautifulSoup/" target="_blank">Beautiful Soup</a> to parse the HTML and convert it to the other format.

With evernote it's a bit tricky to get it to accept everything because any noncompliant HTML entity throws off the whole process, but after some trial and error I managed to fix it. As an aside, if you want a bit more power when editing your evernote notes, this <a href="http://enml-editor.ping13.net/" target="_blank">service</a> lets you directly edit the HTML of any note.
It comes in pretty handy when you clip something from the web and it comes nested in some crazy divs.
I hope evernote's HTML format will not change too much in the near future and this script will stay helpful.
In any case the header contains the evernote client version at the time, so I hope even if it changes they will recognize/honor the old version.
Find the code after the jump.

<!--more-->

```python
from bs4 import BeautifulSoup
import time
import sys
import codecs
from xml.sax.saxutils import escape

if __name__ == "__main__":

	with open(sys.argv[1], 'r') as f:
		sp = BeautifulSoup(f.read())
		content = sp.find_all('div', class_ = 'instance')

	outputFile = codecs.open(sys.argv[2], encoding='utf-8', mode='w+')
	outputFile.write( '&lt;?xml version="1.0" encoding="UTF-8"?&gt;\n&lt;!DOCTYPE en-export SYSTEM "http://xml.evernote.com/pub/evernote-export2.dtd"&gt;\n&lt;en-export export-date="'+time.strftime('%Y%m%dT%H%M%SZ')+'" application="Evernote" version="Evernote Mac 3.3.1 (300245)"&gt;\n')

	for item in content:
		title = item.h2.string
		text = ""
		link = ""
		properties = item.find_all('div')
		for prop in properties:
			propType = prop.find('span', class_="label")
			if(propType != None):
				propContent = prop.find('span', class_="content")
				if propType.string == 'Url':
					link = propContent.string
				elif propType.string == 'Text':
					text = propContent.string
				elif propType.string == 'Notebook':
					notebook = propContent.string
				elif propType.string == 'Tags':
					tags = []
					for t in propContent.find_all('a'):
						tags.append(t.string)
				elif propType.string == 'Created On':
					spDate = propContent.abbr['title']
					date = time.strptime(spDate, '%Y-%m-%dT%H:%M:%S +00:00')
					enDateCr = time.strftime('%Y%m%dT%H%M%SZ', date)
				elif propType.string == 'Modified On':
					spDate = propContent.abbr['title']
					date = time.strptime(spDate, '%Y-%m-%dT%H:%M:%S +00:00')
					enDateUp = time.strftime('%Y%m%dT%H%M%SZ', date)

		enObj = "&lt;note&gt;&lt;title&gt;" + escape(title) + "&lt;/title&gt;"
		enObj += '&lt;content&gt;&lt;![CDATA[&lt;?xml version="1.0" encoding="UTF-8"?&gt;\n&lt;!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"&gt;\n&lt;en-note&gt;'
		try:
			enObj += escape(text)
		except TypeError:
			enObj += ""
		enObj += "\n&lt;/en-note&gt;]]&gt;\n&lt;/content&gt;"
		enObj += "&lt;created&gt;" + enDateCr + "&lt;/created&gt;"
		enObj += "&lt;updated&gt;" + enDateUp + "&lt;/updated&gt;"
		try:
			for tag in tags:
				enObj += "&lt;tag&gt;" + escape(tag) + "&lt;/tag&gt;"
		except NameError:
			pass
		enObj += "&lt;tag&gt;" + escape(notebook) + "&lt;/tag&gt;"
		enObj += "&lt;note-attributes&gt;&lt;source-url&gt;" + escape(link) + "&lt;/source-url&gt;&lt;/note-attributes&gt;&lt;/note&gt;\n"
		outputFile.write(enObj)

	outputFile.write("&lt;/en-export&gt;")
```

&nbsp;
