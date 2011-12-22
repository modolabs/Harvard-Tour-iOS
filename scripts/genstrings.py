#!/usr/bin/python      

import getopt
import sys
import codecs
import os
import re

NO_COMMENT_PROVIDED = 'No comment provided by engineer.'
OBJC_NIL = 'nil'

def update_localization(lang, directories, filename='Localizable.strings'):
    print('Updating language %s...' % lang)
    if not os.path.exists(project_dir + '/Localization/'):
        raise Exception("Could not find Localization directory in %s" % project_dir)
    
    comment_start_pat = re.compile('/\*(.+)')
    comment_end_pat = re.compile('(.+)\*/$')
    value_start_pat = re.compile('"(.+)" = "(.+)"')
    value_end_pat = re.compile('"(.+)";$')
    
    locale_dir = project_dir + '/Localization/' + lang + '.lproj'
    if not os.path.exists(locale_dir):
        os.mkdirs(locale_dir)

    strings_file = locale_dir + '/' + filename
    strings_dict = {}

    # parse existing localization files
    if (os.path.exists(strings_file)):
        inFile = codecs.open(strings_file, 'r', encoding='utf-16')

        comment_parts = []
        current_comment = None
        parsing_comment = False
    
        value_parts = []
        current_label = None
        current_value = None
        parsing_value = False

        for line in inFile:
            if not parsing_comment and not parsing_value:
                match = comment_start_pat.match(line)
                if match:
                    comment_parts.append(match.group(1))
                    parsing_comment = True

                    match = comment_end_pat.match(line)
                    if match:
                        current_comment = ''.join(comment_parts).strip('*/ ')
                        comment_parts = []
                        parsing_comment = False
                        continue
    
            if parsing_comment:
                match = comment_end_pat.match(line)
                if match:
                    comment_parts.append(match.group(1))
                    current_comment = '\n'.join(comment_parts).strip()
                    comment_parts = []
                    parsing_comment = False
                else:
                    comment_parts.append(line.strip())
                continue
    
            if not parsing_value and current_comment is not None:
                match = value_start_pat.match(line)
                if match:
                    current_label = match.group(1)
                    value_parts.append(match.group(2))
                    parsing_value = True

                    match = value_end_pat.match(line)
                    if match:
                        current_value = ''.join(value_parts)
                        value_parts = []
                        parsing_value = False
                        continue
    
            if parsing_value:
                match = value_end_pat.match(line)
                if match:
                    value_parts.append(match.group(1))
                    current_value = '\n'.join(value_parts)
                    value_parts = []
                    parsing_value = False
                else:
                    value_parts.append(line.strip())
    
            if current_comment is not None and current_value is not None and current_label is not None:
                if not strings_dict.has_key(current_label):
                    strings_dict[current_label] = {}

                if current_comment == NO_COMMENT_PROVIDED:
                    current_comment = OBJC_NIL
                strings_dict[current_label][current_comment] = current_value
                current_comment = None
                current_label = None
                current_value = None
      
        inFile.close();

    # TODO: this assumes no multiline comments
    local_string_pat = re.compile('NSLocalizedString\(\s*@"(.+)"\s*,(.+)\)[\s\]]*;?\s*$')
    for directory in directories:
        for (subdir, dir, files) in os.walk(directory):
            for afile in files:
                name = os.path.basename(afile)
                if (name.endswith(".m")):
                    mFile = open(subdir + "/" + name, 'r')
                    for line in mFile:
                        match = local_string_pat.search(line)
                        if (match):
                            label = match.group(1)
                            comment = match.group(2).strip('"@ ')

                            if not strings_dict.has_key(label):
                                strings_dict[label] = {}

                            if not strings_dict[label].has_key(comment):
                                strings_dict[label][comment] = label

    outfile = codecs.open(strings_file, 'w', encoding='utf-16')

    labels = strings_dict.keys()
    labels.sort()

    for label in labels:
        current_dict = strings_dict[label]
        comments = current_dict.keys()
        comments.sort()

        for comment in comments:
            value = current_dict[comment]

            if comment == OBJC_NIL:
                comment = NO_COMMENT_PROVIDED
            else:
                comment = comment.strip('"@ ')

            outfile.write("""/* %s */
"%s" = "%s";

""" % (comment, label, value))

    outfile.close()


### set up environment

script = sys.argv[0]
repo_dir = '/'.join(script.split('/')[:-1]) + '/..'
if not os.path.exists(repo_dir + '/.git') or not os.path.exists(repo_dir + '/Projects'):
    raise Exception("This script does not appear to be run from a Kurogo repository")

directories = map(lambda(x): repo_dir + '/' + x, ['Application', 'Modules', 'Common'])

### retrieve options

project_name = None
languages = []

options, remainder = getopt.getopt(sys.argv[1:], 'l:p:', ['project=', 'lang='])

for opt, arg in options:
    if opt in ('-p', '--project'):
        project_name = arg

    elif opt in ('-l', '--lang'):
        languages.append(arg)

if project_name is None:
    print('No project specified, assuming Universitas')
    print('(you can specify a project using -p or --project)')
    project_name = 'Universitas'

project_dir = repo_dir + '/Projects/' + project_name
directories += map(lambda(x): project_dir + '/' + x, ['Application', 'Common', 'Modules'])

if len(languages) == 0:
    print('No language specified, searching for language directories')
    print('(you can specify a language using -l or --lang)')
    # select all languages
    lang_pat = re.compile('([A-Za-z_]+).lproj')
    loc_dir = project_dir + '/Localization'
    for filename in os.listdir(loc_dir):
        match = lang_pat.match(filename)
        if match:
            languages.append(match.group(1))
    print('Found these languages: %s' % ' '.join(languages))

### main

for lang in languages:
    update_localization(lang, directories)

