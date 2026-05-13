import base64
import json
import httpx
from app.core.config import settings
from app.schemas.scan import ScanResult

GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "meta-llama/llama-4-scout-17b-16e-instruct"

PROMPT = """Siz avtomobil ehtiyot qismlari bo'yicha mutaxasssissiz.
Ushbu rasmni tahlil qiling va ko'rsatilgan avtomobil qismini aniqlang.
FAQAT quyidagi maydonlar bilan JSON obyektini qaytaring (markdown yoki qo'shimcha matn yo'q):
{
  "part_name": "qism nomi O'ZBEK TILIDA",
  "description": "qismning vazifasi va tavsifi O'ZBEK TILIDA (2-3 jumla)",
  "category": "quyidagilardan biri: Dvigatel, Tormoz, Osma, Elektr, Kuzov, Transmissiya, Sovutish, Egzoz, Yoqilgi, Tyuning, Salon, Boyoq, Boshqa",
  "confidence_score": 0.95
}
confidence_score 0.0 dan 1.0 gacha bo'lishi kerak.
Barcha matnlar O'ZBEK TILIDA bo'lishi SHART."""


async def identify_part_from_image(image_bytes: bytes) -> ScanResult:
    image_b64 = base64.b64encode(image_bytes).decode("utf-8")

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                GROQ_URL,
                headers={
                    "Authorization": f"Bearer {settings.GROQ_API_KEY}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": GROQ_MODEL,
                    "messages": [
                        {
                            "role": "user",
                            "content": [
                                {"type": "text", "text": PROMPT},
                                {
                                    "type": "image_url",
                                    "image_url": {
                                        "url": f"data:image/jpeg;base64,{image_b64}"
                                    },
                                },
                            ],
                        }
                    ],
                    "max_tokens": 400,
                    "temperature": 0.1,
                },
            )

        if response.status_code != 200:
            print(f"[AI ERROR] {response.status_code}: {response.text[:200]}")
            return _error_result("AI xizmatida xatolik. Keyinroq urinib ko'ring.")

        content = response.json()["choices"][0]["message"]["content"].strip()

        if "```json" in content:
            content = content.split("```json")[1].split("```")[0].strip()
        elif "```" in content:
            content = content.split("```")[1].split("```")[0].strip()

        result = json.loads(content)
        return ScanResult(
            part_name=result.get("part_name", "Noma'lum"),
            description=result.get("description", ""),
            category=result.get("category", "Boshqa"),
            confidence_score=float(result.get("confidence_score", 0.5)),
        )

    except json.JSONDecodeError:
        return _error_result("AI javobini o'qib bo'lmadi. Qayta urinib ko'ring.")
    except Exception as e:
        print(f"[AI ERROR] {e}")
        return _error_result("AI xizmatida xatolik yuz berdi.")


def _error_result(msg: str) -> ScanResult:
    return ScanResult(
        part_name="Noma'lum qism",
        description=msg,
        category="Noma'lum",
        confidence_score=0.0,
    )
