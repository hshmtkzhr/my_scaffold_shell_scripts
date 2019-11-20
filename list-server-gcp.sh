#!/bin/bash

tmp=`mktemp`
trap 'rm -f $tmp*' 0

dir=$(cd $(dirname $0) && pwd)

function __usage() {
  echo "$(basename $0) [opt]"
  echo "  default: print running only with brief format"
  echo "  -a print all with wide format"
  echo "  -s print terminated only with brief format"
  echo "  -h print this message"
  exit
}

opt=$1
case $opt in
  '-a')
    opt="all"
    ;;
  '-s')
    opt="stopped"
    ;;
  '-h')
    __usage
    ;;
  *) # print running with brief
    opt="default"
    ;;
esac


gcloud compute instances list --format json | python -c '
import sys, json, os

j = json.load(sys.stdin, encoding="utf-8")
for elm in j:
  name = elm["name"]
  status = elm["status"]
  ip = elm["networkInterfaces"][0]["networkIP"]
  created_at = elm["creationTimestamp"]
  machine_type = os.path.basename(elm["machineType"]).rstrip()
  zone = os.path.basename(elm["zone"]).rstrip()
  tags = ",".join(elm["tags"]["items"])
  hostname = ""
  for i in elm["metadata"]["items"]:
    if i["key"] == "Hostname":
      hostname = i["value"]

  print("{0}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}".format(name, hostname, machine_type, status, zone, ip, tags, created_at))
' > $tmp.list

cat $tmp.list | sort -k1,5 > $tmp.sorted

case $opt in
  'all')
    cat $tmp.sorted
    ;;
  'stopped')
    cat $tmp.sorted | grep TERMINATED | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}'
    ;;
  'default')
    cat $tmp.sorted | grep RUNNING | awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6}'
    ;;
esac
