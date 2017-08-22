# -*- coding: utf-8 -*-
import os
import sys
import urllib
import urllib2
import socket
import hashlib
import time
import getopt
import random
from ftplib import FTP, error_perm
from ftplib import FTP_TLS

socket.setdefaulttimeout(30)

#URL = "http://update.can.cibntv.net"
#URL = "http://10.182.1.21:9002"


def http_get(url):
    i_headers = {"User-Agent": "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1) Gecko/20090624 Firefox/3.5",
                 "Accept": "text/plain"}
    print "http_get", url
    req = urllib2.Request(url, headers=i_headers)
    try:
        page = urllib2.urlopen(req)
        return page.read()
    except urllib2.HTTPError, e:
        print "Error Code:", e
        return None
    except urllib2.URLError, e:
        print "Error Reason:", e
        return None
    except Exception as e:
        print "http_get error:", e
        return None


def get_opaque(uri, params):
    keys = params.keys()
    keys.sort()
    stringArray = []
    for k in keys:
        stringArray.append("{0}={1}".format(k, params[k]))
    stringArray.append("key={0}".format("A013227A8D3B4C86ACEB6CB5F5BA9DAA"))  # 100001 1
    strings = "&".join(stringArray)
    strings = "{0}?{1}".format(uri, strings)
    opaque = hashlib.new("MD5", strings).hexdigest().lower()
    return opaque


def get_url(http_domain, uri, params):
    opaque = get_opaque(uri, params)
    params["opaque"] = opaque
    param = urllib.urlencode(params)
    return "{0}{1}?{2}".format(http_domain, uri, param)


def notify_package(http_domain, params):
    uri = "/notify/uploadpackage"
    for k in params.keys():
        if params[k] is None:
            params.pop(k)
    params["rand"] = random.randint(1000, 99999)
    params["timestamp"] = int(time.time())
    params["token"]="A013227A8D3B4C86ACEB6CB5F5BA9DBB"
    url = get_url(http_domain, uri, params)
    print url
    return http_get(url)


def get_params(argv):
    params = {"system_ver": None,
              "app_ver": None,
              "md5": None,
              "file_name": None,
              "channel": None,
              "platform": None,
              "full": None, 
              "file_path": None}
    optlist, args = getopt.getopt(argv, 's:a:m:f:l:c:p:u:')
    for k, v in optlist:
        if k == "-s":  # system_ver
            params["system_ver"] = v
        elif k == "-a":  # app_ver
            params["app_ver"] = v
        elif k == "-m":  # md5
            params["md5"] = v
        elif k == "-f":  # file_name
            params["file_name"] = v
        elif k == "-l":  # file_path
            params["file_path"] = v
        elif k == "-c":  # channel
            params["channel"] = v
        elif k == "-p":
            params["platform"] = v
        elif k == "-u":
            params["full"] = v
    for k in ["system_ver", "app_ver", "md5", "file_name", "channel", "platform", "full"]:
        if params[k] is None:
            print k, "param is None"
            sys.exit()
    return params

def upload_file(host, port, user, passwd, file_name, local_file):
    success = True
    ftp = FTP_TLS()
    try:
        ftp.connect(host=host, port=port)
        ftp.login(user=user, passwd=passwd)
        ftp.prot_p()
        ftp.cwd("FTP")
        file_handle=open(local_file, "rb")
        ftp.storbinary("STOR {0}".format(file_name), file_handle)
        ftp.close()
        file_handle.close()
    except Exception as ex:
        print ex
        success = False
    except error_perm as ex:
        print ex
        success = False
    finally:
        return success


def upload(ftp_host, ftp_port, ftp_user, ftp_passwd, file_name, http_domain, local_file, params):
    if not upload_file(host=ftp_host, port=ftp_port, user=ftp_user, passwd=ftp_passwd, 
			file_name=file_name, local_file=local_file):
        print "upload %s file failed" % ftp_host
        sys.exit()
    print notify_package(http_domain, params)


def main():
    params = get_params(sys.argv[1:])
    local_file="{0}/{1}".format(params["file_path"], params["file_name"])
    ext_name = os.path.splitext(params["file_name"])[1] #获取扩展名
    file_name = "{0}-{1}-{2}-{3}{4}".format(params["platform"],
            params["channel"], params["app_ver"], params["full"], ext_name).replace(' ', '').replace('\r', '').replace('\n', '').strip()
    params["file_name"] = file_name
    #idc
    upload(ftp_host="172.16.11.12", ftp_port=2121, ftp_user="ftposdfuser", ftp_passwd="UU5YI_BeDWQX", file_name=file_name,
                http_domain="http://update.can.cibntv.net", local_file=local_file, params=params)
    #test
    upload(ftp_host="172.16.11.12", ftp_port=2121, ftp_user="ftposdfusertest", ftp_passwd="_mMEn(D7)0PQ", file_name=file_name, 
            http_domain="http://172.16.11.97:9200", local_file=local_file, params=params)


if __name__ == "__main__":
    main()

