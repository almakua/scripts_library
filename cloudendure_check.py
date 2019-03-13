
from datetime import datetime
import requests
import json
import sys

HOST = 'https://console.cloudendure.com'
headers = {'Content-Type': 'application/json'}


if len(sys.argv) != 3:
	print "Usage: cloudendure_check.py CLOUDENDURE_USERNAME CLOUDENDURE_PASSWORD"
	sys.exit(10)

session = {}

endpoint = '/api/latest/{}'
login_data = {'username': sys.argv[1], 'password': sys.argv[2]}
r = requests.post(HOST + endpoint.format('login'), data = json.dumps(login_data), headers = headers)
if r.status_code != 200 and r.status_code != 307:
	print "Bad login credentials"
	sys.exit(1)
	
# check if need to use a different API entry point
if r.history:
	endpoint = '/' + '/'.join(r.url.split('/')[3:-1]) + '/{}'
	r = requests.post(HOST + endpoint.format('login'), data = json.dumps(login_data), headers = headers)

session = {'session': r.cookies['session']}

headers['X-XSRF-TOKEN'] = r.cookies['XSRF-TOKEN']


r = requests.get(HOST + endpoint.format('projects'), headers = headers, cookies = session)
if r.status_code != 200:
	print "Failed to fetch the project"
	sys.exit(2)

try:
	
	projects = json.loads(r.content)['items']
	for project in projects:
		machines = False
		project_id = project['id']
		r = requests.get(HOST + endpoint.format('projects/{}/machines').format(project_id), headers = headers, cookies = session)
		if r.status_code != 200:
			print "Failed to fetch the machines"
			sys.exit(5)

		
		for machine in json.loads(r.content)['items']:
			backlog = 0
			
			if 'backloggedStorageBytes' in machine['replicationInfo']:		
				backlog = machine['replicationInfo']['backloggedStorageBytes']
			else:
				backlog = 0
			
			if 'lastConsistencyDateTime' in machine['replicationInfo']:
				last_consistent = machine['replicationInfo']['lastConsistencyDateTime']
			else:
				last_consistent = 'Still replicating'
			
				
			#print 'Project name: {}, Machine name:{}, Backlog bytes:{}, Last consistency:{}'.format(project['name'], machine['sourceProperties']['name'], backlog, last_consistent)
			#machines = True

			print '{} {} {}'.format(machine['sourceProperties']['name'],backlog,last_consistent)
			machines = True
			#print '{}'.format(r.content)

		#if not machines:
		#	print 'No machines for project {}'.format(project['name'])
except:
	print "No associated project"
	sys.exit(3)
