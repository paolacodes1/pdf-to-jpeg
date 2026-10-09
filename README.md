# PDF to JPEG

A small Mac app that turns every page of a PDF into a JPEG image.

Double-click **PDF to JPEG.app**, pick a PDF, then pick a folder to save the images in (cancel to save next to the PDF). Pages are saved as `<name>_page_1.jpg`, `<name>_page_2.jpg`, … at 200 DPI.

## Requirements

```bash
brew install poppler
```

On first launch the app creates its own Python environment in `~/Library/Application Support/PDF to JPEG/` and installs `pdf2image` there, so nothing is installed system-wide.

## Command line

The script lives inside the app bundle and can also be run directly:

```bash
python3 "PDF to JPEG.app/Contents/Resources/pdf_to_jpeg.py" document.pdf [output_dir] [dpi]
```
