from PIL import Image
import io


def compress_image(image_bytes: bytes, max_size_kb: int = 500, quality: int = 85) -> bytes:
    """Compress image to reduce size before sending to AI API."""
    img = Image.open(io.BytesIO(image_bytes))

    # Convert to RGB if needed (e.g., PNG with alpha)
    if img.mode in ("RGBA", "P"):
        img = img.convert("RGB")

    # Resize if too large
    max_dimension = 1024
    if img.width > max_dimension or img.height > max_dimension:
        img.thumbnail((max_dimension, max_dimension), Image.LANCZOS)

    # Compress
    output = io.BytesIO()
    img.save(output, format="JPEG", quality=quality, optimize=True)
    compressed = output.getvalue()

    # If still too large, reduce quality further
    while len(compressed) > max_size_kb * 1024 and quality > 30:
        quality -= 10
        output = io.BytesIO()
        img.save(output, format="JPEG", quality=quality, optimize=True)
        compressed = output.getvalue()

    return compressed
