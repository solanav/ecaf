import requests
import json

data = json.loads(open("../nuam.json").read())

for facul in data:
  print(facul)
  for degree in data[facul]["degrees"]:
    for y in range(1, 7):
      print("\t" + degree)

      payload = {
        "_accion": "actualizarComboAsignaturas",
        "_anoAcademico": 2020,
        "_centro": facul,
        "_planEstudio": degree,
        "_curso": y,
        "_alumExternos": "N",
        "entradaPublica": "S",
        "idiomaPais": "es.ES"
      }

      r = requests.post(
          "https://secretaria-virtual.uam.es/doa/consultaPublica/look[conpub]ActualizarCombosPubGuiaDocAs",
          params=payload
      )

      asignaturas = r.json()['asignaturas']
      
      data[str(facul)]["degrees"][str(degree)]["years"][str(y)] = asignaturas

      f = open("../nuam.json", "w", encoding="utf-8")
      json.dump(data, f, indent=4, sort_keys=True, ensure_ascii=False)
      f.close()