""" DB interaction """
import psycopg2, logging
from src.constants import *


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
        logging.error(error)
    finally:
        if conn is not None:
            conn.close()


def get_contract():
    """ return contract info  from db """
    conn = connect_db()
    cur = conn.cursor()

    cur.execute("SELECT * FROM contract;")
    res = cur.fetchone()

    cur.close()
    conn.close()
    return res


def set_contract(address, abi):
    """ stores contract info to db """
    conn = connect_db()
    cur = conn.cursor()
    cur.execute("DROP TABLE contract")
    conn.commit()
    create_tables()
    cur.execute("INSERT INTO contract (address, abi) VALUES (%s, %s);", (address, abi))
    conn.commit()
    cur.close()
    conn.close()