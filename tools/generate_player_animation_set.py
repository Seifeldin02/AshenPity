from pathlib import Path
from PIL import Image, ImageEnhance, ImageOps


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "sprites" / "upgrade"
SOURCE = OUT / "player_idle.png"
CANVAS = (96, 96)
FOOT_Y = 91
CENTER_X = 48


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise RuntimeError("source sprite has no visible pixels")
    return bbox


def crop_source() -> Image.Image:
    source = Image.open(SOURCE).convert("RGBA")
    cropped = source.crop(alpha_bbox(source))
    max_h = 87
    if cropped.height > max_h:
        scale = max_h / float(cropped.height)
        cropped = cropped.resize((round(cropped.width * scale), round(cropped.height * scale)), Image.Resampling.LANCZOS)
    return cropped


def tint(image: Image.Image, color: tuple[int, int, int], amount: float) -> Image.Image:
    overlay = Image.new("RGBA", image.size, color + (0,))
    r, g, b, a = image.split()
    overlay.putalpha(a)
    return Image.blend(image, overlay, amount)


def silhouette(image: Image.Image, color: tuple[int, int, int, int], radius: int = 1) -> Image.Image:
    alpha = image.getchannel("A")
    mask = alpha.filter(ImageFilter.MaxFilter(radius * 2 + 1)) if radius > 0 else alpha
    out = Image.new("RGBA", image.size, color)
    out.putalpha(mask)
    return out


def place(body: Image.Image, x_offset: int = 0, y_offset: int = 0, scale=(1.0, 1.0), rotate=0.0, warm_rim=False) -> Image.Image:
    w = max(1, round(body.width * scale[0]))
    h = max(1, round(body.height * scale[1]))
    transformed = body.resize((w, h), Image.Resampling.LANCZOS)
    if rotate != 0.0:
        transformed = transformed.rotate(rotate, expand=True, resample=Image.Resampling.BICUBIC)
    if warm_rim:
        transformed = tint(transformed, (255, 186, 118), 0.05)

    canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    x = round(CENTER_X - transformed.width * 0.5 + x_offset)
    y = round(FOOT_Y - transformed.height + y_offset)

    # Soft contact shadow baked into the frame so the sprite visually belongs to the floor.
    shadow = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    sx0, sy0, sx1, sy1 = 26 + x_offset // 3, FOOT_Y - 7, 70 + x_offset // 3, FOOT_Y + 1
    for yy in range(sy0, sy1):
        for xx in range(sx0, sx1):
            nx = (xx - (sx0 + sx1) * 0.5) / max((sx1 - sx0) * 0.5, 1)
            ny = (yy - (sy0 + sy1) * 0.5) / max((sy1 - sy0) * 0.5, 1)
            if nx * nx + ny * ny <= 1.0:
                shadow.putpixel((xx, yy), (4, 3, 5, 105))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(transformed, (x, y))
    return canvas


def make_slash_frame(body: Image.Image, name: str, color: tuple[int, int, int, int], length: int, lift: int, rotate: float) -> Image.Image:
    frame = place(body, x_offset=3, y_offset=-1, scale=(1.02, 0.99), rotate=rotate, warm_rim=True)
    blade = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    cx, cy = 59, 51 - lift
    pts = [
        (cx - 3, cy + 18),
        (cx + length, cy - 12),
        (cx + length + 6, cy - 7),
        (cx + 2, cy + 23),
    ]
    ImageDraw.Draw(blade).polygon(pts, fill=color)
    ImageDraw.Draw(blade).polygon([(cx + 2, cy + 15), (cx + length - 4, cy - 8), (cx + length, cy - 5), (cx + 6, cy + 18)], fill=(255, 236, 178, 150))
    frame.alpha_composite(blade)
    frame.save(OUT / name)


def main() -> None:
    body = crop_source()
    OUT.mkdir(parents=True, exist_ok=True)

    idle = place(body, warm_rim=True)
    idle.save(OUT / "player_idle.png")
    place(body, y_offset=-1, scale=(1.0, 1.015), warm_rim=True).save(OUT / "player_idle_2.png")

    place(body, x_offset=-3, y_offset=1, scale=(1.03, 0.985), rotate=-1.8, warm_rim=True).save(OUT / "player_run_1.png")
    place(body, x_offset=2, y_offset=-1, scale=(0.99, 1.015), rotate=1.3, warm_rim=True).save(OUT / "player_run_2.png")
    place(body, x_offset=4, y_offset=0, scale=(1.02, 0.99), rotate=2.2, warm_rim=True).save(OUT / "player_run_3.png")
    place(body, x_offset=-1, y_offset=-1, scale=(1.0, 1.01), rotate=-0.8, warm_rim=True).save(OUT / "player_run_4.png")

    make_slash_frame(body, "player_light_1.png", (244, 228, 176, 210), 33, 0, -5.0)
    make_slash_frame(body, "player_light_2.png", (255, 192, 108, 220), 39, 5, 2.0)
    make_slash_frame(body, "player_light_3.png", (255, 148, 74, 225), 46, -3, -7.0)
    make_slash_frame(body, "player_heavy.png", (255, 98, 52, 230), 54, 8, -9.0)
    make_slash_frame(body, "player_collect.png", (255, 216, 94, 245), 62, 0, -12.0)

    place(body, x_offset=-6, y_offset=3, scale=(1.16, 0.82), rotate=-8.0, warm_rim=True).save(OUT / "player_dodge.png")
    place(tint(body, (255, 80, 65), 0.22), x_offset=-2, y_offset=1, scale=(0.98, 1.0), rotate=-5.0).save(OUT / "player_hurt.png")
    place(tint(body, (150, 145, 140), 0.25), x_offset=0, y_offset=8, scale=(1.14, 0.58), rotate=-78.0).save(OUT / "player_death.png")
    place(body, x_offset=0, y_offset=0, scale=(1.0, 1.0), rotate=-3.0, warm_rim=True).save(OUT / "player_parry.png")
    place(tint(body, (255, 168, 92), 0.08), x_offset=0, y_offset=0, scale=(0.99, 1.01), warm_rim=True).save(OUT / "player_heal.png")

    # Kept for older code paths/tests, but PlayerVisual now uses the attack-specific frames.
    Image.open(OUT / "player_light_1.png").save(OUT / "player_attack.png")


if __name__ == "__main__":
    from PIL import ImageDraw, ImageFilter

    main()
