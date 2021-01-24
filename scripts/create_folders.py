import json
import os
import requests

f = open("nuam.json", "r")
j = json.loads(f.read())
f.close()

for faculty in j:
  a = j[faculty]['name'].replace("/", ";")
  print(f"{a}")
  for degree in j[faculty]['degrees']:
    b = j[faculty]['degrees'][degree]['name'].replace("/", ";")
    print(f"\t{b}")

    for curso in range(1, 7):
      payload = {
          "_accion":"actualizarComboAsignaturas",
          "_anoAcademico": 2020,
          "_centro": faculty,
          "_planEstudio": degree,
          "_curso": curso,
          "_alumExternos": "N",
          "entradaPublica": "S",
          "idiomaPais": "es.ES"
      }

      r = requests.post(
          "https://secretaria-virtual.uam.es/doa/consultaPublica/look[conpub]ActualizarCombosPubGuiaDocAs",
          params=payload
      )

      j2 = r.json()

      for course in j2["asignaturas"]:
        c = j2["asignaturas"][course].replace("/", "|")

        os.makedirs(f"{a}/{b}/{curso}/{c}", exist_ok=True)