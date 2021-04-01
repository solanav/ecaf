from ddbb import Database
from time import sleep
import os
from urllib.parse import unquote
from tqdm import tqdm
import json

# Download
import paramiko

# Servidor Libre UAM
from nextcloud import NextCloud
import sys
from os.path import dirname
from os.path import join

NEXTCLOUD_URL = os.getenv("NEXTCLOUD_URL")
NEXTCLOUD_USERNAME = os.getenv("NEXTCLOUD_USERNAME")
NEXTCLOUD_PASSWORD = os.getenv("NEXTCLOUD_PASSWORD")
NEXTCLOUD_DOWNLOAD_FOLDER = os.getenv("NEXTCLOUD_DOWNLOAD_FOLDER")

def clear():
    print("\n" * 100)

def check_duplicates_manually(db):
    duplicate_files = db.get_duplicates()

    if len(duplicate_files) == 0:
        print("There are no duplicate files")
        sleep(1)

    for h, files in duplicate_files.items():
        clear()

        # Show the duplicates
        i = 0
        for f in files:
            print(f"============== FILE NUMBER > ({i})")
            print(f)
            i += 1

        # Ask for file number
        keep = -1
        while keep < 0 or keep > len(files):
            keep = int(input("Which one do you want to keep? (File number)\n>>> "))

        i = 0
        for f in files:
            if i != keep:
                db.delete_file(f)
            i += 1

def check_duplicates_automatically(db):
    duplicate_files = db.get_duplicates()

    print(duplicate_files)

    for h, files in duplicate_files.items():
        keep_files = [files[0], ]
        delete_files = []
        
        # For each file
        for f in files[1:]:
            duplicate = False
            # For each unique file
            for f2 in keep_files:
                # If we have it, delete it
                if f.name == f.name:
                    delete_files.append(f)
                    duplicate = True
                    break

            if not duplicate:
                keep_files.append(f)

        for f in delete_files:
            db.delete_file(f)

def check_uploads(db):
    files = db.get_not_approved()

    if len(files) == 0:
        print("There are no new files")
        sleep(1)

    for f in files:
        clear()
        print(f)

        decision = False
        while not decision:
            decision = input("Approve? [Y]es | [N]o | [S]kip\n> ").lower()

            # Approve the file
            if decision == "y":
                db.approve_file(f)
            # Remove the file
            elif decision == "n":
                db.delete_file(f)
            # Skip the file
            elif decision == "s":
                print("Skipping file...")
            else:
                decision = False

def servidorlibreuam_sync():
    FILE = 0
    DIR = 1

    nxc = NextCloud(
        endpoint=NEXTCLOUD_URL,
        user=NEXTCLOUD_USERNAME,
        password=NEXTCLOUD_PASSWORD,
        json_output=True
    )

    folders = []

    # Explore the root folder first
    root = nxc.list_folders(NEXTCLOUD_USERNAME, path="Descarga").data
    for res in root[1:]:
        if res["resource_type"] == "collection":
            res_type = DIR
        else:
            res_type = FILE
        res_path = res["href"].replace("/remote.php/dav/files/"+ NEXTCLOUD_USERNAME + "/", "")
        folders.append((res_type, res_path))

    # Download files and explore folders
    for res_type, res_path in folders:
        print(f"{res_type} - {unquote(res_path)}")
        local_path = unquote(res_path.replace("Descarga/", NEXTCLOUD_DOWNLOAD_FOLDER))
        if res_type == FILE:
            # Download the file
            nxc.download_file(NEXTCLOUD_USERNAME, res_path, NEXTCLOUD_DOWNLOAD_FOLDER, overwrite=True)
        elif res_type == DIR:
            # Create the dir locally
            os.makedirs(local_path, exist_ok=True)

            # Add the files inside this dir
            root = nxc.list_folders(NEXTCLOUD_USERNAME, path=res_path).data
            for res in root[1:]:
                if res["resource_type"] == "collection":
                    r_type = DIR
                else:
                    r_type = FILE
                r_path = res["href"].replace("/remote.php/dav/files/" + NEXTCLOUD_USERNAME + "/", "")
                folders.append((r_type, r_path))

def fill_faculty(db):
    jsondb = json.load(open("../nuam.json"))

    files = db.get_all_files()
    for f in tqdm(files):
        faculty_code = f.degree.split("/")[0]
        faculty = jsondb[faculty_code]["name"]

        query = """
        UPDATE public.files
        SET faculty='{}'
        WHERE id={}
        """.format(faculty, f.id_)

        db.cur.execute(query)
        db.conn.commit()


if __name__ == "__main__":
    db = Database()

    while True:
        clear()

        print("What do you want to do?")
        print("(0) Check uploads")
        print("(1) Check duplicates (Manually)")
        print("(2) Check duplicates (Automatic)")
        print("(3) Sync with external nextcloud")
        print("(4) Fill faculty in Database")
        print("(5) Exit")
        selection = int(input(">>> "))

        if selection == 0:
            clear()
            check_uploads(db)
        elif selection == 1:
            clear()
            check_duplicates_manually(db)
        elif selection == 2:
            clear()
            check_duplicates_automatically(db)
        elif selection == 3:
            clear()
            servidorlibreuam_sync()
        elif selection == 4:
            clear()
            fill_faculty()
        elif selection == 5:
            clear()
            exit(0)
