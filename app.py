from fastapi import FastAPI
from pydantic import BaseModel
from transformers import AutoModelForSeq2SeqLM, NllbTokenizer
from typing import List
import uvicorn


MODEL_SAVE_PATH = "./model"
model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_SAVE_PATH)
tokenizer = NllbTokenizer.from_pretrained(MODEL_SAVE_PATH)


app = FastAPI()


class TranslationRequest(BaseModel):
    text: str
    src_lang: str
    tgt_lang: str


class TranslationResponse(BaseModel):
    translations: List[str]


def translate(
    text,
    src_lang="rus_Cyrl",
    tgt_lang="eng_Latn",
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


@app.post("/translate", response_model=TranslationResponse)
def perform_translation(request: TranslationRequest):
    translations = translate(
        text=request.text, src_lang=request.src_lang, tgt_lang=request.tgt_lang
    )
    return TranslationResponse(translations=translations)


def main():
    uvicorn.run(app)


if __name__ == "__main__":
    main()
