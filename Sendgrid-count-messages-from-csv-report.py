#!/usr/bin/env python3

import sys
import csv

if len(sys.argv) > 1:
	print(sys.argv[1])
	filename = sys.argv[1]
else:
	filename = '/Users/jason.brink/Downloads/csv/DS-sendgrid-report-csre-4234.csv'

myfile =open(filename, 'r')
reader = csv.DictReader(myfile)
my_list = list()
for dictionary in reader:
	my_list.append(dictionary)

msg_ids = {}
for row in my_list:
        msg_ids.setdefault(row['message_id'], []).append(row['reason'])

print('{0} delivered messages'.format(len([msg_ids[x][-1] for x in msg_ids.keys() if ' OK ' in msg_ids[x][-1]])))
print('{0} undelivered messages'.format(len([msg_ids[x][-1] for x in msg_ids.keys() if ' OK ' not in msg_ids[x][-1]])))

