import urllib2
import hashlib
import os

def retrieveAndSave(url):
    response = urllib2.urlopen(url)
    rawMedia = response.read()
    
    parts = url.split('.')
    md5 = hashlib.md5(url).hexdigest()
    if len(parts) > 1:
        cacheName = md5 + '.' + parts[-1]
    else:
        cacheName = md5 

    if not os.path.exists('Resources/data/media/'):
        os.mkdir('Resources/data/media/')
        
    mediaOutFile = open('Resources/data/media/' + cacheName, 'w')
    mediaOutFile.write(rawMedia)
    mediaOutFile.close()
