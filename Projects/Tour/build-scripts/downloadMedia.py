import urllib2
import hashlib

def retrieveAndSave(stopID, url):
    response = urllib2.urlopen(url)
    rawMedia = response.read()
    
    parts = url.split('.')
    md5 = hashlib.md5(url).hexdigest()
    if len(parts) > 1:
        cacheName = md5 + '.' + parts[-1]
    else:
        cacheName = md5 
        
    mediaOutFile = open('Resources/data/stops/' + stopID + '/' + cacheName, 'w')
    mediaOutFile.write(rawMedia)
    mediaOutFile.close()