import os,shutil
src_dir = os.path.join('backend','models','models')
dst_dir = os.path.join('backend','models')
files = ['sentiment_model.h5','tokenizer.pkl','label_encoder.pkl']
print('src_dir:', src_dir)
for f in files:
    s = os.path.join(src_dir,f)
    d = os.path.join(dst_dir,f)
    if os.path.exists(s):
        try:
            shutil.copy2(s,d)
            print('copied', s, '->', d)
        except Exception as e:
            print('failed to copy', s, ':', e)
    else:
        print('missing', s)
print('\nResulting files:')
for f in files:
    p = os.path.join(dst_dir,f)
    if os.path.exists(p):
        print(p, 'size=', os.path.getsize(p))
    else:
        print(p, 'MISSING')
