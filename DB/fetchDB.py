#!/usr/bin/python
# test or fetch DB https://thecyberpunker.com/ 

import pymysql

con = pymysql.connect('host', 'username',
    'password', 'dbname')

try:

    with con.cursor() as cur:

        cur.execute('SELECT VERSION()')

        version = cur.fetchone()

        print(f'Database version: {version[0]}')

finally:

    con.close()