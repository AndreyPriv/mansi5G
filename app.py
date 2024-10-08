from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from transformers import AutoModelForSeq2SeqLM, NllbTokenizer
from typing import List
import re
import sys
import typing as tp
import unicodedata
from sacremoses import MosesPunctNormalizer
import uvicorn

# Инициализация модели и токенизатора
MODEL_SAVE_PATH = "./model"
model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_SAVE_PATH)
tokenizer = NllbTokenizer.from_pretrained(MODEL_SAVE_PATH)

# Инициализация нормализатора
mpn = MosesPunctNormalizer(lang="en")
mpn.substitutions = [(re.compile(r), sub) for r, sub in mpn.substitutions]


# Функция для замены непечатаемых символов
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


# Предобработка текста
def preproc(text: str) -> str:
    clean = mpn.normalize(text)
    clean = replace_nonprint(clean)
    clean = unicodedata.normalize("NFKC", clean)
    return clean


app = FastAPI()

# Добавляем CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Разрешаем все источники
    allow_credentials=True,
    allow_methods=["*"],  # Разрешаем все методы
    allow_headers=["*"],  # Разрешаем все заголовки
)


class TranslationRequest(BaseModel):
    text: str
    src_lang: str
    tgt_lang: str


class TranslationResponse(BaseModel):
    translations: List[str]


# Функция перевода текста
def translate(
    text: str,
    src_lang="rus_Cyrl",
    tgt_lang="mns_Cyrl",
    a=32,
    b=3,
    max_input_length=1024,
    num_beams=4,
    **kwargs
):
    tokenizer.src_lang = src_lang
    tokenizer.tgt_lang = tgt_lang
    inputs = tokenizer(
        text,
        return_tensors="pt",
        padding=True,
        truncation=True,
        max_length=max_input_length,
    )
    model.eval()
    result = model.generate(
        **inputs.to(model.device),
        forced_bos_token_id=tokenizer.convert_tokens_to_ids(tgt_lang),
        max_new_tokens=int(a + b * inputs.input_ids.shape[1]),
        num_beams=num_beams,
        **kwargs
    )
    return tokenizer.batch_decode(result, skip_special_tokens=True)


# Обработка POST-запроса на перевод текста
@app.post("/translate", response_model=TranslationResponse)
def perform_translation(request: TranslationRequest):
    # Предобработка текста
    clean_text = preproc(request.text)
    translations = translate(
        text=clean_text, src_lang=request.src_lang, tgt_lang=request.tgt_lang
    )

    return TranslationResponse(translations=translations)


# Функция запуска Uvicorn
def main():
    uvicorn.run(app, host="0.0.0.0", port=8000)


if __name__ == "__main__":
    main()
