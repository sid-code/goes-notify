#!/usr/bin/env python

# Note: for setting up email with sendmail, see: http://linuxconfig.org/configuring-gmail-as-sendmail-email-relay

import argparse
import json
import logging
import sys
import os
import glob
import requests
import hashlib

from datetime import datetime
from os import path
from subprocess import call

GOES_URL_FORMAT = 'https://ttp.cbp.dhs.gov/schedulerapi/slots?orderBy=soonest&limit=3&locationId={0}&minimum=1'

def notify_send(notify_program, dates, current_apt):
    call([notify_program, ', '.join(dates), current_apt.strftime('%B %d, %Y')])

def main(notify_program=None, location_id=None, interview_date=None):
    try:
        # obtain the json from the web url
        data = requests.get(GOES_URL_FORMAT.format(location_id)).json()

    	# parse the json
        if not data:
            logging.info('No tests available.')
            sys.exit(1)

        current_apt = interview_date
        dates = []
        for o in data:
            if o['active']:
                dt = o['startTimestamp'] #2017-12-22T15:15
                dtp = datetime.strptime(dt, '%Y-%m-%dT%H:%M')
                if current_apt > dtp:
                    dates.append(dtp.strftime('%A, %B %d %Y @ %I:%M%p'))

        if not dates:
            sys.exit(1)

        hash = hashlib.md5(
            (''.join(dates) + current_apt.strftime('%B %d, %Y @ %I:%M%p')).encode('utf8')
        ).hexdigest()
        fn = "goes-notify_{0}.txt".format(hash)
        if os.path.exists(fn):
            sys.exit(1)
        else:
            for f in glob.glob("goes-notify_*.txt"):
                os.remove(f)
            f = open(fn,"w")
            f.close()

    except OSError:
        logging.critical("Something went wrong when trying to obtain the openings")
        sys.exit(1)

    msg = 'Found new appointment(s) in location %s on %s (current is on %s)!' % ((location_id), dates[0], current_apt.strftime('%B %d, %Y @ %I:%M%p'))

    notify_send(notify_program, dates, current_apt)
    sys.exit(0)

if __name__ == '__main__':

    # Configure Basic Logging
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(levelname)s: %(asctime)s %(message)s',
        datefmt='%m/%d/%Y %I:%M:%S %p',
        stream=sys.stdout,
    )

    pwd = path.dirname(sys.argv[0])

    # Parse Arguments
    parser = argparse.ArgumentParser(description="Command line script to check for goes openings.")
    parser.add_argument('--notify_program', dest='notify_program', default=None, help="The program to call with the date of an available appointment")
    parser.add_argument('--location_id', dest='location_id', default=None, help='Enrollment center location ID')
    parser.add_argument('--interview_date', dest='interview_date', default=None, help='Date of currently scheduled interview')
    arguments = vars(parser.parse_args())
    logging.info("Notify program: " + arguments['notify_program'])
    logging.info("Location ID:    " + arguments['location_id'])
    logging.info("Interview date: " + arguments['interview_date'])

    main(notify_program=arguments['notify_program'],
         location_id=int(arguments['location_id']),
         interview_date=datetime.strptime(arguments['interview_date'], '%B %d, %Y'))
