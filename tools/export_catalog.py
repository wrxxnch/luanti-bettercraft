#!/usr/bin/env python3
"""Exporta registros Lua e assets do BetterCraft para um catálogo JSON do site.

Uso:
  python3 tools/export_catalog.py --game-root games/bettercraft \
      --output ../blockframestudio/src/data/bettercraftCatalog.json

O parser é estático de propósito: não inicia o jogo e não modifica o repositório.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

REGISTRATION_RE = re.compile(
    r"(?:(?:core|minetest)\.register_(node|craftitem|tool)|"
    r"(?:natural_habitat)\.register_(multinode))\s*\(",
    re.IGNORECASE,
)
STRING_RE = re.compile(r"(['\"])((?:\\.|(?!\1).)*)\1", re.DOTALL)
FIELD_STRING_RE = {
    field: re.compile(rf"\b{field}\s*=\s*(['\"])((?:\\.|(?!\1).)*)\1", re.DOTALL)
    for field in ("description", "drawtype", "mesh", "inventory_image", "wield_image", "paramtype", "paramtype2")
}


def decode_lua_string(value: str) -> str:
    """Decodifica apenas escapes comuns usados nos nomes e paths dos mods."""
    replacements = {
        r"\\n": "\n",
        r"\\r": "\r",
        r"\\t": "\t",
        r'\\"': '"',
        r"\\'": "'",
        r"\\\\": "\\",
    }
    for escaped, decoded in replacements.items():
        value = value.replace(escaped, decoded)
    return value


def skip_string(text: str, index: int) -> int:
    quote = text[index]
    index += 1
    while index < len(text):
        if text[index] == "\\":
            index += 2
        elif text[index] == quote:
            return index + 1
        else:
            index += 1
    return len(text)


def skip_comment(text: str, index: int) -> int:
    if text.startswith("--[[", index):
        end = text.find("]]", index + 4)
        return len(text) if end < 0 else end + 2
    end = text.find("\n", index + 2)
    return len(text) if end < 0 else end


def matching_delimiter(text: str, start: int, opening: str = "(") -> int:
    pairs = {"(": ")", "{": "}", "[": "]"}
    closing = pairs[opening]
    depth = 0
    index = start
    while index < len(text):
        if text[index] in "'\"":
            index = skip_string(text, index)
            continue
        if text.startswith("--", index):
            index = skip_comment(text, index)
            continue
        if text[index] == opening:
            depth += 1
        elif text[index] == closing:
            depth -= 1
            if depth == 0:
                return index
        index += 1
    return -1


def first_argument(text: str, opening_end: int) -> tuple[str | None, int]:
    index = opening_end
    while index < len(text) and text[index].isspace():
        index += 1
    if index >= len(text) or text[index] not in "'\"":
        return None, index
    end = skip_string(text, index)
    raw = text[index + 1 : end - 1]
    return decode_lua_string(raw), end


def extract_table_field(body: str, field: str) -> str:
    match = re.search(rf"\b{re.escape(field)}\s*=\s*\{{", body)
    if not match:
        return ""
    end = matching_delimiter(body, match.end() - 1, "{")
    return body[match.end() : end] if end >= 0 else ""


def quoted_values(value: str) -> list[str]:
    return [decode_lua_string(match.group(2)) for match in STRING_RE.finditer(value)]


def parse_groups(body: str) -> dict[str, int | float | bool]:
    raw = extract_table_field(body, "groups")
    result: dict[str, int | float | bool] = {}
    for match in re.finditer(
        r"(?:\[\s*(['\"])(.*?)\1\s*\]|([A-Za-z_][\w]*))\s*=\s*(-?\d+(?:\.\d+)?|true|false)",
        raw,
    ):
        key = match.group(2) or match.group(3)
        value = match.group(4)
        result[key] = value == "true" if value in ("true", "false") else float(value) if "." in value else int(value)
    return result


def field_string(body: str, field: str) -> str | None:
    match = FIELD_STRING_RE[field].search(body)
    return decode_lua_string(match.group(2)) if match else None


def clean_texture(value: str | None) -> str | None:
    if not value:
        return None
    # Luanti texture modifiers are useful in-game but not filenames.
    value = value.split("^")[-1]
    value = value.strip("()")
    return value if value and not value.startswith("[") else None


def parse_registrations(game_root: Path) -> list[dict[str, Any]]:
    registrations: dict[str, dict[str, Any]] = {}
    for lua_file in sorted(game_root.rglob("*.lua")):
        text = lua_file.read_text(encoding="utf-8", errors="replace")
        for match in REGISTRATION_RE.finditer(text):
            registration = (match.group(1) or match.group(2)).lower()
            item_type = "node" if registration == "node" else "item"
            name, after_name = first_argument(text, match.end())
            if not name or not re.match(r"^[\w.-]+:[\w.+-]+$", name):
                continue
            brace = text.find("{", after_name)
            if brace < 0:
                continue
            close = matching_delimiter(text, brace, "{")
            if close < 0:
                continue
            body = text[brace + 1 : close]
            definitions = [(name, body)]
            if registration == "multinode":
                shared = extract_table_field(body, "shared")
                nodes = extract_table_field(body, "nodes")
                definitions = []
                for node_match in re.finditer(r"\[\s*(['\"])(.*?)\1\s*\]\s*=\s*\{", nodes):
                    node_end = matching_delimiter(nodes, node_match.end() - 1, "{")
                    if node_end >= 0:
                        suffix = decode_lua_string(node_match.group(2))
                        definitions.append((name + suffix, shared + "\n" + nodes[node_match.end() : node_end]))
                if not definitions:
                    definitions = [(name, shared or body)]

            for registered_name, definition in definitions:
                tiles = [clean_texture(item) for item in quoted_values(extract_table_field(definition, "tiles"))]
                tiles = [item for item in tiles if item]
                registrations[registered_name] = {
                    "name": registered_name,
                    "type": item_type,
                    "description": field_string(definition, "description") or registered_name,
                    "drawtype": field_string(definition, "drawtype"),
                    "mesh": field_string(definition, "mesh"),
                    "inventory_image": clean_texture(field_string(definition, "inventory_image")),
                    "wield_image": clean_texture(field_string(definition, "wield_image")),
                    "tiles": tiles,
                    "paramtype": field_string(definition, "paramtype"),
                    "paramtype2": field_string(definition, "paramtype2"),
                }
    return [registrations[name] for name in sorted(registrations)]


def scan_assets(game_root: Path, asset_base_url: str | None) -> list[dict[str, Any]]:
    assets: list[dict[str, Any]] = []
    for kind in ("textures", "models"):
        for folder in sorted(game_root.rglob(kind)):
            if not folder.is_dir():
                continue
            for path in sorted(item for item in folder.rglob("*") if item.is_file()):
                relative = path.relative_to(game_root).as_posix()
                record: dict[str, Any] = {
                    "name": path.name,
                    "kind": kind[:-1],
                    "path": relative,
                    "extension": path.suffix.lower().lstrip("."),
                    "size_bytes": path.stat().st_size,
                }
                if asset_base_url:
                    record["url"] = asset_base_url.rstrip("/") + "/" + relative
                assets.append(record)
    return assets


def asset_index(assets: Iterable[dict[str, Any]]) -> dict[str, list[dict[str, Any]]]:
    index: dict[str, list[dict[str, Any]]] = {}
    for asset in assets:
        index.setdefault(asset["name"], []).append(asset)
    return index


def attach_assets(items: list[dict[str, Any]], assets: list[dict[str, Any]]) -> None:
    by_name = asset_index(assets)
    for item in items:
        texture_names = set(item["tiles"])
        for field in ("inventory_image", "wield_image"):
            if item[field]:
                texture_names.add(item[field])
        item["texture_assets"] = [
            asset for name in sorted(texture_names) for asset in by_name.get(Path(name).name, []) if asset["kind"] == "texture"
        ]
        model_names = {Path(item["mesh"]).name} if item["mesh"] else set()
        item["model_assets"] = [
            asset for name in sorted(model_names) for asset in by_name.get(name, []) if asset["kind"] == "model"
        ]


def asset_mod(asset: dict[str, Any]) -> str:
    parts = Path(asset["path"]).parts
    for folder in ("textures", "models"):
        if folder in parts:
            index = parts.index(folder)
            if index >= 2:
                return parts[index - 1]
    return "unknown_mod"


def copy_assets(game_root: Path, assets: list[dict[str, Any]], output_dir: Path, separated: bool) -> None:
    used_names: set[tuple[str, str]] = set()
    for asset in assets:
        source = game_root / asset["path"]
        kind = "textures" if asset["kind"] == "texture" else "models"
        filename = asset["name"]
        if separated:
            mod = asset_mod(asset)
            key = (kind, mod, filename)
            if key in used_names:
                stem = Path(filename).stem
                suffix = Path(filename).suffix
                filename = f"{stem}__{len(used_names)}{suffix}"
                counter = 2
                while (kind, mod, filename) in used_names:
                    filename = f"{stem}__{len(used_names)}_{counter}{suffix}"
                    counter += 1
            used_names.add((kind, mod, filename))
            destination = output_dir / kind / mod / filename
        else:
            key = (kind, filename)
            if key in used_names:
                stem = Path(filename).stem
                suffix = Path(filename).suffix
                filename = f"{stem}__{asset_mod(asset)}{suffix}"
                counter = 2
                while (kind, filename) in used_names:
                    filename = f"{stem}__{asset_mod(asset)}_{counter}{suffix}"
                    counter += 1
            used_names.add((kind, filename))
            destination = output_dir / kind / filename
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game-root", type=Path, required=True, help="games/bettercraft")
    parser.add_argument("--output", type=Path, required=True, help="arquivo JSON de saída")
    parser.add_argument(
        "--asset-base-url",
        default="https://raw.githubusercontent.com/wrxxnch/luanti-bettercraft/main/games/bettercraft",
        help="prefixo para URLs públicas dos assets; use vazio para omitir URLs",
    )
    parser.add_argument(
        "--gentexture",
        action="store_true",
        help="gera textures/ e models/ planos, sem subpastas de mods",
    )
    parser.add_argument(
        "--gentexture-separated",
        action="store_true",
        help="gera textures/<mod>/ e models/<mod>/ separados por mod",
    )
    args = parser.parse_args()

    game_root = args.game_root.resolve()
    if not game_root.is_dir():
        parser.error(f"game root inexistente: {game_root}")

    items = parse_registrations(game_root)
    assets = scan_assets(game_root, args.asset_base_url or None)
    attach_assets(items, assets)
    # O arquivo público é deliberadamente um array puro. Os dados auxiliares
    # de assets são usados para validar e relacionar arquivos, mas não entram
    # no JSON final para manter o schema solicitado pelo site.
    public_items = [
        {key: item[key] for key in (
            "type", "name", "description", "drawtype", "mesh", "inventory_image",
            "wield_image", "tiles", "paramtype", "paramtype2"
        )}
        for item in items
    ]
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(public_items, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if args.gentexture and args.gentexture_separated:
        parser.error("use apenas uma opção entre --gentexture e --gentexture-separated")
    if args.gentexture or args.gentexture_separated:
        assets_dir = args.output.parent
        for kind in ("textures", "models"):
            (assets_dir / kind).mkdir(parents=True, exist_ok=True)
        copy_assets(game_root, assets, assets_dir, separated=args.gentexture_separated)
    print(f"wrote {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
