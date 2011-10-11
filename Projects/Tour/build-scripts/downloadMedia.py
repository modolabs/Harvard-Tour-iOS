################################################################
#
#  Copyright 2011 The President and Fellows of Harvard College
#  Copyright 2011 Modo Labs Inc.
#
################################################################

import urllib2
import hashlib
import os

basePath = ''

def retrieveAndSave(url):
    if len(url) == 0:
       print 'Warning Empty URL for a media path'
       return

    if url.startswith('/'):
        fullURL = basePath + url
    else:  
        fullURL = url

    try:
        response = urllib2.urlopen(fullURL)
    except urllib2.HTTPError:
        print 'error downloading: ' + fullURL
        raise
    rawMedia = response.read()
    
    parts = url.split('.')
    md5 = hashlib.md5(url).hexdigest()
    if len(parts) > 1:
        cacheName = md5 + '.' + parts[-1]
    else:
        cacheName = md5 

    if not os.path.exists('Resources/data.temp/media/'):
        os.mkdir('Resources/data.temp/media/')
        
    mediaOutFile = open('Resources/data.temp/media/' + cacheName, 'w')
    mediaOutFile.write(rawMedia)
    mediaOutFile.close()
