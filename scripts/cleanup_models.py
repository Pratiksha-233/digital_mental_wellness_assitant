import os, shutil
base = os.path.join('backend','models')
# find zero-byte files
zeros = []
for root, dirs, files in os.walk(base):
    for f in files:
        p = os.path.join(root,f)
        try:
            if os.path.getsize(p) == 0:
                zeros.append(p)
        except OSError:
            pass
if zeros:
    print('Zero-byte files found:')
    for z in zeros:
        print('  Deleting', z)
        try:
            os.remove(z)
        except Exception as e:
            print('   Failed to remove', z, e)
else:
    print('No zero-byte files found.')

# move nested folder if exists
nested = os.path.join(base,'models')
backup = nested + '.backup'
if os.path.exists(nested):
    # remove existing backup if present
    if os.path.exists(backup):
        print('Removing existing backup at', backup)
        shutil.rmtree(backup)
    print('Moving nested models folder to', backup)
    shutil.move(nested, backup)
else:
    print('No nested models folder found at', nested)

# list remaining files
print('\nRemaining files in', base)
for entry in os.listdir(base):
    p = os.path.join(base, entry)
    if os.path.isfile(p):
        print(' ', entry, os.path.getsize(p))
    else:
        print(' ', entry, '(dir)')
