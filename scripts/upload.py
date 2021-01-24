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
  password="1234",
  host="192.168.1.144",
  port="5432"
)
cur = conn.cursor()

def list_dir(p):
  return list(filter(lambda x: not os.path.isfile(x), os.listdir(p)))

def list_files(p):
  return list(filter(os.path.isfile, os.listdir(p)))

def gen_name(base_name):
  i = 0
  while True:
    if i == 0:
      path = "/home/solanav/ecaf/priv/static/uploads/" + base_name
    else:
      path = "/home/solanav/ecaf/priv/static/uploads/" + str(i) + base_name

    if not os.path.isfile(path):
      break

    i += 1

  if i == 0:
    return base_name
  else:
    return str(i) + base_name

def hash_file(filename):
  h  = hashlib.sha256()
  b  = bytearray(128*1024)
  mv = memoryview(b)
  with open(filename, 'rb', buffering=0) as f:
      for n in iter(lambda : f.readinto(mv), 0):
          h.update(mv[:n])
  return h.hexdigest()

for d in list_dir("."):
  faculty = d.split(" - ")[0]

  print(faculty)
  
  for d2 in list_dir(d):
    degree = d2.split(" - ")[0]
    print(f"\t{degree}")
    
    for d3 in list_dir(d + "/" + d2):
      year = d3
      print(f"\t\t{year}")

      for d4 in list_dir(d + "/" + d2 + "/" + d3):
        course = d4.split(" - ")[0]
        print(f"\t\t\t{course}")
      
        for d5 in list_dir(d + "/" + d2 + "/" + d3 + "/" + d4):
          type_ = unidecode(d5.lower())
          print(f"\t\t\t\t{type_}")

          for root, dirs, files in os.walk(d + "/" + d2 + "/" + d3 + "/" + d4 + "/" + d5):
            for name in files:
              path = os.path.join(root, name)
              file_name = name
              typp = os.path.isfile(path)
              
              if typp:
                backname = gen_name(name)

                copyfile(path, "/home/solanav/ecaf/priv/static/uploads/" + backname)
                h = hash_file("/home/solanav/ecaf/priv/static/uploads/" + backname)

                dt = str(datetime.now()).split(".")[0]
                td2 = faculty + "/" + d2.replace(";", "/")
                td3 = d3.replace(";", "/")
                td4 = d4.replace(";", "/")
                cur.execute(f"INSERT INTO public.files(backname, name, uploader, description, type, university, degree, year, course, hash, professor, inserted_at, updated_at) VALUES ('{backname}', '{file_name}', 'auto', 'none', '{type_}', 'Universidad Autonoma de Madrid', '{td2}', '{td3}', '{td4}', '{h}', 'unknown', TO_TIMESTAMP('{dt}', 'YYYY/MM/DD HH24:MI:SS'), TO_TIMESTAMP('{dt}', 'YYYY/MM/DD HH24:MI:SS'));")
                conn.commit()

                print(f"\t\t\t\t\t{file_name}")
