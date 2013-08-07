#! /usr/bin/env python

# This is for Py2k.  For Py3k, use http.client and urllib.parse instead, and
# use // instead of / for the division
import httplib
import urlparse
import urllib
import sys

def unshorten_url(url):
    #http://stackoverflow.com/questions/4201062/how-can-i-unshorten-a-url-using-python
    parsed = urlparse.urlparse(url)
    h = httplib.HTTPConnection(parsed.netloc)
    h.request('HEAD', parsed.path)
    response = h.getresponse()
    if response.status/100 == 3 and response.getheader('Location'):
        return response.getheader('Location')
    else:
        return url

def fix_url(url):
    #http://stackoverflow.com/questions/804336/best-way-to-convert-a-unicode-url-to-ascii-utf-8-percent-escaped-in-python
    # turn string into unicode
    if not isinstance(url,unicode):
        url = url.decode('utf8')
    # parse it
    parsed = urlparse.urlsplit(url)
    # divide the netloc further
    userpass,at,hostport = parsed.netloc.rpartition('@')
    user,colon1,pass_ = userpass.partition(':')
    host,colon2,port = hostport.partition(':')
    # encode each component
    scheme = parsed.scheme.encode('utf8')
    user = urllib.quote(user.encode('utf8'))
    colon1 = colon1.encode('utf8')
    pass_ = urllib.quote(pass_.encode('utf8'))
    at = at.encode('utf8')
    host = host.encode('idna')
    colon2 = colon2.encode('utf8')
    port = port.encode('utf8')
    path = '/'.join(  # could be encoded slashes!
        urllib.quote(urllib.unquote(pce).encode('utf8'),'')
        for pce in parsed.path.split('/')
    )
    query = urllib.quote(urllib.unquote(parsed.query).encode('utf8'),'=&?/')
    fragment = urllib.quote(urllib.unquote(parsed.fragment).encode('utf8'))
    # put it back together
    netloc = ''.join((user,colon1,pass_,at,host,colon2,port))
    return urlparse.urlunsplit((scheme,netloc,path,query,fragment))

def main():
   for line in sys.stdin:
      input_url = line.strip()
      try:
         input_url = fix_url(input_url)
         response = unshorten_url(input_url) 
         print input_url + "\t" + response
      except:
         print input_url + "\tERROR"

if __name__ == '__main__':
   main()
