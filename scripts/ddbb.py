import psycopg2
from ecafile import Ecafile

class Database():
    def __init__(self):
        self.conn = psycopg2.connect(
            database=os.getenv("DB_DATABASE"),
            user=os.getenv("DB_USERNAME"),
            password=os.getenv("DB_PASSWORD"),
            host=os.getenv("DB_HOSTNAME"),
            port=os.getenv("DB_PORT")
        )
        self.cur = self.conn.cursor()

    def get_all_files(self):
        query = """
        SELECT id, backname, name, uploader, description, type, university, degree, year, course, professor, hash
        FROM public.files
        """
        self.cur.execute(query)
        files = [Ecafile(f) for f in self.cur.fetchall()]
        return files

    def get_not_approved(self):
        query = """
        SELECT id, backname, name, uploader, description, type, university, degree, year, course, professor, hash
        FROM public.files WHERE approved=false
        """
        self.cur.execute(query)
        files = [Ecafile(f) for f in self.cur.fetchall()]
        return files

    def approve_file(self, f):
        query = """
        UPDATE public.files
        SET approved=true
        WHERE id={}
        """.format(f.id_)

        self.cur.execute(query)
        self.conn.commit()

    def delete_file(self, f):
        query = """
        DELETE FROM public.files
        WHERE id='{}'
        """.format(f.id_)

        self.cur.execute(query)
        self.conn.commit()

    def get_duplicates(self):
        query = """
        SELECT id, backname, name, uploader, description, type, university, degree, year, course, professor, hash
        FROM public.files a_files
        WHERE (
            SELECT COUNT(*) from public.files b_files
            WHERE a_files.hash=b_files.hash
        ) > 1
        ORDER BY hash
        """
        self.cur.execute(query)
        files = [Ecafile(f) for f in self.cur.fetchall()]

        files_grouped = {}
        for f in files:
            if f.h in files_grouped:
                files_grouped[f.h].append(f)
            else:
                files_grouped[f.h] = [f, ]

        return files_grouped
