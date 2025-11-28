import os,hashlib
paths=[
 'backend/models/sentiment_model.h5',
 'backend/models/models/sentiment_model.h5',
 'backend/models/tokenizer.pkl',
 'backend/models/models/tokenizer.pkl',
 'backend/models/label_encoder.pkl',
 'backend/models/models/label_encoder.pkl'
]
for p in paths:
    if os.path.exists(p):
        s=os.path.getsize(p)
        try:
            with open(p,'rb') as f:
                data=f.read()
                h=hashlib.sha1(data).hexdigest()
        except Exception as e:
            h=str(e)
        print(f"{p}: size={s}, sha1={h}")
    else:
        print(f"{p}: MISSING")
