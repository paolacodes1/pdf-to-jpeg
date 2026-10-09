#!/usr/bin/env python3
"""Extract PDF pages as JPEG images."""

import sys
from pathlib import Path

try:
    from pdf2image import convert_from_path
except ImportError:
    print("Missing required package. Install with:")
    print("  pip install pdf2image")
    print("\nYou also need poppler installed:")
    print("  brew install poppler")
    sys.exit(1)


def pdf_to_jpeg(pdf_path: str, output_dir: str = None, dpi: int = 200):
    """Convert each page of a PDF to a JPEG image.

    Args:
        pdf_path: Path to the PDF file
        output_dir: Directory to save images (defaults to same as PDF)
        dpi: Image resolution (default 200)
    """
    pdf_path = Path(pdf_path)

    if not pdf_path.exists():
        print(f"Error: File not found: {pdf_path}")
        sys.exit(1)

    if output_dir:
        output_path = Path(output_dir)
    else:
        output_path = pdf_path.parent

    output_path.mkdir(parents=True, exist_ok=True)

    print(f"Converting: {pdf_path.name}")

    images = convert_from_path(pdf_path, dpi=dpi)

    base_name = pdf_path.stem

    for i, image in enumerate(images, start=1):
        output_file = output_path / f"{base_name}_page_{i}.jpg"
        image.save(output_file, "JPEG", quality=95)
        print(f"  Saved: {output_file.name}")

    print(f"\nDone! Extracted {len(images)} page(s)")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python pdf_to_jpeg.py <pdf_file> [output_dir] [dpi]")
        print("\nExamples:")
        print("  python pdf_to_jpeg.py document.pdf")
        print("  python pdf_to_jpeg.py document.pdf ./output")
        print("  python pdf_to_jpeg.py document.pdf ./output 300")
        sys.exit(1)

    pdf_file = sys.argv[1]
    out_dir = sys.argv[2] if len(sys.argv) > 2 else None
    resolution = int(sys.argv[3]) if len(sys.argv) > 3 else 200

    pdf_to_jpeg(pdf_file, out_dir, resolution)
