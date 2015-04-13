#!/usr/bin/python3
import os, sys, re, shutil
from collections import OrderedDict

# Author: LDN <duron.luke@gmail.com>
# Python version : 3.4
# Brief:
#   Parse dico files and generate output files for telemac-mode.el
#   list and documentation of keywords
# /!\ Remove and replace all the content of definitions and lists folders

def parse_dico_file(dicofile):
    global keywords, toto
    """
    Parse telemac dictionary file (for one module)
    Return a list of keywords as a dict type
    """
    def remove_surrounding_char(string, char):
        """Return a string without surrounding char if present"""
        if string.startswith(char) and string.endswith(char):
            return string[1:-1]
        else:
            return string

    def iter_on_keyword():
        """
        Generate an iterator on each keyword of dicofile
        keyword is a dict with key from variable `keys`
        """
        with open(dicofile, 'r', encoding='iso-8859-1') as filein:
            content = filein.readlines()
            last_key = None
            keyword = {}

            for line in content:
                line = line.strip()  # remove trailing whitespaces and line breaking
                line = line.replace("''", "'")  # for French apostrophe
                key_found = False

                if not line.startswith('/') and line != '':
                    for key in keys:
                        # Find if current line starts with a key
                        if re.search('{}\s*='.format(key), line):
                            if key == first_key and last_key is not None:
                                # A new keyword is reached...

                                for key2clean, value in keyword.items():
                                    # Remove surrounding quotation mark (and trailing space)"
                                    # Not possible do it before because values are build by concatenation
                                    keyword[key2clean] = remove_surrounding_char(keyword[key2clean], "'").strip()

                                yield keyword
                                # Clean for next keyword
                                keyword = {}

                            value = line.split('=')[1]
                            keyword[key] = value.strip()
                            last_key = key
                            key_found = True
                            break

                    if not key_found and last_key is not None:
                        # The current key is written on multiple lines
                        keyword[last_key] = keyword[last_key] + '\n' + line

    # Build keywords by step
    keywords = []
    for keyword in iter_on_keyword():
        keywords.append(keyword)

    return keywords

def write_list_file(list_file, list_keyword_names):
    """
    Write keywords name (list_keyword_names) in list_file
    Keywords are written by alphabetic order and separated by a line breaking
    """
    list_keyword_names.sort()
    with open(list_file, 'w') as fileout:
        for keyword in list_keyword_names:
            fileout.write(keyword + '\n')

def write_def_file(keyword, lang, module, def_folder):
    """
    Write a definition file from keyword (dict of keys/values)
    """
    def_file = os.path.join(def_folder, keyword[name[lang]])

    with open(def_file, 'w') as fileout:
        first = True
        for key, label in labels2write[lang].items():
            value = None

            if key in keyword:
                # Read value found in dico, but can be empty (see below)
                value = keyword[key]

            if value == '':
                if key in default_empty_keys:
                    value = default_empty_value[lang]
                else:
                    # Key with an empty string value will not be written
                    value = None

            if value is not None:
                if first:
                    first = False
                else:
                    # Add line breaking between keys
                    fileout.write('\n')
                    fileout.write('\n')

                fileout.write("{} = {}".format(label, value))

def generate_files_from_dico(dicofile, langs, module):
    """
    Read and parse dico file
    Write files (and create foler if missing) in :
    * lists: list of keywords for each module
    * definitions: help/documentation file for each keyword (one sub-folder per module)
    /!\ Overwrites all generated files
    """
    print("Parsing file: {}".format(dicofile))
    keywords = parse_dico_file(dicofile)

    for lang in langs:
        # 1) Write list of keywords
        list_folder = os.path.join('lists', lang)
        os.makedirs(list_folder, exist_ok=True)
        list_file = os.path.join(list_folder, module)
        print("Writing list of keywords: {}".format(list_file))
        list_keyword_names = [keyword[name[lang]] for keyword in keywords]
        write_list_file(list_file, list_keyword_names)

        # 2) Write definition files
        def_folder = os.path.join('definitions', lang, module)
        os.makedirs(def_folder, exist_ok=True)
        print("Writings definition files in {}".format(def_folder))

        for keyword in keywords:
            write_def_file(keyword, lang, module, def_folder)

# ~> VARIABLES TO PARSE DICO FILES
# Telemac dico files (one per module) consists of list of keywords.
# A keyword has several keys with a corresponding value.
# The keys are precised in a variable, and the value correspond to the text
#   after the = symbol and can be written on multiple lines
first_key = 'NOM'  # recognize a new keyword (first key in the block of keys)
keys = ['NOM', 'NOM1', 'TYPE', 'INDEX', 'MNEMO', 'TAILLE', 'SUBMIT', 'DEFAUT', 'DEFAUT1', 'CHOIX', 'CHOIX1', 'RUBRIQUE', 'RUBRIQUE1', 'COMPORT', 'NIVEAU', 'APPARENCE', 'AIDE', 'AIDE1']  # some are optional (order is not relevant)

# ~> VARIABLE TO WRITE DEFINITION FILES
# Keys to find keyword name
name = {'fr': 'NOM',
        'en': 'NOM1'}

# no_value is only used as value for the key default if missing
default_empty_keys = ['DEFAUT', 'DEFAUT1']
default_empty_value = {'fr': 'aucun',
                       'en': 'no value'}

# Keys to write in definition files
labels2write = {
    'fr': OrderedDict({
        'DEFAUT': 'DÉFAUT',
        'CHOIX': 'CHOIX',
        'AIDE': 'AIDE'
    }),
    'en': OrderedDict({
        'DEFAUT1': 'DEFAULT',
        'CHOIX1': 'CHOICE',
        'AIDE1': 'HELP'
    })}

if __name__ == "__main__":
    # Remove all the content generated folder if they already exist
    shutil.rmtree('lists', ignore_errors=True)
    shutil.rmtree('definitions', ignore_errors=True)

    # ~> SELECT MODULES AND LANGUAGE TO EXPORT
    langs = ['fr', 'en']
    modules = ['artemis', 'postel3d', 'sisyphe', 'stbtel', 'telemac2d', 'telemac3d', 'tomawac']
    # langs = ['fr']
    # modules = ['telemac2d']

    for module in modules:
        dicofile = os.path.join('dico', '{}.dico'.format(module))
        print("~> Module {} (language(s) = {})".format(module, langs))
        generate_files_from_dico(dicofile, langs, module)

    print('My work is done...')
