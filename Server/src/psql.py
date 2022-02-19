""" DB interaction """
import psycopg2
from .constants import *


def connect_db():
    """ Connect to db """
    return psycopg2.connect(
        host=HOST,
        database=DATABASE,
        user=USER,
        password=PASSWORD
    )


def create_tables():
    """ creates initial tables """
    commands = (
        """
        CREATE TABLE IF NOT EXISTS headers (
           id serial PRIMARY KEY NOT NULL,
        )
        """,
        )
    conn = None
    try:
        conn = connect_db()
        cur = conn.cursor()

        # create tables
        for command in commands:
            cur.execute(command)

        # close communication with the db
        cur.close()

        # commit the changes
        conn.commit()

    except Exception as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
