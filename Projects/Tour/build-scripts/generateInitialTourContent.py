import sys
import plistlib
import os
import urllib2
import json
import downloadMedia

configuration = sys.argv[1]
server = configuration.split(' - ')[-1]

mainConfig = plistlib.readPlist("Config.plist")

secretConfig = None
if os.path.isfile("secret/Config.plist"):
    secretConfig = plist.readPlist("secret/Config.plist")

serverConfig = None
if secretConfig and secretConfig.has_key('Servers') and secretConfig['Servers'].has_key(server):
    serverConfig = secretConfig['Servers'][server]
elif mainConfig.has_key('Servers') and mainConfig['Servers'].has_key(server):
    serverConfig = mainConfig['Servers'][server]

if not serverConfig:
    raise Exception("No server configuration found for %s" % server)

if serverConfig.has_key('APIPath'):
    apiPath = serverConfig['APIPath']
else:
    raise Exception("No api path found for server configuration of %s" % server)

if serverConfig.has_key('Host'):
    host = serverConfig['Host']
else:
    raise Exception("No host found for server configuration of %s" % server)

if serverConfig.has_key('PathExtension'):
    pathExtension = serverConfig['PathExtension']
    if len(pathExtension) > 0 and (not pathExtension.endswith('/')):
        pathExtension += '/'
else:
    raise Exception("No path extension found for server configuration of %s" % server)


apiFullPath = 'http://' + host + '/' + pathExtension + apiPath
stopsJson = urllib2.urlopen(apiFullPath + '/tour/tour').read()
tourResponse = json.loads(stopsJson)['response']
stops = tourResponse['stops']
jsonOutFile = open('Resources/data/stops.json', 'w')
jsonOutFile.write(json.dumps(stops))
jsonOutFile.close

downloadMedia.basePath = 'http://' + host

for stop in stops:
    stopJson = urllib2.urlopen(apiFullPath + '/tour/stop?id=' + urllib2.quote(stop['details']['id'])).read()
    stop = json.loads(stopJson)['response']
    stopDetails = stop['details']
    if not os.path.exists('Resources/data/stops/' + stopDetails['id']):
        os.mkdir('Resources/data/stops/' + stopDetails['id'])
    
    jsonOutFile = open('Resources/data/stops/' + stopDetails['id'] + '/content.json', 'w')
    jsonOutFile.write(json.dumps(stop))
    
    # retrieve media content (photos and video)
    downloadMedia.retrieveAndSave(stopDetails['photo'])
    downloadMedia.retrieveAndSave(stopDetails['thumbnail'])
    for lenseId in stop['lenses']:
        lense = stop['lenses'][lenseId]
        OF = open('Resources/data/sample.json', 'w')
        OF.write(json.dumps(stop['lenses']))
        OF.close
        lenseContents = lense['contents']
        for lenseItem in lenseContents:
            if lenseItem['type'] == u'photo' or lenseItem['type'] == u'video':
                downloadMedia.retrieveAndSave(lenseItem['url'])
            elif lenseItem['type'] == u'slideshow':
                for slide in lenseItem['slides']:
                    downloadMedia.retrieveAndSave(slide['url'])
