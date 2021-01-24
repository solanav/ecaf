import os
import os.path
from pprint import pprint
from unidecode import unidecode
import string
import random
import psycopg2
from datetime import datetime
from shutil import copyfile
import hashlib

conn = psycopg2.connect(
  database="ecaf_dev",
  user="ecaf",
  password="mateos",
  host="192.168.1.144",
  port="5432"
)
cur = conn.cursor()

cur.execute("""
  SELECT id, backname, name, uploader, description, type, university, degree, year, course, professor, hash
  FROM public.files WHERE approved=false
""")
res = cur.fetchall()

for file in res:
  print("\n" * 100)

  (id_, backname, name, uploader, description, type_, university, degree, year, course, professor, h) = file
  print(f"Id          - {id_}")
  print(f"Name        - {name}")
  print(f"Uploader    - {uploader}")
  print(f"Description - {description}")
  print(f"Type        - {type_}")
  print(f"University  - {university}")
  print(f"Degree      - {degree}")
  print(f"Year        - {year}")
  print(f"Course      - {course}")
  print(f"Professor   - {professor}")
  print(f"Hash        - {h}")
  print(f"Path        - /home/solanav/ecaf/priv/static/uploads/{backname}")

  decision = False
  while not decision:
    decision = input("Approve? [Y]es | [N]o | [S]kip\n> ").lower()

    # Approve the file
    if decision == "y":
      cur.execute(f"UPDATE public.files SET approved=true WHERE id={id_}")
      conn.commit()
    # Remove the file
    elif decision == "n":
      cur.execute(f"DELETE FROM public.files WHERE id={id_}")
      conn.commit()
      os.remove("/home/solanav/ecaf/priv/static/uploads/" + backname)
    # Skip the file
    elif decision == "s":
      print("Skipping file...")
    else:
      decision = False