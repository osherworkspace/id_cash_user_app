#!/usr/bin/env python3
"""Install exact ID-CASH supplied PNGs from the shared onboarding ZIP.

Usage: python3 scripts/install_brand_assets.py --app user
       python3 scripts/install_brand_assets.py --app agent
       python3 scripts/install_brand_assets.py --app user --verify-only
"""
import argparse
import hashlib
from pathlib import Path
from zipfile import ZipFile

HASHES = {
    "brand_logo.png": "0aa3ec3d872d62013b9cb8536658aa38f475cc6f700212f0ff66ace44762a376",
    "onboarding_face.png": "e5283b7d400a99cfaf98c96de881425b3ba7daec33c733bea5fcad7b8650b2d4",
    "onboarding_idc.png": "fe256cb27d818d56b1551f8177b850504f906efb3bb27ec5b6fa1e8f9fd93bc7",
}
FILES = {
    "user": {
        **HASHES,
        "app_icon.png": "9d027bc6bf881eb4346a13f6e55dde9212727fe0d8ea2ecee80ce9f275350614",
        "onboarding_send.png": "0c85f3ecdfcb1d71c2681e012753b58b8a633d06ad9da2ba7f9be6de577ce1b2",
        "onboarding_services.png": "4c5332e380cfbefd4fef40c91535afc5d78a6826fa0374bd8aa8685982ccf6f3",
    },
    "agent": {
        **HASHES,
        "app_icon.png": "a7ad034535267812fc7c8be276e6b0859551244368bcb51c7ccf70f86c253ee9",
        "onboarding_agent.png": "73cfc335dc57b59c9652c28d523eb202dfb3dcc1b5457a314e0588abb9d9f181",
    },
}

def verify(file: str, data: bytes, expected_hash: str) -> None:
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError(f"{file}: not a PNG")
    if hashlib.sha256(data).hexdigest() != expected_hash:
        raise ValueError(f"{file}: not the original supplied artwork")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--app", required=True, choices=("user", "agent"))
    parser.add_argument("--archive", default="idcash_onboarding_assets.zip")
    parser.add_argument("--verify-only", action="store_true")
    args = parser.parse_args()
    dest = Path("assets/images")
    if args.verify_only:
        for name, sha in FILES[args.app].items():
            file = dest / name
            verify(str(file), file.read_bytes(), sha)
            print(f"Verified original {file}")
        return
    archive = Path(args.archive)
    if not archive.is_file():
        raise FileNotFoundError(
            f"{archive} was not found. Upload the supplied ID-CASH ZIP "
            "to this branch root; no placeholder images are accepted."
        )
    with ZipFile(archive) as z:
        for name, sha in FILES[args.app].items():
            source = f"idcash_onboarding_assets/{args.app}/assets/images/{name}"
            data = z.read(source)
            verify(source, data, sha)
            dest.mkdir(parents=True, exist_ok=True)
            (dest / name).write_bytes(data)
            print(f"Installed exact original {name} ({len(data):,} bytes)")

if __name__ == "__main__":
    main()
