from fastapi import FastAPI
from pydantic import BaseModel
from transformers import MBart50Tokenizer, MBartForConditionalGeneration
import torch
import uvicorn


app = FastAPI()

# Загрузите модель и токенизатор из локальной папки
model_path = "./model"
tokenizer_path = "./model"

model = MBartForConditionalGeneration.from_pretrained(
    "facebook/mbart-large-50-many-to-many-mmt"
)
tokenizer = MBart50Tokenizer.from_pretrained(
    "facebook/mbart-large-50-many-to-many-mmt", src_lang="ru_RU"
)


# Классы для FastAPI
class TranslationRequest(BaseModel):
    text: str
    target_lang: str


class TranslationResponse(BaseModel):
    translation: str


# Маршрут для перевода текста
@app.post("/translate", response_model=TranslationResponse)
async def translate(request: TranslationRequest):
    # Токенизируем входной текст
    model_inputs = tokenizer(request.text, return_tensors="pt")

    # Принудительно задаем язык на основе входных данных
    forced_bos_token_id = tokenizer.lang_code_to_id[request.target_lang]

    # Генерируем перевод
    generated_tokens = model.generate(
        **model_inputs, forced_bos_token_id=forced_bos_token_id
    )

    # Декодируем результат в строку
    translation = tokenizer.batch_decode(generated_tokens, skip_special_tokens=True)

    # Возвращаем перевод в виде ответа
    return TranslationResponse(translation=translation[0])


# Пример вызова для проверки локально
if __name__ == "__main__":
    uvicorn.run(app)
