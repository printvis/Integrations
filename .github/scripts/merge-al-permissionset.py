#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

KNOWN_TYPE_ORDER = {
    "tabledata": 0,
    "table": 1,
    "report": 2,
    "codeunit": 3,
    "xmlport": 4,
    "page": 5,
    "query": 6,
}


class PermissionSetError(ValueError):
    pass


class MergeConflictError(PermissionSetError):
    pass


@dataclass(frozen=True)
class Entry:
    key: str
    text: str
    object_type: str


@dataclass(frozen=True)
class ParsedPermissionSet:
    header_lines: tuple[str, ...]
    assignment_prefix: str
    continuation_indent: str
    entries: tuple[Entry, ...]
    footer_lines: tuple[str, ...]
    line_ending: str


def normalize_whitespace(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip())


def normalize_entry_text(value: str) -> str:
    left, right = split_entry(value)
    return f"{normalize_whitespace(left)} = {normalize_whitespace(right)}"


def split_entry(value: str) -> tuple[str, str]:
    if "=" not in value:
        raise PermissionSetError(f"Invalid permission entry (missing '='): {value}")
    left, right = value.split("=", 1)
    left = left.rstrip()
    right = right.lstrip()
    if not left or not right:
        raise PermissionSetError(f"Invalid permission entry: {value}")
    return left, right


def entry_key(value: str) -> str:
    left, _ = split_entry(value)
    return normalize_whitespace(left)


def entry_object_type(value: str) -> str:
    left, _ = split_entry(value)
    return left.strip().split(None, 1)[0].lower()


def detect_line_ending(text: str) -> str:
    return "\r\n" if "\r\n" in text else "\n"


def parse_permission_set(text: str) -> ParsedPermissionSet:
    lines = text.splitlines()
    if not lines:
        raise PermissionSetError("Permission set file is empty")

    permissions_index = None
    permissions_match = None
    for index, line in enumerate(lines):
        match = re.match(r"^(\s*Permissions\s*=\s*)(.*)$", line)
        if match:
            permissions_index = index
            permissions_match = match
            break
    if permissions_index is None or permissions_match is None:
        raise PermissionSetError("Could not find Permissions assignment")

    closing_index = None
    for index in range(permissions_index + 1, len(lines)):
        if lines[index].strip() == "}":
            closing_index = index
            break
    if closing_index is None:
        raise PermissionSetError("Could not find permission set closing brace")

    header_lines = tuple(lines[:permissions_index])
    assignment_prefix = permissions_match.group(1)
    permission_lines = [permissions_match.group(2), *lines[permissions_index + 1 : closing_index]]
    if not permission_lines:
        raise PermissionSetError("Permission set has no permission entries")

    if any(not line.strip() for line in permission_lines):
        raise PermissionSetError("Permission entries must not contain blank lines")

    continuation_indent = ""
    if len(permission_lines) > 1:
        continuation_indent = re.match(r"^(\s*)", permission_lines[1]).group(1)
    if not continuation_indent:
        base_indent = re.match(r"^(\s*)", assignment_prefix).group(1)
        continuation_indent = f"{base_indent}    "

    raw_entries: list[str] = []
    for index, line in enumerate(permission_lines):
        stripped = line.strip()
        is_last = index == len(permission_lines) - 1
        if is_last:
            if not stripped.endswith(";"):
                raise PermissionSetError("Last permission entry must end with ';'")
            stripped = stripped[:-1].rstrip()
        else:
            if not stripped.endswith(","):
                raise PermissionSetError("Permission entries before the last must end with ','")
            stripped = stripped[:-1].rstrip()
        if not stripped:
            raise PermissionSetError("Permission entry must not be empty")
        raw_entries.append(stripped)

    entries: list[Entry] = []
    seen_keys: set[str] = set()
    for value in raw_entries:
        key = entry_key(value)
        if key in seen_keys:
            raise PermissionSetError(f"Duplicate permission entry for '{key}'")
        seen_keys.add(key)
        entries.append(Entry(key=key, text=value, object_type=entry_object_type(value)))

    footer_lines = tuple(lines[closing_index:])
    return ParsedPermissionSet(
        header_lines=header_lines,
        assignment_prefix=assignment_prefix,
        continuation_indent=continuation_indent,
        entries=tuple(entries),
        footer_lines=footer_lines,
        line_ending=detect_line_ending(text),
    )


def merge_scalar(base: str, ours: str, theirs: str, label: str) -> str:
    if ours == theirs or theirs == base:
        return ours
    if ours == base:
        return theirs
    raise MergeConflictError(f"Conflicting changes in {label}")


def equivalent_entries(left: Entry | None, right: Entry | None) -> bool:
    if left is None or right is None:
        return left is right
    return normalize_entry_text(left.text) == normalize_entry_text(right.text)


def choose_rendered_entry(preferred: Entry, fallback: Entry | None = None) -> Entry:
    return preferred if preferred is not None else fallback  # type: ignore[return-value]


def merge_entries(base: ParsedPermissionSet, ours: ParsedPermissionSet, theirs: ParsedPermissionSet) -> dict[str, Entry]:
    base_map = {entry.key: entry for entry in base.entries}
    ours_map = {entry.key: entry for entry in ours.entries}
    theirs_map = {entry.key: entry for entry in theirs.entries}

    merged: dict[str, Entry] = {}
    for key in sorted(set(base_map) | set(ours_map) | set(theirs_map)):
        base_entry = base_map.get(key)
        our_entry = ours_map.get(key)
        their_entry = theirs_map.get(key)

        if base_entry is None:
            if our_entry is None and their_entry is None:
                continue
            if our_entry is None:
                merged[key] = their_entry  # type: ignore[assignment]
                continue
            if their_entry is None:
                merged[key] = our_entry
                continue
            if equivalent_entries(our_entry, their_entry):
                merged[key] = our_entry
                continue
            raise MergeConflictError(f"Conflicting new permission entry for '{key}'")

        if our_entry is None or their_entry is None:
            continue
        if equivalent_entries(our_entry, base_entry):
            merged[key] = choose_rendered_entry(their_entry, our_entry)
            continue
        if equivalent_entries(their_entry, base_entry):
            merged[key] = our_entry
            continue
        if equivalent_entries(our_entry, their_entry):
            merged[key] = our_entry
            continue
        raise MergeConflictError(f"Conflicting updates to permission entry '{key}'")

    return merged


def sort_value(entry: Entry) -> tuple[int, str]:
    return (
        KNOWN_TYPE_ORDER.get(entry.object_type, len(KNOWN_TYPE_ORDER)),
        normalize_entry_text(entry.text).casefold(),
    )


def build_entry_order(base: ParsedPermissionSet, merged_entries: dict[str, Entry]) -> list[Entry]:
    ordered_keys = [entry.key for entry in base.entries if entry.key in merged_entries]
    existing_keys = set(ordered_keys)
    additions = [entry for key, entry in merged_entries.items() if key not in existing_keys]

    for object_type in sorted({entry.object_type for entry in additions}, key=lambda value: (KNOWN_TYPE_ORDER.get(value, len(KNOWN_TYPE_ORDER)), value)):
        candidates = sorted((entry for entry in additions if entry.object_type == object_type), key=sort_value)
        last_index = None
        for index, key in enumerate(ordered_keys):
            if merged_entries[key].object_type == object_type:
                last_index = index
        if last_index is not None:
            insertion_index = last_index + 1
        else:
            insertion_index = len(ordered_keys)
            new_type_rank = KNOWN_TYPE_ORDER.get(object_type, len(KNOWN_TYPE_ORDER))
            for index, key in enumerate(ordered_keys):
                current_type_rank = KNOWN_TYPE_ORDER.get(merged_entries[key].object_type, len(KNOWN_TYPE_ORDER))
                if current_type_rank > new_type_rank:
                    insertion_index = index
                    break
        ordered_keys[insertion_index:insertion_index] = [entry.key for entry in candidates]

    return [merged_entries[key] for key in ordered_keys]


def render_permission_set(template: ParsedPermissionSet, header_lines: tuple[str, ...], entries: Iterable[Entry], footer_lines: tuple[str, ...]) -> str:
    ordered_entries = list(entries)
    if not ordered_entries:
        raise PermissionSetError("Permission set must contain at least one entry")

    lines = list(header_lines)
    for index, entry in enumerate(ordered_entries):
        punctuation = ";" if index == len(ordered_entries) - 1 else ","
        if index == 0:
            lines.append(f"{template.assignment_prefix}{entry.text}{punctuation}")
        else:
            lines.append(f"{template.continuation_indent}{entry.text}{punctuation}")
    lines.extend(footer_lines)
    return template.line_ending.join(lines)


def merge_permission_sets(base_text: str, ours_text: str, theirs_text: str) -> str:
    base = parse_permission_set(base_text)
    ours = parse_permission_set(ours_text)
    theirs = parse_permission_set(theirs_text)

    header_lines_text = merge_scalar(
        base.line_ending.join(base.header_lines),
        ours.line_ending.join(ours.header_lines),
        theirs.line_ending.join(theirs.header_lines),
        "permission set header",
    )
    footer_lines_text = merge_scalar(
        base.line_ending.join(base.footer_lines),
        ours.line_ending.join(ours.footer_lines),
        theirs.line_ending.join(theirs.footer_lines),
        "permission set footer",
    )

    merged_entries = merge_entries(base, ours, theirs)
    ordered_entries = build_entry_order(base, merged_entries)

    merged_header_lines = tuple(header_lines_text.splitlines())
    merged_footer_lines = tuple(footer_lines_text.splitlines())
    return render_permission_set(ours, merged_header_lines, ordered_entries, merged_footer_lines)


def validate_permission_set(text: str, source: str) -> None:
    parse_permission_set(text)


def merge_files(base_path: Path, ours_path: Path, theirs_path: Path) -> int:
    try:
        merged = merge_permission_sets(
            base_path.read_text(encoding="utf-8"),
            ours_path.read_text(encoding="utf-8"),
            theirs_path.read_text(encoding="utf-8"),
        )
    except PermissionSetError as error:
        print(f"al-permset merge driver: {error}", file=sys.stderr)
        return 1

    ours_path.write_text(merged, encoding="utf-8", newline="")
    return 0


def validate_files(paths: Iterable[Path]) -> int:
    for path in paths:
        try:
            validate_permission_set(path.read_text(encoding="utf-8"), str(path))
        except PermissionSetError as error:
            print(f"al-permset validation failed for {path}: {error}", file=sys.stderr)
            return 1
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Merge or validate generated AL permission set files.")
    parser.add_argument("paths", nargs="*", help="Either base/ours/theirs for merge mode, or files after --validate")
    parser.add_argument("--validate", action="store_true", help="Validate one or more permission set files instead of merging")
    args = parser.parse_args(argv)

    if args.validate:
        if not args.paths:
            parser.error("--validate requires at least one file path")
        return validate_files(Path(path) for path in args.paths)

    if len(args.paths) != 3:
        parser.error("merge mode requires exactly three paths: BASE OURS THEIRS")
    base_path, ours_path, theirs_path = (Path(path) for path in args.paths)
    return merge_files(base_path, ours_path, theirs_path)


if __name__ == "__main__":
    sys.exit(main())
