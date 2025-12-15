#!/usr/bin/env python3
"""
Wayfire Cheatsheet ODT Generator
Creates a beautiful single-page landscape ODT document with Kartoza branding
"""

import zipfile
import os
import shutil
import sys
import argparse
from pathlib import Path

# Configuration
SCRIPT_DIR = Path(__file__).parent
CONFIG_DIR = SCRIPT_DIR.parent
RESOURCES_DIR = CONFIG_DIR / "resources"
OUTPUT_FILE = CONFIG_DIR / "docs" / "wayfire-cheatsheet.odt"
CHEATSHEET_MD = CONFIG_DIR / "docs" / "wayfire-keybinds-cheat-sheet.md"

# Kartoza brand colors
KARTOZA_BLUE = "#5B9BD5"
KARTOZA_ORANGE = "#E7B547"
KARTOZA_GRAY = "#888888"


def parse_markdown_cheatsheet():
    """Parse the markdown cheatsheet file and extract sections"""
    if not CHEATSHEET_MD.exists():
        print(f"Error: Cheatsheet file not found: {CHEATSHEET_MD}")
        sys.exit(1)

    sections = {}
    current_section = None
    current_keybinds = []

    with open(CHEATSHEET_MD, "r") as f:
        for line in f:
            line = line.strip()

            # Skip empty lines, the main title, and table headers
            if not line or line.startswith("# Wayfire") or line.startswith("|------"):
                continue

            # Section headers (## with emoji)
            if line.startswith("## "):
                if current_section and current_keybinds:
                    sections[current_section] = current_keybinds
                current_section = line[3:]  # Remove "## "
                current_keybinds = []
                continue

            # Skip table header row
            if line.startswith("| Keybind | Action |"):
                continue

            # Table rows with keybinds
            if line.startswith("| `") and line.endswith(" |"):
                parts = [
                    part.strip() for part in line.split("|")[1:-1]
                ]  # Remove empty first/last
                if len(parts) >= 2:
                    keybind = parts[0].strip("`")
                    action = parts[1]
                    if keybind and action:
                        current_keybinds.append((keybind, action))

    # Add the last section
    if current_section and current_keybinds:
        sections[current_section] = current_keybinds

    return sections


def create_odt_structure():
    """Create the ODT directory structure"""
    temp_dir = Path("/tmp/wayfire_odt")
    if temp_dir.exists():
        shutil.rmtree(temp_dir)

    temp_dir.mkdir()
    (temp_dir / "META-INF").mkdir()
    (temp_dir / "Pictures").mkdir()

    # Copy Kartoza images
    logo_src = RESOURCES_DIR / "kartoza-logo.png"
    bg_src = RESOURCES_DIR / "KartozaBackground.png"

    if logo_src.exists():
        shutil.copy(logo_src, temp_dir / "Pictures/")
    if bg_src.exists():
        shutil.copy(bg_src, temp_dir / "Pictures/")

    return temp_dir


def create_manifest(temp_dir):
    """Create META-INF/manifest.xml"""
    manifest_content = """<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">
 <manifest:file-entry manifest:full-path="/" manifest:version="1.2" manifest:media-type="application/vnd.oasis.opendocument.text"/>
 <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="Pictures/kartoza-logo.png" manifest:media-type="image/png"/>
 <manifest:file-entry manifest:full-path="Pictures/KartozaBackground.png" manifest:media-type="image/png"/>
</manifest:manifest>"""

    with open(temp_dir / "META-INF/manifest.xml", "w") as f:
        f.write(manifest_content)


def create_meta(temp_dir):
    """Create meta.xml"""
    meta_content = """<?xml version="1.0" encoding="UTF-8"?>
<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0">
 <office:meta>
  <meta:generator>Kartoza Wayfire Cheatsheet Generator</meta:generator>
  <meta:creator>Kartoza</meta:creator>
  <meta:creation-date>2024-01-01T00:00:00</meta:creation-date>
  <meta:subject>Wayfire Window Manager Keyboard Shortcuts</meta:subject>
  <meta:description>Quick reference guide for Wayfire keybinds</meta:description>
 </office:meta>
</office:document-meta>"""

    with open(temp_dir / "meta.xml", "w") as f:
        f.write(meta_content)


def create_styles(temp_dir):
    """Create styles.xml with landscape orientation and Kartoza styling"""
    styles_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<office:document-styles xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0">
 <office:font-face-decls>
  <style:font-face style:name="Nunito" svg:font-family="Nunito, 'Liberation Sans', sans-serif" style:font-family-generic="swiss" style:font-pitch="variable"/>
  <style:font-face style:name="Nunito1" svg:font-family="Nunito, 'Liberation Sans', sans-serif" style:font-family-generic="swiss" style:font-pitch="variable"/>
  <style:font-face style:name="Liberation Sans" svg:font-family="'Liberation Sans'" style:font-family-generic="swiss"/>
  <style:font-face style:name="Liberation Mono" svg:font-family="'Liberation Mono'" style:font-family-generic="modern"/>
 </office:font-face-decls>
 <office:styles>
  <style:default-style style:family="paragraph">
   <style:paragraph-properties fo:text-align="left"/>
   <style:text-properties style:font-name="Nunito" fo:font-size="10pt"/>
  </style:default-style>
  <style:style style:name="Standard" style:family="paragraph" style:class="text"/>
  <style:style style:name="Header" style:family="paragraph" style:parent-style-name="Standard">
   <style:paragraph-properties fo:margin-left="1.3in"/>
   <style:text-properties style:font-name="Nunito" fo:font-size="22pt" fo:font-weight="bold" fo:color="{KARTOZA_BLUE}"/>
  </style:style>
  <style:style style:name="SectionTitle" style:family="paragraph" style:parent-style-name="Standard">
   <style:paragraph-properties fo:margin-bottom="0.1in"/>
   <style:text-properties style:font-name="Nunito" fo:font-size="11pt" fo:font-weight="bold" fo:color="#333333"/>
  </style:style>
  <style:style style:name="Keybind" style:family="character">
   <style:text-properties style:font-name="Liberation Mono" fo:font-weight="bold" fo:background-color="#E8E8E8" fo:color="#2D2D2D"/>
  </style:style>
  <style:style style:name="Footer" style:family="paragraph" style:parent-style-name="Standard">
   <style:paragraph-properties fo:text-align="center" fo:margin-top="0.2in"/>
   <style:text-properties style:font-name="Nunito" fo:font-size="9pt" fo:color="{KARTOZA_GRAY}"/>
  </style:style>
 </office:styles>
 <office:automatic-styles>
  <style:page-layout style:name="pm1">
   <style:page-layout-properties fo:page-width="11in" fo:page-height="8.5in" style:print-orientation="landscape" fo:margin-top="0.4in" fo:margin-bottom="0.4in" fo:margin-left="0.5in" fo:margin-right="0.5in"/>
  </style:page-layout>
 </office:automatic-styles>
 <office:master-styles>
  <style:master-page style:name="Standard" style:page-layout-name="pm1"/>
 </office:master-styles>
</office:document-styles>"""

    with open(temp_dir / "styles.xml", "w") as f:
        f.write(styles_content)


def create_content(temp_dir, sections):
    """Create content.xml with the cheatsheet data"""

    # Create table cells for each section
    cells_xml = []
    section_count = 0

    # Organize sections into 3 columns
    sections_list = list(sections.items())
    rows_needed = (len(sections_list) + 2) // 3  # Round up division

    for row in range(rows_needed):
        row_cells = []
        for col in range(3):
            section_idx = row * 3 + col
            if section_idx < len(sections_list):
                section_name, keybinds = sections_list[section_idx]

                # Build cell content (escape section name too)
                section_name_escaped = (
                    section_name.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace('"', "&quot;")
                    .replace("'", "&apos;")
                )
                cell_content = f'<text:p text:style-name="SectionTitle">{section_name_escaped}</text:p>\n'

                # Add keybinds (limit to fit in cell)
                for keybind, action in keybinds[:8]:  # Limit to 8 items per section
                    # Escape XML characters properly
                    keybind = (
                        keybind.replace("&", "&amp;")
                        .replace("<", "&lt;")
                        .replace(">", "&gt;")
                        .replace('"', "&quot;")
                        .replace("'", "&apos;")
                    )
                    action = (
                        action.replace("&", "&amp;")
                        .replace("<", "&lt;")
                        .replace(">", "&gt;")
                        .replace('"', "&quot;")
                        .replace("'", "&apos;")
                    )
                    cell_content += f'<text:p text:style-name="Standard"><text:span text:style-name="Keybind">{keybind}</text:span> - {action}</text:p>\n'

                row_cells.append(
                    f'<table:table-cell table:style-name="Table1_Cell">\n{cell_content}</table:table-cell>'
                )
            else:
                row_cells.append(
                    '<table:table-cell table:style-name="Table1_Cell"><text:p text:style-name="Standard"/></table:table-cell>'
                )

        cells_xml.append(
            f"<table:table-row>\n{chr(10).join(row_cells)}\n</table:table-row>"
        )

    table_rows = "\n".join(cells_xml)

    content_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0">
 <office:font-face-decls>
  <style:font-face style:name="Nunito" svg:font-family="Nunito, 'Liberation Sans', sans-serif" style:font-family-generic="swiss" style:font-pitch="variable"/>
  <style:font-face style:name="Liberation Sans" svg:font-family="'Liberation Sans'" style:font-family-generic="swiss"/>
  <style:font-face style:name="Liberation Mono" svg:font-family="'Liberation Mono'" style:font-family-generic="modern"/>
 </office:font-face-decls>
 <office:automatic-styles>
  <style:style style:name="Kartoza_Background" style:family="graphic" style:parent-style-name="Graphics">
   <style:graphic-properties style:run-through="background" style:wrap="run-through" style:number-wrapped-paragraphs="no-limit" style:wrap-contour="false" style:vertical-pos="from-top" style:vertical-rel="page" style:horizontal-pos="from-left" style:horizontal-rel="page"/>
  </style:style>
  <style:style style:name="Content_Overlay" style:family="graphic" style:parent-style-name="Graphics">
   <style:graphic-properties style:run-through="background" style:wrap="run-through" style:number-wrapped-paragraphs="no-limit" style:wrap-contour="false" style:vertical-pos="from-top" style:vertical-rel="page" style:horizontal-pos="from-left" style:horizontal-rel="page" draw:fill="solid" draw:fill-color="#ffffff" draw:opacity="75%" style:shadow="none"/>
  </style:style>
  <style:style style:name="Table1" style:family="table">
   <style:table-properties style:width="10in" table:align="center"/>
  </style:style>
  <style:style style:name="Table1.A" style:family="table-column">
   <style:table-column-properties style:column-width="3.3in"/>
  </style:style>
  <style:style style:name="Table1_Cell" style:family="table-cell">
   <style:table-cell-properties fo:padding="0.15in" fo:border="none" style:vertical-align="top"/>
  </style:style>
 </office:automatic-styles>
 <office:body>
  <office:text>
   <text:p text:style-name="Standard">
    <draw:frame draw:style-name="Kartoza_Background" draw:name="Background" text:anchor-type="page" svg:x="0in" svg:y="0in" svg:width="11in" svg:height="8.5in" draw:z-index="0">
     <draw:image xlink:href="Pictures/KartozaBackground.png" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad"/>
    </draw:frame>
   </text:p>
   
   <text:p text:style-name="Standard">
    <draw:frame draw:style-name="Content_Overlay" draw:name="ContentOverlay" text:anchor-type="page" svg:x="0.3in" svg:y="0.3in" svg:width="10.4in" svg:height="7.9in" draw:z-index="1">
     <draw:text-box/>
    </draw:frame>
   </text:p>
   
   <text:p text:style-name="Standard">
    <draw:frame draw:name="Logo" text:anchor-type="page" svg:x="0.5in" svg:y="0.1in" svg:width="0.7in" svg:height="0.7in" draw:z-index="2">
     <draw:image xlink:href="Pictures/kartoza-logo.png" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad"/>
    </draw:frame>
   </text:p>
   <text:p text:style-name="Header">Wayfire Keybinds Cheat Sheet</text:p>
   
   <text:p text:style-name="Standard"/>
   
   <table:table table:name="CheatSheetTable" table:style-name="Table1">
    <table:table-column table:style-name="Table1.A" table:number-columns-repeated="3"/>
    {table_rows}
   </table:table>
   
   <text:p text:style-name="Footer">
    <text:span style:font-weight="bold">Kartoza</text:span> • Wayfire Window Manager • Open Source GIS Solutions
   </text:p>
   
  </office:text>
 </office:body>
</office:document-content>"""

    with open(temp_dir / "content.xml", "w") as f:
        f.write(content_xml)


def create_odt_archive(temp_dir):
    """Create the final ODT file as a ZIP archive"""
    if OUTPUT_FILE.exists():
        OUTPUT_FILE.unlink()

    with zipfile.ZipFile(OUTPUT_FILE, "w", zipfile.ZIP_DEFLATED) as zipf:
        # Add mimetype first (uncompressed)
        zipf.writestr(
            "mimetype", "application/vnd.oasis.opendocument.text", zipfile.ZIP_STORED
        )

        # Add all other files
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                file_path = Path(root) / file
                arc_name = file_path.relative_to(temp_dir)
                zipf.write(file_path, arc_name)


def convert_to_pdf_and_png(formats):
    """Convert the ODT to PDF and PNG using LibreOffice"""
    if not OUTPUT_FILE.exists():
        print("❌ ODT file not found, cannot convert")
        return

    pdf_output = CONFIG_DIR / "wayfire-cheatsheet.pdf"

    # Convert ODT to PDF (needed for PNG conversion too)
    if "pdf" in formats or "png" in formats:
        print("📄 Converting to PDF...")
        # Use specific PDF export options for better font handling
        pdf_filter_options = "ExportBookmarks:bool=false;EmbedStandardFonts:bool=true;EmbedFonts:bool=true"
        result = os.system(
            f'libreoffice --headless --convert-to pdf:"writer_pdf_Export:{pdf_filter_options}" --outdir "{CONFIG_DIR}" "{OUTPUT_FILE}"'
        )

        if result == 0 and pdf_output.exists():
            if "pdf" in formats:
                print(f"✅ PDF created: {pdf_output}")
        else:
            print("❌ PDF conversion failed")
            return

    # Convert PDF to PNG
    if "png" in formats and pdf_output.exists():
        print("🖼️  Converting to PNG...")
        png_output = CONFIG_DIR / "wayfire-cheatsheet.png"

        # Try ImageMagick first
        magick_result = os.system(
            f'convert -density 300 "{pdf_output}" -quality 90 "{png_output}" 2>/dev/null'
        )

        if magick_result == 0 and png_output.exists():
            print(f"✅ PNG created: {png_output}")
        else:
            # Try pdftoppm as fallback
            print("   Trying alternative conversion method...")
            ppm_result = os.system(
                f'pdftoppm -png -r 300 "{pdf_output}" "{CONFIG_DIR}/wayfire-cheatsheet" 2>/dev/null'
            )

            # pdftoppm creates files with page numbers, rename the first one
            ppm_file = CONFIG_DIR / "wayfire-cheatsheet-1.png"
            if ppm_file.exists():
                ppm_file.rename(png_output)
                print(f"✅ PNG created: {png_output}")
            else:
                print("⚠️  PNG conversion failed - install ImageMagick or poppler-utils")


def main():
    """Main function to generate the ODT cheatsheet"""
    parser = argparse.ArgumentParser(
        description="Generate Wayfire cheatsheet in various formats"
    )
    parser.add_argument(
        "--formats",
        "-f",
        nargs="+",
        choices=["odt", "pdf", "png", "all"],
        default=["all"],
        help="Output formats to generate (default: all)",
    )

    args = parser.parse_args()

    # Normalize format list
    if "all" in args.formats:
        formats = ["odt", "pdf", "png"]
    else:
        formats = args.formats

    print("🔥 Generating Wayfire Cheatsheet...")
    print(f"📋 Output formats: {', '.join(formats)}")

    # Always generate ODT first (needed for conversions)
    if "odt" in formats or "pdf" in formats or "png" in formats:
        # Parse the markdown cheatsheet
        print("📖 Parsing cheatsheet markdown...")
        sections = parse_markdown_cheatsheet()
        print(f"   Found {len(sections)} sections with shortcuts")

        # Create ODT structure
        print("📁 Creating ODT structure...")
        temp_dir = create_odt_structure()

        # Create ODT components
        print("⚙️  Creating ODT components...")
        create_manifest(temp_dir)
        create_meta(temp_dir)
        create_styles(temp_dir)
        create_content(temp_dir, sections)

        # Create final ODT file
        print("📦 Creating ODT archive...")
        create_odt_archive(temp_dir)

        # Clean up
        shutil.rmtree(temp_dir)

        if "odt" in formats:
            print(f"✅ ODT created: {OUTPUT_FILE}")

    # Convert to other formats
    if "pdf" in formats or "png" in formats:
        convert_to_pdf_and_png(formats)

    print("🎉 Generation complete!")


if __name__ == "__main__":
    main()

