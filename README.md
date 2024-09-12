# mansi5G  
# Ссылки
Ссылка на гугл диск с моделью: запривачена, до подведения итогов  

Ссылка на hugging face:  запривачена, до подведения итогов  

# Тест модели  
Последний тест модели с метриками: NLLB_Preproc_text.ipynb  

BLEU Russ->Mansi 24.97, chrF2++ = 49.07 / Mansi->Russ 27.06, chrF2++ = 53.04 (1600 test words)


# Пример использование модели
```python
from transformers import AutoModelForSeq2SeqLM, NllbTokenizer

MODEL_SAVE_PATH = 'Папка с моделью'

model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_SAVE_PATH).cuda();
tokenizer = NllbTokenizer.from_pretrained(MODEL_SAVE_PATH)

# Функция для перевода текста
def translate(
    text, src_lang='rus_Cyrl', tgt_lang='eng_Latn',
    a=32, b=3, max_input_length=1024, num_beams=4, **kwargs
):
    """Turn a text or a list of texts into a list of translations"""
    tokenizer.src_lang = src_lang
    tokenizer.tgt_lang = tgt_lang
    inputs = tokenizer(
        text, return_tensors='pt', padding=True, truncation=True,
        max_length=max_input_length
    )
    model.eval() # turn off training mode
    result = model.generate(
        **inputs.to(model.device),
        forced_bos_token_id=tokenizer.convert_tokens_to_ids(tgt_lang),
        max_new_tokens=int(a + b * inputs.input_ids.shape[1]),
        num_beams=num_beams, **kwargs
    )
    return tokenizer.batch_decode(result, skip_special_tokens=True)


# Mansi -> Russian
t = 'А̄лы ма̄т о̄лнэ то̄ва ӯйхулт вит та̄нти палтыланыл ӯньщим о̄луӈкв ханьщувласт,  таи ма̄гсыл хо̄са вит тал о̄луӈкв вēрмегы.'
print(translate(t, 'mns_Cyrl', 'rus_Cyrl'))

# Russian -> Mansi
t = 'Его много народу знает, во многих странах известен.'
print(translate(t, 'rus_Cyrl', 'mns_Cyrl'))
```  
Для улучшения качества перевода рекомендуется предварительная обработка текста:  

```python

import re
import sys
import typing as tp
import unicodedata
from sacremoses import MosesPunctNormalizer


mpn = MosesPunctNormalizer(lang="en")
mpn.substitutions = [
    (re.compile(r), sub) for r, sub in mpn.substitutions
]


def get_non_printing_char_replacer(replace_by: str = " ") -> tp.Callable[[str], str]:
    non_printable_map = {
        ord(c): replace_by
        for c in (chr(i) for i in range(sys.maxunicode + 1))
        if unicodedata.category(c) in {"C", "Cc", "Cf", "Cs", "Co", "Cn"}
    }

    def replace_non_printing_char(line) -> str:
        return line.translate(non_printable_map)

    return replace_non_printing_char


replace_nonprint = get_non_printing_char_replacer(" ")


def preproc(text):
    clean = mpn.normalize(text)
    clean = replace_nonprint(clean)
    clean = unicodedata.normalize("NFKC", clean)
    return clean

text = preproc(text)

```  
