import importlib
import services.ml_service as m
importlib.reload(m)
print('model loaded:', bool(getattr(m.ml_service,'model',None)), 'tokenizer loaded:', bool(getattr(m.ml_service,'tokenizer',None)))
