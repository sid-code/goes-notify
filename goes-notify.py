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

def notify_send(dates, current_apt, settings, use_gmail=False):
    call(["bash", "./notify.sh",
          "'" + ', '.join(dates) + "'",
          "'" + current_apt.strftime('%B-%d,%Y') + "'"])

def main(*args, **kwargs):
    try:
        # obtain the json from the web url
        data = requests.get(GOES_URL_FORMAT.format(kwargs['location_id'])).json()

    	# parse the json
        if not data:
            logging.info('No tests available.')
            sys.exit(1)

        current_apt = kwargs['interview_date']
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
        if settings.get('no_spamming') and os.path.exists(fn):
            sys.exit(1)
        else:
            for f in glob.glob("goes-notify_*.txt"):
                os.remove(f)
            f = open(fn,"w")
            f.close()

    except OSError:
        logging.critical("Something went wrong when trying to obtain the openings")
        sys.exit(1)

    msg = 'Found new appointment(s) in location %s on %s (current is on %s)!' % (settings.get("enrollment_location_id"), dates[0], current_apt.strftime('%B %d, %Y @ %I:%M%p'))
    logging.info(msg + (' Sending email.' if not settings.get('no_email') else ' Not sending email.'))

    notify_send(dates, current_apt, settings, use_gmail=settings.get('use_gmail'))
    sys.exit(0)

def _check_settings(config):
    required_settings = (
        'current_interview_date_str',
        'enrollment_location_id'
    )

    for setting in required_settings:
        if not config.get(setting):
            raise ValueError('Missing setting %s in config.json file.' % setting)

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
    parser.add_argument('--location_id', dest='location_id', default=None, help='Enrollment center location ID')
    parser.add_argument('--interview_date', dest='interview_date', default=None, help='Date of currently scheduled interview')
    arguments = vars(parser.parse_args())
    logging.info("Location ID:    " + arguments['location_id'])
    logging.info("Interview date: " + arguments['interview_date'])

    main(location_id=int(arguments['location_id']),
         interview_date=datetime.strptime(arguments['interview_date'], '%B %d, %Y'))
