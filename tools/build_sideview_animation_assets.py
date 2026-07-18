from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "sprites" / "sideview" / "source"
FRAME_DIR = ROOT / "assets" / "sprites" / "sideview" / "wanderer"
EFFECT_DIR = ROOT / "assets" / "effects" / "sideview" / "ash_crosscut"
WEAPON_DIR = ROOT / "assets" / "sprites" / "sideview" / "weapons"

FRAME_CANVAS = (512, 512)
FRAME_BASELINE_Y = 448
FRAME_ROOT_X = 256
TARGET_STANDING_HEIGHT = 320

SHEETS = {
    "idle": ("wanderer_idle_alpha.png", 4),
    "run": ("wanderer_run_alpha.png", 8),
    "light": ("wanderer_light_alpha.png", 7),
    "heavy": ("wanderer_heavy_alpha.png", 8),
    "parry": ("wanderer_parry_alpha.png", 6),
    "skill": ("wanderer_skill_alpha.png", 8),
    "death": ("wanderer_death_alpha.png", 6),
}

# Visual-only vertical offsets preserve contact/compression/flight without moving the collider.
BASELINE_OFFSETS = {
    "idle": [0, 1, 0, -1],
    "run": [0, 4, -3, -10, 0, 4, -3, -10],
}


def split_cells(image: Image.Image, count: int) -> list[Image.Image]:
    cells: list[Image.Image] = []
    for index in range(count):
        left = round(index * image.width / count)
        right = round((index + 1) * image.width / count)
        cells.append(image.crop((left, 0, right, image.height)))
    return cells


def split_character_poses(image: Image.Image, count: int) -> list[Image.Image]:
    """Split at low-alpha valleys so wide capes never bleed into adjacent poses."""
    alpha = image.getchannel("A")
    column_ink = []
    for x in range(image.width):
        column = alpha.crop((x, 0, x + 1, image.height))
        column_ink.append(sum(pixel > 96 for pixel in column.get_flattened_data()))

    nominal_width = image.width / count
    search_radius = max(48, round(nominal_width * 0.27))
    cuts = [0]
    for index in range(1, count):
        nominal = round(index * nominal_width)
        left = max(cuts[-1] + 32, nominal - search_radius)
        right = min(image.width, nominal + search_radius + 1)
        minimum_ink = min(column_ink[left:right])
        candidates = [x for x in range(left, right) if column_ink[x] == minimum_ink]
        cuts.append(min(candidates, key=lambda x: abs(x - nominal)))
    cuts.append(image.width)
    return [image.crop((cuts[index], 0, cuts[index + 1], image.height)) for index in range(count)]


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("Frame contains no visible pixels")
    return bbox


def foot_anchor_x(image: Image.Image, bbox: tuple[int, int, int, int]) -> float:
    left, top, right, bottom = bbox
    band_height = max(12, int((bottom - top) * 0.14))
    alpha = image.getchannel("A")
    points: list[int] = []
    for y in range(max(top, bottom - band_height), bottom):
        for x in range(left, right):
            if alpha.getpixel((x, y)) > 96:
                points.append(x)
    if not points:
        return (left + right) * 0.5
    return (min(points) + max(points)) * 0.5


def normalize_character_sheet(name: str, source_name: str, count: int) -> None:
    source = Image.open(SOURCE_DIR / source_name).convert("RGBA")
    cells = split_character_poses(source, count)
    boxes = [alpha_bbox(cell) for cell in cells]
    standing_height = max(bottom - top for _, top, _, bottom in boxes)
    scale = TARGET_STANDING_HEIGHT / standing_height

    for index, (cell, bbox) in enumerate(zip(cells, boxes)):
        left, top, right, bottom = bbox
        anchor_x = foot_anchor_x(cell, bbox)
        cropped = cell.crop((left, top, right, bottom))
        resized = cropped.resize(
            (
                max(1, round(cropped.width * scale)),
                max(1, round(cropped.height * scale)),
            ),
            Image.Resampling.LANCZOS,
        )
        anchor_in_crop = (anchor_x - left) * scale
        paste_x = round(FRAME_ROOT_X - anchor_in_crop)
        frame_offsets = BASELINE_OFFSETS.get(name, [0] * count)
        paste_y = FRAME_BASELINE_Y - resized.height + frame_offsets[index]
        frame = Image.new("RGBA", FRAME_CANVAS, (0, 0, 0, 0))
        frame.alpha_composite(resized, (paste_x, paste_y))
        frame.save(FRAME_DIR / f"{name}_{index:02d}.png", optimize=True)


def normalize_effect_sheet() -> None:
    source = Image.open(SOURCE_DIR / "ash_crosscut_alpha.png").convert("RGBA")
    cells = split_cells(source, 6)
    for index, cell in enumerate(cells):
        left, top, right, bottom = alpha_bbox(cell)
        cropped = cell.crop((left, top, right, bottom))
        scale = min(430 / cropped.width, 390 / cropped.height)
        resized = cropped.resize(
            (round(cropped.width * scale), round(cropped.height * scale)),
            Image.Resampling.LANCZOS,
        )
        frame = Image.new("RGBA", FRAME_CANVAS, (0, 0, 0, 0))
        frame.alpha_composite(
            resized,
            ((FRAME_CANVAS[0] - resized.width) // 2, (FRAME_CANVAS[1] - resized.height) // 2),
        )
        frame.save(EFFECT_DIR / f"ash_crosscut_{index:02d}.png", optimize=True)


def normalize_weapon() -> None:
    source = Image.open(SOURCE_DIR / "starter_longsword_alpha.png").convert("RGBA")
    left, top, right, bottom = alpha_bbox(source)
    cropped = source.crop((left, top, right, bottom))
    target_height = 236
    scale = target_height / cropped.height
    resized = cropped.resize(
        (round(cropped.width * scale), target_height),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", (96, 256), (0, 0, 0, 0))
    canvas.alpha_composite(resized, ((canvas.width - resized.width) // 2, 8))
    canvas.save(WEAPON_DIR / "starter_longsword.png", optimize=True)


def main() -> None:
    FRAME_DIR.mkdir(parents=True, exist_ok=True)
    EFFECT_DIR.mkdir(parents=True, exist_ok=True)
    WEAPON_DIR.mkdir(parents=True, exist_ok=True)
    for name, (source_name, count) in SHEETS.items():
        normalize_character_sheet(name, source_name, count)
    normalize_effect_sheet()
    normalize_weapon()
    print("Built side-view character, weapon, and skill effect frames.")


if __name__ == "__main__":
    main()
