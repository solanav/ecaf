class Ecafile():
    def __init__(self, file_tuple):
        (id_, backname, name, uploader, description, type_, university, degree, year, course, professor, h) = file_tuple

        self.id_ = id_
        self.backname = backname
        self.name = name
        self.uploader = uploader
        self.description = description
        self.type_ = type_
        self.university = university
        self.degree = degree
        self.year = year
        self.course = course
        self.professor = professor
        self.h = h

    def __str__(self):
        s = ""

        s += f"Id          - {self.id_}\n"
        s += f"Name        - {self.name}\n"
        s += f"Uploader    - {self.uploader}\n"
        s += f"Description - {self.description}\n"
        s += f"Type        - {self.type_}\n"
        s += f"University  - {self.university}\n"
        s += f"Degree      - {self.degree}\n"
        s += f"Year        - {self.year}\n"
        s += f"Course      - {self.course}\n"
        s += f"Professor   - {self.professor}\n"
        s += f"Hash        - {self.h}\n"
        s += f"Path        - {self.backname}\n"

        return s