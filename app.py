from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoModelForSeq2SeqLM, NllbTokenizer
import re
import sys
import typing as tp
import unicodedata
from sacremoses import MosesPunctNormalizer
import uvicorn  # Импортируем Uvicorn


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


# Перевод текста
def translate(
    text: str,
    src_lang: str = "rus_Cyrl",
    tgt_lang: str = "eng_Latn",
    a: int = 32,
    b: int = 3,
    max_input_length: int = 1024,
    num_beams: int = 4,
    **kwargs
) -> tp.List[str]:
    """Перевод текста"""
    tokenizer.src_lang = src_lang
    tokenizer.tgt_lang = tgt_lang
    inputs = tokenizer(
        text,
        return_tensors="pt",
        padding=True,
        truncation=True,
        max_length=max_input_length,
    )
    model.eval()  # Отключаем режим тренировки
    result = model.generate(
        **inputs.to(model.device),
        forced_bos_token_id=tokenizer.convert_tokens_to_ids(tgt_lang),
        max_new_tokens=int(a + b * inputs.input_ids.shape[1]),
        num_beams=num_beams,
        **kwargs
    )
    return tokenizer.batch_decode(result, skip_special_tokens=True)


# Инициализация FastAPI
app = FastAPI()


# Классы для входных данных
class TranslationRequest(BaseModel):
    text: str
    src_lang: str  # Язык исходного текста
    tgt_lang: str  # Язык перевода


# Создаем роут для перевода текста
@app.post("/translate/")
def translate_text(request: TranslationRequest):
    # Предобработка текста
    clean_text = preproc(request.text)
    # Перевод текста
    translation = translate(
        clean_text,
        src_lang=request.src_lang,
        tgt_lang=request.tgt_lang,
    )
    # Возвращаем результат
    return {"translation": translation}


# Функция для запуска Uvicorn
def main():
    uvicorn.run(app)


# Запуск через uvicorn, если скрипт вызывается напрямую
if __name__ == "__main__":
    main()
