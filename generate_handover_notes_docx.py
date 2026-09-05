import os
import sys
import io
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn
from PIL import Image as PILImage

# -----------------------------------------------------------------------------
# XML HELPER FUNCTIONS FOR PROFESSIONAL DOCX STYLING
# -----------------------------------------------------------------------------

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=80, bottom=80, left=100, right=100):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(
        f'<w:tcMar {nsdecls("w")}>'
        f'<w:top w:w="{top}" w:type="dxa"/>'
        f'<w:bottom w:w="{bottom}" w:type="dxa"/>'
        f'<w:left w:w="{left}" w:type="dxa"/>'
        f'<w:right w:w="{right}" w:type="dxa"/>'
        f'</w:tcMar>'
    )
    tcPr.append(tcMar)

def set_table_borders(table, color="CBD5E1", sz="4", val="single"):
    tblPr = table._tbl.tblPr
    borders = parse_xml(f'''
        <w:tblBorders {nsdecls("w")}>
            <w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:left w:val="none"/>
            <w:right w:val="none"/>
            <w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:insideV w:val="none"/>
        </w:tblBorders>
    ''')
    tblPr.append(borders)

def set_card_borders(table, color="D4AF37", sz="6", val="single"):
    tblPr = table._tbl.tblPr
    borders = parse_xml(f'''
        <w:tblBorders {nsdecls("w")}>
            <w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:left w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:right w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:insideH w:val="none"/>
            <w:insideV w:val="none"/>
        </w:tblBorders>
    ''')
    tblPr.append(borders)

def set_callout_borders(table, color="D4AF37", sz="16", val="single"):
    tblPr = table._tbl.tblPr
    borders = parse_xml(f'''
        <w:tblBorders {nsdecls("w")}>
            <w:top w:val="none"/>
            <w:bottom w:val="none"/>
            <w:left w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:right w:val="none"/>
            <w:insideH w:val="none"/>
            <w:insideV w:val="none"/>
        </w:tblBorders>
    ''')
    tblPr.append(borders)

def add_image_to_paragraph(p, img_path, width_inches=2.9):
    if not os.path.exists(img_path):
        r_err = p.add_run(f"[Visual Asset: {os.path.basename(img_path)}]")
        r_err.font.color.rgb = RGBColor(220, 38, 38)
        r_err.font.size = Pt(8.5)
        return
    try:
        with PILImage.open(img_path) as img:
            buf = io.BytesIO()
            img.convert('RGB').save(buf, format='PNG')
            buf.seek(0)
            p.add_run().add_picture(buf, width=Inches(width_inches))
    except Exception as e:
        p.add_run(f"[Image Error: {e}]")

# -----------------------------------------------------------------------------
# MAIN BUILDER FUNCTION
# -----------------------------------------------------------------------------

def build_handover_document():
    docx_filename = "ABP_Development_Handover_Review_and_Client_Alignment_Notes.docx"
    doc = Document()

    # Standard Page Margins: 0.75 in
    for section in doc.sections:
        section.top_margin = Inches(0.75)
        section.bottom_margin = Inches(0.75)
        section.left_margin = Inches(0.75)
        section.right_margin = Inches(0.75)

    # Color Palette Definitions
    C_NAVY_DARK = RGBColor(10, 25, 47)      # #0A192F - Luxury Dark Navy
    C_NAVY_LIGHT = RGBColor(30, 58, 138)    # #1E3A8A - Royal Blue Accent
    C_GOLD_DARK = RGBColor(184, 151, 46)    # #B8972E - Deep Gold
    C_GOLD_BRIGHT = RGBColor(212, 175, 55)  # #D4AF37 - Luxury Gold
    C_TEXT = RGBColor(51, 65, 85)           # #334155 - Slate Body Text
    C_GREEN = RGBColor(5, 150, 105)         # #059669 - Forest Green
    C_AMBER = RGBColor(217, 119, 6)         # #D97706 - Amber Warning
    C_RED = RGBColor(220, 38, 38)           # #DC2626 - Alert Red
    C_GRAY = RGBColor(100, 116, 139)        # #64748B - Subtitle Slate
    C_CARD_BG = "F8FAFC"
    V_FOLDER = "visual_assets"

    # Typography Helpers
    def add_h1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(16)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Calibri'
        run.font.size = Pt(13.5)
        run.font.bold = True
        run.font.color.rgb = C_NAVY_DARK
        return p

    def add_h2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Calibri'
        run.font.size = Pt(11.5)
        run.font.bold = True
        run.font.color.rgb = C_NAVY_LIGHT
        return p

    def add_h3(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(8)
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Calibri'
        run.font.size = Pt(10)
        run.font.bold = True
        run.font.color.rgb = C_GOLD_DARK
        return p

    def add_body(text, bold_prefix=None, color=C_TEXT):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_pre = p.add_run(bold_prefix)
            r_pre.font.name = 'Calibri'
            r_pre.font.size = Pt(9.5)
            r_pre.font.bold = True
            r_pre.font.color.rgb = C_NAVY_DARK
        r_text = p.add_run(text)
        r_text.font.name = 'Calibri'
        r_text.font.size = Pt(9.5)
        r_text.font.color.rgb = color
        return p

    def add_bullet(bold_label, desc, status_text=None, is_pending=False, is_done=True):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_before = Pt(1)
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.line_spacing = 1.15
        
        r_lbl = p.add_run(bold_label)
        r_lbl.font.bold = True
        r_lbl.font.size = Pt(9.5)
        r_lbl.font.color.rgb = C_NAVY_DARK
        
        r_desc = p.add_run(f": {desc} ")
        r_desc.font.size = Pt(9.5)
        r_desc.font.color.rgb = C_TEXT
        
        if status_text:
            r_stat = p.add_run(f"[{status_text}]")
            r_stat.font.bold = True
            r_stat.font.size = Pt(9)
            if is_pending:
                r_stat.font.color.rgb = C_AMBER
            elif is_done:
                r_stat.font.color.rgb = C_GREEN
            else:
                r_stat.font.color.rgb = C_RED
        return p

    def add_callout(text, bold_title="CRITICAL STRATEGIC NOTE:"):
        table = doc.add_table(rows=1, cols=1)
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        table.autofit = False
        table.columns[0].width = Inches(7.0)
        cell = table.cell(0, 0)
        set_cell_background(cell, "FEFCE8") # Light Amber background
        set_cell_margins(cell, top=100, bottom=100, left=140, right=140)
        set_callout_borders(table, color="D4AF37", sz="16")
        
        p = cell.paragraphs[0]
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.line_spacing = 1.15
        r_t = p.add_run(f"{bold_title} ")
        r_t.font.name = 'Calibri'
        r_t.font.bold = True
        r_t.font.size = Pt(9.5)
        r_t.font.color.rgb = C_NAVY_DARK
        
        r_m = p.add_run(text)
        r_m.font.name = 'Calibri'
        r_m.font.size = Pt(9)
        r_m.font.color.rgb = C_TEXT
        
        doc.add_paragraph().paragraph_format.space_after = Pt(4)

    def render_visual_card_cell(cell, item, width_in=3.0):
        # item: (fname, title, subtitle, badge)
        fname, title, subtitle, badge = item
        fpath = os.path.join(V_FOLDER, fname)
        set_cell_background(cell, C_CARD_BG)
        set_cell_margins(cell, top=60, bottom=60, left=70, right=70)
        
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(1)
        
        r_title = p.add_run(f"📸 {title} ")
        r_title.font.name = 'Calibri'
        r_title.font.bold = True
        r_title.font.size = Pt(8.5)
        r_title.font.color.rgb = C_NAVY_DARK
        
        r_badge = p.add_run(f"[{badge}]")
        r_badge.font.name = 'Calibri'
        r_badge.font.bold = True
        r_badge.font.size = Pt(8)
        r_badge.font.color.rgb = C_GREEN
        
        p_sub = cell.add_paragraph()
        p_sub.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p_sub.paragraph_format.space_before = Pt(0)
        p_sub.paragraph_format.space_after = Pt(3)
        r_sub = p_sub.add_run(subtitle)
        r_sub.font.name = 'Calibri'
        r_sub.font.size = Pt(7.5)
        r_sub.font.color.rgb = C_GRAY
        
        p_img = cell.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(2)
        p_img.paragraph_format.space_after = Pt(2)
        add_image_to_paragraph(p_img, fpath, width_inches=width_in)

    def add_visual_proof_pair(item1, item2):
        card_table = doc.add_table(rows=1, cols=2)
        card_table.alignment = WD_TABLE_ALIGNMENT.CENTER
        card_table.autofit = False
        card_table.columns[0].width = Inches(3.45)
        card_table.columns[1].width = Inches(3.45)
        
        cells = card_table.rows[0].cells
        render_visual_card_cell(cells[0], item1, width_in=3.0)
        render_visual_card_cell(cells[1], item2, width_in=3.0)
        
        set_card_borders(card_table, color="D4AF37", sz="5")
        doc.add_paragraph().paragraph_format.space_after = Pt(4)

    # -------------------------------------------------------------------------
    # HEADER BANNER TABLE
    # -------------------------------------------------------------------------
    header_table = doc.add_table(rows=2, cols=2)
    header_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    header_table.autofit = False
    header_table.columns[0].width = Inches(4.8)
    header_table.columns[1].width = Inches(2.2)

    cell_00 = header_table.cell(0, 0)
    p_title = cell_00.paragraphs[0]
    p_title.paragraph_format.space_after = Pt(2)
    r = p_title.add_run("ANIMAL BIRTHDAY PREDICTOR (ABP)™")
    r.font.name = 'Calibri'
    r.font.size = Pt(16.5)
    r.font.bold = True
    r.font.color.rgb = C_NAVY_DARK

    cell_01 = header_table.cell(0, 1)
    p_meta = cell_01.paragraphs[0]
    p_meta.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p_meta.paragraph_format.space_after = Pt(2)
    r = p_meta.add_run("DOCUMENT CLASSIFICATION\n")
    r.font.bold = True
    r.font.size = Pt(8.5)
    r.font.color.rgb = C_NAVY_DARK
    r2 = p_meta.add_run("Client Handover & Alignment Notes")
    r2.font.size = Pt(8.5)
    r2.font.color.rgb = C_GRAY

    cell_10 = header_table.cell(1, 0)
    p_sub = cell_10.paragraphs[0]
    p_sub.paragraph_format.space_after = Pt(4)
    r = p_sub.add_run("Comprehensive Handover Review, Visual Proofs, Architecture Alignments & Phased Implementation Timelines")
    r.font.name = 'Calibri'
    r.font.size = Pt(9.5)
    r.font.color.rgb = C_GOLD_DARK

    cell_11 = header_table.cell(1, 1)
    p_status = cell_11.paragraphs[0]
    p_status.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p_status.paragraph_format.space_after = Pt(4)
    r = p_status.add_run("PREPARED FOR: ")
    r.font.bold = True
    r.font.size = Pt(8.5)
    r.font.color.rgb = C_NAVY_DARK
    r_client = p_status.add_run("Tracey (Client)\n")
    r_client.font.bold = True
    r_client.font.size = Pt(8.5)
    r_client.font.color.rgb = C_GOLD_DARK
    r_date = p_status.add_run("Date: September 2026 | Version: 2.1")
    r_date.font.size = Pt(8)
    r_date.font.color.rgb = C_GRAY

    set_cell_background(cell_00, "F8FAFC")
    set_cell_background(cell_01, "F8FAFC")
    set_cell_background(cell_10, "F8FAFC")
    set_cell_background(cell_11, "F8FAFC")
    for row in header_table.rows:
        for cell in row.cells:
            set_cell_margins(cell, top=80, bottom=80, left=100, right=100)

    doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # -------------------------------------------------------------------------
    # SECTION 1: EXECUTIVE INTRODUCTION & DESIGN CONSISTENCY COMMITMENT
    # -------------------------------------------------------------------------
    add_h1("1. Executive Overview & Design Consistency Commitment")
    add_body(
        "Following our comprehensive project meeting and the 30-point development handover brief, this document provides "
        "a complete, transparent alignment between the client's vision and the development team's technical implementation. "
        "The overarching goal is to build an enterprise-grade, multi-species animal management platform that effortlessly scales "
        "from individual hobbyist owners with 1–2 animals to large thoroughbred studs and commercial operations with 200+ animals."
    )
    
    add_h2("Unified Design System Across All Animal Species (Horse, Dog, Cat & Beyond)")
    add_body(
        "The client rightfully stressed that consistency is the absolute #1 design requirement. A user navigating through the "
        "Equine / Horse section, Dog section, Cat section, or any future species must instantly recognize that they are using one cohesive application. "
        "We have codified this through our centralized Flutter design tokens and UI architecture:"
    )
    add_bullet("Color Palette", "Shared luxury dark theme (#0A192F / #121212) accented with polished gold (#D4AF37) and emerald status green across all modules.", "LOCKED & VERIFIED ✅")
    add_bullet("Typography & Hierarchy", "Consistent font weights, scalable typography, uniform letter spacing, and standard card padding.", "LOCKED & VERIFIED ✅")
    add_bullet("Component Standardization", "Identical button styles, date pickers, input fields, camera/gallery upload slots, and confirmation dialogs.", "LOCKED & VERIFIED ✅")
    add_bullet("Species Scoping", "While visual styling is identical, the underlying clinical fields, gestation algorithms, and terminology remain strictly species-specific.", "LOCKED & VERIFIED ✅")
    add_bullet("Thunkable Work Review", "The team has thoroughly inspected the client's existing Thunkable layouts, content, and guidelines, using them as the primary visual reference while elevating the codebase to professional Flutter architecture.", "THUNKABLE REVIEWED ✅")

    add_visual_proof_pair(
        ("WhatsApp Image 2026-08-30 at 2.10.25 AM (1).jpeg", "Dashboard Hub (Unified Visual Identity)", "Gold-accented dark theme (#0A192F), unified stats, active tier badge & quick CTAs", "CORE DESIGN SYSTEM"),
        ("WhatsApp Image 2026-08-30 at 2.10.12 AM.jpeg", "Multi-Species Hub (Universal Architecture)", "Seamless species switching between Equine, Canine, Feline & Livestock with shared UI tokens", "MULTI-SPECIES UI")
    )

    # -------------------------------------------------------------------------
    # SECTION 2: EQUINE & FOAL WORKFLOW STATUS – WHAT IS ALREADY 100% DONE
    # -------------------------------------------------------------------------
    add_h1("2. Equine & Foal Workflow Status: What Is Already Completed & Tested")
    add_body(
        "In response to Meeting Points 8, 9, 10, 25, and 26, the development team is pleased to confirm that the entire Horse/Equine "
        "journey—specifically including the complete chronological Foal Suite, Dam/Sire auto-population, newborn photography, and IgG antibody testing—"
        "is ALREADY 100% BUILT, FULLY FUNCTIONAL, AND TESTED in the codebase. Below is the exact chronological breakdown with visual proof:"
    )

    add_callout(
        "TWO IMMEDIATE CLIENT UI/UX DECISIONS REQUIRED:\n\n"
        "1. WHERE SHOULD THE FOAL DUE DATE BE DISPLAYED? The app calculates the exact 340-day due date, scan schedule, and viable window (320-365d). "
        "Tracey must confirm her preferred primary UI placement: (A) Top of the Mare's Profile Card, (B) Dedicated Gestation / Pregnancy Countdown Card, "
        "(C) Main Dashboard Home Screen Widget, or (D) Stud Foaling Diary list view, and whether to display an active 'Days Remaining' countdown pill.\n\n"
        "2. WHERE & HOW SHOULD THE OFFICIAL CERTIFICATE OPTION BE SHOWN? The app generates 3 official vector PDF certificates (Foal Pedigree, "
        "45-Day Pregnancy Scan, Stud Foaling Diary). Tracey must confirm where the button should live: (Option 1) Prominent golden button inside each Foal's "
        "Profile and Mare's Pregnancy card; (Option 2) Centralized 'Certificates Vault' tab in the main navigation; or (Option 3) Inside the Foal Buyer "
        "Management workflow for sales handover.\n\n"
        "Detailed screenshots of current live locations and proposed options are illustrated directly below in Subsections 2.1 and 2.2.",
        bold_title="CRITICAL CLIENT UI/UX DECISION REQUIRED (DUE DATE & CERTIFICATES):"
    )

    add_h2("Strict Chronological Lifecycle Implementation")
    add_body(
        "To address the client's concern regarding mixed-up content, the application enforces a strict, logical chronological workflow:"
    )
    add_bullet("Step 1: Mare & Dam Registration", "Broodmare identity registration with microchip, breed, color, and 3-angle physical markings (Head/Face, Left Side, Right Side).", "COMPLETED ✅")
    add_bullet("Step 2: Breeding Service & Stallion Selection", "Covers date, Stallion / Covering Sire designation, and breeding method (Natural, Chilled, Frozen, ET, ICSI).", "COMPLETED ✅")
    add_bullet("Step 3: Embryo Transfer Carrier Mare", "Surrogate recipient mare tracking separate from the genetic dam, retaining complete biological lineage.", "COMPLETED ✅")
    add_bullet("Step 4: Gestation Engine & Due Date Calculation", "Automated 340-day calculation, viable delivery window (320–365 days), and live days-remaining countdown.", "COMPLETED ✅")
    add_bullet("Step 5: Three Pregnancy Scans & Twin Alert", "Scan 1 (Day 14-16), Scan 2 (Day 28-30), Scan 3 (Day 45-60) with automated high-priority Twin Warning banner.", "COMPLETED ✅")
    add_bullet("Step 6: Arrival Celebration & Congratulations Screen", "Interactive particle celebration with the clinical '1-2-3 Foaling Rule' veterinary checklist (Hour 1: Stand, Hour 2: Nurse Colostrum, Hour 3: Placenta expelled).", "COMPLETED ✅")
    add_bullet("Step 7: Newborn Foal Registration Page", "Direct transition from congratulations to newborn registration: DOB, sex (Filly/Colt), birth weight, delivery notes, and placenta status.", "COMPLETED ✅")
    add_bullet("Step 8: Automated Dam & Sire Lineage Carryover", "The Foal record automatically populates the Dam (Mother) and Sire / Stallion (Father) directly from the pregnancy record—zero redundant data entry.", "COMPLETED ✅")
    add_bullet("Step 9: Foal Photograph Capture", "High-resolution camera photo capture in the foaling barn or gallery upload, synced directly to secure cloud storage.", "COMPLETED ✅")
    add_bullet("Step 10: IgG Antibody Test Record (mg/dL)", "Dedicated clinical testing field to log Foal Immunoglobulin G (IgG) antibody levels (mg/dL) verifying adequate colostral transfer.", "COMPLETED ✅")
    add_bullet("Step 11: Foal Lifecycle Tracking & Buyer Linking", "Status tracking (Active, Sold, Gelded, Deceased), buyer contact linking, sale price, microchip transfer, and PDF Pedigree Certificate generation.", "COMPLETED ✅")

    # Visual proof cards for Foal workflow
    add_visual_proof_pair(
        ("WhatsApp Image 2026-08-30 at 2.10.12 AM (1).jpeg", "Birth Celebration & 1-2-3 Foaling Rule", "Glowing ABP golden crest, congratulations banner & interactive 1-2-3 clinical checklist", "CELEBRATION SCREEN"),
        ("WhatsApp Image 2026-08-30 at 2.10.23 AM (2).jpeg", "New Foal Registration & Birth Log", "Newborn form: DOB, sex (Filly/Colt), linked Dam/Mother, weight & foal profile photo upload", "FOAL REGISTRATION")
    )
    add_visual_proof_pair(
        ("WhatsApp Image 2026-08-30 at 2.10.24 AM.jpeg", "Birth Log Registry & Summary Stats", "Foaling summary stats (Total, Colts, Fillies, Gelded, Sold) with status filters (Keep, Available)", "BIRTH LOG HUB"),
        ("WhatsApp Image 2026-08-30 at 2.10.20 AM (1).jpeg", "Official Foal Pedigree Certificate PDF", "High-res printable vector certificate with microchip, DNA profile, parentage & health", "OFFICIAL CERTIFICATE")
    )
    add_visual_proof_pair(
        ("WhatsApp Image 2026-08-30 at 2.10.22 AM (1).jpeg", "Gestation Countdown & Scan Milestones", "Live foaling countdown (339 days remaining) with automated 3-stage ultrasound milestones", "PREGNANCY ENGINE"),
        ("WhatsApp Image 2026-08-30 at 2.10.23 AM.jpeg", "Three Ultrasound Scans & Twin Alert", "3/3 Scans confirmed status with clinical red Twin Alert banner and re-scan countdown", "3-STAGE SCANS")
    )

    # -------------------------------------------------------------------------
    # SUBSECTION 2.1: FOAL DUE DATE PLACEMENT - CURRENT IMPLEMENTATION & OPTIONS
    # -------------------------------------------------------------------------
    add_h2("2.1 Foal Due Date UI Placement: Current Locations & Client Preference Options")
    add_body(
        "A critical question for the equine workflow is where the Foal Due Date should be most prominently displayed. "
        "The application currently computes the exact expected foaling date based on the 340-day equine gestation cycle "
        "(with earliest viable delivery at 320 days and overdue threshold at 365 days). "
        "Below are the current locations where the Foal Due Date appears, along with layout options for Tracey's preference:"
    )
    add_bullet(
        "Current Location 1: Mare Gestation & Pregnancy Card",
        "A prominent golden banner displaying 'FINAL FOALING DUE DATE: DD/MM/YYYY' accompanied by a live countdown pill "
        "(e.g., '339 Days Remaining') and the biological viable window (320-365 days).",
        "CURRENTLY LIVE ✅"
    )
    add_bullet(
        "Current Location 2: Breeding Wizard Completion Summary (Step 6)",
        "The final step of the 6-step breeding wizard reveals the calculated foaling due date and auto-schedules Day 14, 28, and 45 scan milestones.",
        "CURRENTLY LIVE ✅"
    )
    add_bullet(
        "Current Location 3: Stud Foaling Diary & Pasture Movement Roster",
        "In commercial stud view, every broodmare displays her expected due date with dynamic movement badges: Overdue (Red), "
        "Foaling Barn <14d (Amber), Close Paddock <30d (Yellow), and Upcoming 30+d (Green).",
        "CURRENTLY LIVE ✅"
    )
    add_bullet(
        "Current Location 4: Dedicated 'When Is My Foal Due?' Rapid Calculator",
        "Standalone rapid calculator allowing instant computation of due dates without saving records.",
        "CURRENTLY LIVE ✅"
    )
    add_bullet(
        "Current Location 5: Synced Chronological Calendar & Timeline Feed",
        "Chronological events timeline syncing scan dates, vaccine deadlines, and the foaling due date.",
        "CURRENTLY LIVE ✅"
    )

    add_visual_proof_pair(
        ("WhatsApp Image 2026-08-30 at 2.10.21 AM.jpeg", "Dedicated Due Date Calculator", "Instant due date calculation screen: Projected Foaling Date, Days Remaining & Viable Delivery Window", "RAPID CALCULATOR"),
        ("WhatsApp Image 2026-08-30 at 2.10.21 AM (1).jpeg", "Stud Foaling Diary Due Dates", "Broodmare commercial roster displaying Target Due Dates (340d) & pasture countdown badges", "STUD ROSTER DUE DATES")
    )

    add_body(
        "SPECIFIC QUESTION FOR TRACEY (DUE DATE PLACEMENT): Where does Tracey prefer the Foal Due Date to be most prominently emphasized? "
        "Options include: (A) Sticky top header on the Mare's primary profile card, (B) Dedicated Gestation / Pregnancy tab banner, "
        "(C) An 'Upcoming Foal Deliveries' summary card directly on the main Dashboard home screen, or (D) Inside the Stud Foaling Diary roster. "
        "Please also confirm if you prefer a simple date (DD/MM/YYYY) or with an active countdown pill (e.g. '12 Days Remaining').",
        bold_prefix="CLIENT DECISION REQUIRED: ",
        color=C_GOLD_DARK
    )

    # -------------------------------------------------------------------------
    # SUBSECTION 2.2: OFFICIAL PDF CERTIFICATE PRESENTATION & BUTTON PLACEMENT
    # -------------------------------------------------------------------------
    add_h2("2.2 Official PDF Certificate Presentation: Button Placement & Delivery Options")
    add_body(
        "The application features a complete vector PDF certificate rendering engine. It currently generates three official documents: "
        "(1) Official Foal Pedigree Certificate, (2) 45-Day Equine Pregnancy Scan Certificate (required for Thoroughbred Stud Book "
        "and Sport Horse registrations), and (3) Printable Stud Foaling Diary Reports. "
        "To ensure the certificate button is intuitive and easily accessible for breeders, we present the current layout and options:"
    )
    add_bullet(
        "Current Button Location 1: Foal Profile / Details Screen",
        "Located directly under 'Action Shortcuts' on the Foal Profile screen as a prominent golden button: [PDF CERTIFICATE]. "
        "Tapping opens the full vector print preview with instant download, print, or email sharing.",
        "CURRENTLY LIVE ✅"
    )
    add_bullet(
        "Current Button Location 2: Pregnancy Scans & Milestones Screen",
        "Located on the 45-Day scan confirmation card as: [VIEW & EXPORT 45-DAY CERTIFICATE], allowing vets and breeders to export proof of pregnancy.",
        "CURRENTLY LIVE ✅"
    )
    add_bullet(
        "Current Button Location 3: Commercial Buyer Management Section",
        "Linked to the buyer sale record, enabling 1-tap pedigree export when transferring ownership of a foal.",
        "CURRENTLY LIVE ✅"
    )

    add_visual_proof_pair(
        ("WhatsApp Image 2026-08-30 at 2.10.20 AM (1).jpeg", "Official Foal Pedigree Certificate PDF", "Luxury vector certificate layout with microchip, DNA profile, parentage & health summary", "PEDIGREE CERTIFICATE"),
        ("WhatsApp Image 2026-08-30 at 2.10.20 AM (2).jpeg", "Print Preview & PDF Export Engine", "Native print preview and PDF export engine with instant download & share options", "PRINT & EXPORT ENGINE")
    )

    add_body(
        "SPECIFIC QUESTION FOR TRACEY (CERTIFICATE PRESENTATION): How and where should the Certificate option be shown? "
        "Options include: (Option 1 - Current) As a prominent golden action button directly inside each Foal's Profile and Mare's Pregnancy card; "
        "(Option 2) A dedicated 'Certificates & Documents' vault tab in the bottom navigation where all generated certificates across all animals "
        "are centrally listed, searched, and exported; or (Option 3) Primarily positioned inside the Foal Buyer Management workflow for sales handover. "
        "We recommend a combination of Option 1 and Option 2 for maximum convenience.",
        bold_prefix="CLIENT DECISION REQUIRED: ",
        color=C_GOLD_DARK
    )

    # -------------------------------------------------------------------------
    # SECTION 3: SUBSCRIPTION TIERS & PRICING ARCHITECTURE (CLIENT CONFIRMATIONS)
    # -------------------------------------------------------------------------
    add_h1("3. Subscription Architecture, Animal Tiers & Mobile Store Policies")
    add_body(
        "In response to Meeting Points 2, 3, 4, 5, 6, 7, 21, 22, and 29, the subscription model represents a significant new "
        "architectural layer. The system must accommodate hobbyists with 1–2 horses while seamlessly handling large commercial studs with 200+ horses."
    )

    add_callout(
        "CLIENT PRICING AUTONOMY GUARANTEE:\n"
        "The development team does NOT assume, suggest, or dictate any subscription prices. All pricing decisions—including Monthly rates, "
        "Annual rates, currency selection, and Annual discount percentages—are 100% at Tracey's sole discretion.\n\n"
        "The application architecture and Supabase database are built to be completely dynamic: once the client determines the final pricing figures, "
        "the team will simply enter those exact amounts into the configuration tables.",
        bold_title="PRICING AUTONOMY & POLICY:"
    )

    add_h2("Proposed Subscription Tier Structure & Animal Quota Limits")
    add_body(
        "Below is the proposed tier framework structured around animal limits to prevent subscription sharing and abuse. "
        "The pricing fields are intentionally reserved for the client to confirm her desired rates:"
    )

    # Subscription Table (NO PRE-SET PRICES)
    sub_table = doc.add_table(rows=1, cols=5)
    sub_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    sub_table.autofit = False
    sub_table.columns[0].width = Inches(1.2)
    sub_table.columns[1].width = Inches(1.1)
    sub_table.columns[2].width = Inches(1.4)
    sub_table.columns[3].width = Inches(2.1)
    sub_table.columns[4].width = Inches(1.2)

    headers = ["Tier Plan", "Animal Limit", "Pricing Model", "Included Feature Scope", "Target Audience"]
    for i, h_text in enumerate(headers):
        cell = sub_table.rows[0].cells[i]
        set_cell_background(cell, "0A192F")
        set_cell_margins(cell, top=60, bottom=60, left=60, right=60)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h_text)
        r.font.bold = True
        r.font.size = Pt(8.5)
        r.font.color.rgb = RGBColor(255, 255, 255)

    sub_rows_data = [
        ("Free / Starter", "Up to 1 Animal", "Free Tier ($0.00)", "Basic gestation due date calculation, basic countdown, read-only FAQ. No PDF generation or buyer sales tracking.", "Hobbyists trying out the app"),
        ("Basic / Standard", "Up to 10 Animals", "[To be set by Client: Monthly & Annual Rate]", "Full 6-step breeding wizard, 3 ultrasound scans, preventative care logs, emergency vet directory, cloud photo sync.", "Recreational owners, multi-horse owners"),
        ("Professional", "Up to 50 Animals", "[To be set by Client: Monthly & Annual Rate]", "Everything in Basic PLUS Full Foal Suite (Birth logging, IgG testing, Pedigree certificates, Buyer management, Stud Foaling Diary).", "Professional breeders, small studs, vet practices"),
        ("Enterprise", "Up to 200 Animals", "[To be set by Client: Monthly, Annual & Custom Rate]", "Everything in Professional PLUS multi-staff access, commercial batch imports, dedicated backup, custom stud branding on PDFs.", "Commercial thoroughbred studs, large breeding farms")
    ]

    for row_data in sub_rows_data:
        cells = sub_table.add_row().cells
        for i, val in enumerate(row_data):
            set_cell_margins(cells[i], top=40, bottom=40, left=50, right=50)
            p = cells[i].paragraphs[0]
            if i in [0, 1]:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            else:
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            r = p.add_run(val)
            r.font.size = Pt(8)
            if i == 0:
                r.font.bold = True
                r.font.color.rgb = C_NAVY_DARK
            elif i == 1:
                r.font.bold = True
                r.font.color.rgb = C_GOLD_DARK
            elif i == 2:
                r.font.bold = True
                r.font.color.rgb = C_AMBER if "[" in val else C_GREEN
            else:
                r.font.color.rgb = C_TEXT

    set_table_borders(sub_table)
    doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # Visual proof of existing billing UI
    add_visual_proof_pair(
        ("WhatsApp Image 2026-08-30 at 2.10.26 AM (3).jpeg", "ABP Pro Master Breeder Tier Card", "In-app subscription tier card layout with verified feature checklist & auto-renew toggle", "SUBSCRIPTION CARD"),
        ("WhatsApp Image 2026-08-30 at 2.10.26 AM.jpeg", "Billing History & Security Guarantee", "Verified billing invoice list layout and official 256-bit bank-grade encryption guarantee", "INVOICE PORTAL")
    )

    add_h2("Preventing Subscription Abuse & Animal Limit Enforcement")
    add_body(
        "To answer the client's question in Meeting Point 5 regarding whether a user with a 5-animal plan can add unlimited animals: "
        "The application database strictly tracks: User ID ➔ Active Subscription ➔ Max Allowed Quota ➔ Current Animal Count. "
        "When an owner reaches their limit, the '+ Add Animal' action is gracefully intercepted with an informative prompt explaining "
        "that their quota has been reached, displaying a 1-tap upgrade button."
    )

    add_callout(
        "CRITICAL APP STORE COMPLIANCE (APPLE & GOOGLE IN-APP PURCHASE POLICIES):\n"
        "Under Apple App Store Guideline 3.1.1 and Google Play Billing policies, any digital subscription purchased inside a mobile application "
        "MUST be processed through Apple In-App Purchase (StoreKit) and Google Play Billing. Apple and Google strictly prohibit third-party "
        "gateways (like Stripe) directly inside the iOS/Android apps for unlocking digital features, taking a standard 15%–30% platform fee.\n\n"
        "RECOMMENDED HYBRID ARCHITECTURE:\n"
        "1. Stripe on the Web Landing Page / Admin Portal: Users can purchase or renew subscriptions directly on the marketing website via Stripe "
        "(credit card, Google Pay, Apple Pay web, direct wire transfer) where you keep ~97% of revenue with NO 30% store fees.\n"
        "2. Apple & Google In-App Purchases inside the Mobile App: Mobile users can either purchase via native Apple/Google subscriptions OR log in "
        "with an existing web account purchased via Stripe (fully compliant under Apple's 'Multiplatform App / Reader' rule).\n\n"
        "CLIENT QUESTION: Does Tracey approve this hybrid payment architecture (Stripe on Web + Native IAP on iOS/Android Stores)?",
        bold_title="CRITICAL PAYMENT ARCHITECTURE NOTICE:"
    )

    # -------------------------------------------------------------------------
    # SECTION 4: MARKETING LANDING PAGE, EVENT PROMOTION & QR CODE STRATEGY
    # -------------------------------------------------------------------------
    add_h1("4. Marketing Landing Page, Event Strategy & The QR Code Decision")
    add_body(
        "Meeting Points 14, 15, and 27 discuss preparing for a major Australian horse event at the end of October. "
        "The client asked whether she could have a QR code for attendees to scan, and whether it should point to a web landing page or the app."
    )

    add_h2("The Strategic Question: What Should the QR Code Open?")
    add_body(
        "We have conducted a thorough UX and technical evaluation of both options:"
    )

    # QR Code Comparison Table
    qr_table = doc.add_table(rows=1, cols=3)
    qr_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    qr_table.autofit = False
    qr_table.columns[0].width = Inches(1.5)
    qr_table.columns[1].width = Inches(2.75)
    qr_table.columns[2].width = Inches(2.75)

    qr_headers = ["Evaluation Metric", "Option A: Modern Web Landing Page (STRONGLY RECOMMENDED)", "Option B: Direct App Store / App Link"]
    for i, h_text in enumerate(qr_headers):
        cell = qr_table.rows[0].cells[i]
        set_cell_background(cell, "0A192F")
        set_cell_margins(cell, top=60, bottom=60, left=60, right=60)
        p = cell.paragraphs[0]
        r = p.add_run(h_text)
        r.font.bold = True
        r.font.size = Pt(8.5)
        r.font.color.rgb = RGBColor(255, 255, 255)

    qr_comparison_data = [
        ("Device Compatibility", "Universal 100% compatibility. Works instantly on Safari (iPhone), Chrome (Android), and tablets without any installation.", "Requires dynamic link routing. If configured incorrectly, Android users may fail on Apple links."),
        ("Event Experience & Conversion", "EXCELLENT. Attendees instantly see visual screenshots, feature highlights, pricing, and video walkthroughs before deciding to download.", "POOR / HIGH FRICTION. Forces the user directly into the App Store download screen without context. Many attendees abandon download due to slow paddock cell data."),
        ("Timing Safety (October Event)", "100% BULLETPROOF. Even if Apple or Google review is pending during the event, the landing page is live, captures attendee emails, offers pre-orders, and lets users test the live web demo.", "HIGH RISK. If Apple/Google review experiences even a 48-hour delay or rejection during the event, scanning the QR code returns an embarrassing broken link / 404 error."),
        ("Lead Capture & Special Offers", "Can display a custom Australian Event Welcome Banner with an exclusive event promo code (e.g. 'AUS-EQUINE-2026' for launch discount) and email signup.", "Cannot capture leads or emails prior to download. If an attendee cancels download, they are lost forever."),
        ("Smart App Store Badges", "Features official 1-tap 'Download on App Store' and 'Get it on Google Play' buttons that deep-link directly to the store once live.", "Direct store jump only.")
    ]

    for row_data in qr_comparison_data:
        cells = qr_table.add_row().cells
        for i, val in enumerate(row_data):
            set_cell_margins(cells[i], top=40, bottom=40, left=50, right=50)
            p = cells[i].paragraphs[0]
            r = p.add_run(val)
            r.font.size = Pt(8)
            if i == 0:
                r.font.bold = True
                r.font.color.rgb = C_NAVY_DARK
            elif i == 1:
                r.font.color.rgb = C_GREEN if "EXCELLENT" in val or "100%" in val else C_TEXT
                if "STRONGLY RECOMMENDED" in val or "BULLETPROOF" in val:
                    r.font.bold = True
            else:
                r.font.color.rgb = C_RED if "POOR" in val or "HIGH RISK" in val else C_TEXT

    set_table_borders(qr_table)
    doc.add_paragraph().paragraph_format.space_after = Pt(6)

    add_body(
        "DEVELOPMENT TEAM RECOMMENDATION: We strongly recommend Option A. We will build a sleek, luxury responsive landing page "
        "at the official domain (e.g. animalbirthdaypredictor.com) featuring high-resolution visuals, the 6-step breeding wizard breakdown, "
        "the Foal Suite preview, tier breakdowns, and prominent download buttons. The printed QR code for the October Australian event "
        "will point to this page, guaranteeing zero risk and maximum attendee conversion."
    )
    add_bullet("Client Confirmation Required", "Does Tracey approve Option A (Web Landing Page with smart app store badges) for the event QR code?", "AWAITING CONFIRMATION ⏳", is_pending=True)

    # -------------------------------------------------------------------------
    # SECTION 5: WEB ADMIN DASHBOARD PROPOSAL (REALISTIC & MANAGEABLE)
    # -------------------------------------------------------------------------
    add_h1("5. Web Admin Dashboard Proposal: Clear, Feasible & High-Impact")
    add_body(
        "In Meeting Points 12 and 13, the client asked whether a separate website/database interface is required to view customers, "
        "submitted animals, subscriptions, and testing results from her Mac/laptop. "
        "A Web Admin Dashboard is indeed the ideal solution because it gives Tracey operational control from any browser without requiring mobile app store updates."
    )

    add_h2("What We Propose to Build (Clean, Highly Feasible & Practical)")
    add_body(
        "To ensure rapid delivery, flawless reliability, and straightforward maintenance without unnecessary backend complexity, "
        "we have defined the 7 core features that deliver 100% of the operational oversight Tracey needs:"
    )

    admin_features = [
        ("1. Secure Role-Based Admin Login", "Dedicated web authentication portal restricting access exclusively to Tracey and authorized administrators (backed by Supabase Auth with admin role claims)."),
        ("2. Customer & Breeder Directory", "Searchable, sortable table of all registered users displaying Name, Email, Account Creation Date, Last Active Date, and current Account Status."),
        ("3. Subscription & Quota Monitor", "Real-time overview of active user plans (Free, Basic, Pro, Enterprise), animal quota limits, renewal dates, and Stripe billing status."),
        ("4. Manual Quota & VIP Override", "Simple 1-tap ability for Tracey to adjust an animal limit or grant a complimentary Pro/Enterprise upgrade to a VIP stud or vet client directly from the dashboard."),
        ("5. Global Multi-Species Animal Registry", "Master table of all animals entered in the system, filterable by species (Horse, Dog, Cat) with quick search by Animal Name, Microchip Number, Stud Book ID, or Owner Email."),
        ("6. Gestation & Clinical Testing Audit Logs", "Read-only inspection feed showing recent ultrasound scan entries (Scan 1/2/3 confirmations, Twin alert occurrences) and Foal IgG antibody test results (mg/dL)."),
        ("7. 1-Click CSV / Excel Export Engine", "Instant export buttons to download complete customer lists, animal registries, or breeding logs into CSV/Excel spreadsheets for accounting, marketing, or backup.")
    ]

    for title, desc in admin_features:
        add_bullet(title, desc, "IN-SCOPE & HIGHLY RECOMMENDED ✅", is_done=True)

    add_h2("What We Intentionally Exclude from Phase 1 (To Protect Project Stability)")
    add_body(
        "To prevent scope bloat, excessive development hours, and maintenance nightmares, we recommend excluding the following "
        "unnecessary items from Phase 1:"
    )
    add_bullet("Live Video Streaming from Barns", "Real-time camera streaming requires massive media server infrastructure and ongoing bandwidth costs that are unnecessary for a breeding management app.", "EXCLUDED FROM PHASE 1 ❌", is_pending=False, is_done=False)
    add_bullet("Custom In-App Support Chat Desk", "Building a custom ticketing desk from scratch is costly to maintain. We recommend embedding an established widget (e.g. Crisp, Intercom) or a direct support email link.", "EXCLUDED FROM PHASE 1 ❌", is_pending=False, is_done=False)
    add_bullet("Raw Database Schema Editing", "Direct unvalidated SQL editing from the UI creates severe risks of data corruption. The dashboard will provide structured, validated controls instead.", "EXCLUDED FROM PHASE 1 ❌", is_pending=False, is_done=False)

    add_body(
        "CLIENT QUESTION: Does Tracey agree with this 7-feature Web Admin Dashboard scope for Phase 1?",
        bold_prefix="APPROVAL REQUIRED: ",
        color=C_GOLD_DARK
    )

    # -------------------------------------------------------------------------
    # SECTION 6: APP STORE PUBLISHING, TESTING & LEGAL ENTITY ALIGNMENT
    # -------------------------------------------------------------------------
    add_h1("6. App Store Publishing, Device Testing & Legal Entity Alignment")
    add_body(
        "Meeting Points 16, 17, 18, 19, 20, and 24 address the critical steps for publishing and beta testing:"
    )

    add_h2("Apple Developer Account & 'The Flying Dutchman' Resolution")
    add_body(
        "The client correctly identified that her existing Apple Developer account displays her veterinary clinic name "
        "('The Flying Dutchman'), which could confuse horse owners and pet parents who expect 'Animal Birthday Predictor'. "
        "We recommend the following coordinated action with the client's solicitor:"
    )
    add_bullet("Step 1: Entity & D-U-N-S® Registration", "The solicitor must confirm the legal incorporation of the app entity (e.g., Animal Birthday Predictor Pty Ltd) and obtain a free 9-digit D-U-N-S number from Dun & Bradstreet (required by Apple for corporate accounts).", "PENDING SOLICITOR ⏳", is_pending=True)
    add_bullet("Step 2: Apple Developer Organization Account", "Enroll the new entity with Apple. Alternatively, if the existing account can be renamed, request a legal entity name update through Apple Developer Support.", "PENDING CLIENT/SOLICITOR ⏳", is_pending=True)
    add_bullet("Step 3: Team Access for App Store Connect", "Grant the development team Admin or App Manager access so we can configure certificates, provisioning profiles, TestFlight builds, and store listing metadata.", "ACTION REQUIRED ⏳", is_pending=True)

    add_h2("Beta Testing Plan (Android APK & iOS TestFlight)")
    add_bullet("Android APK Ready Immediately", "The development team can compile and provide an Android APK file within 24–48 hours. Any user with an Android phone can install and test the complete app immediately.", "READY FOR IMMEDIATE DELIVERY ✅")
    add_bullet("iPhone / iOS TestFlight Testing", "As soon as Apple Developer access is provided, we will deploy the build to Apple TestFlight. Up to 10,000 external beta testers can test the app on iPhones before public release.", "AWAITING APPLE ACCOUNT ACCESS ⏳", is_pending=True)
    add_bullet("Beta Tester Roster", "Tracey is invited to assemble a list of 5–10 trusted horse breeders and vets to participate in the closed beta group.", "CLIENT ACTION ⏳", is_pending=True)

    # -------------------------------------------------------------------------
    # SECTION 7: CANINE (DOG) & FELINE (CAT) MODULE INTEGRATION
    # -------------------------------------------------------------------------
    add_h1("7. Canine (Dog) & Feline (Cat) Module Strategy")
    add_body(
        "Meeting Points 1, 10, 11, 25, and 27 discuss expanding the multi-species platform to include Dogs and Cats. "
        "The development team has already engineered the multi-species architecture and database schema in Flutter to support this seamlessly."
    )
    add_bullet("Configurable Gestation Timelines", "Unlike horses (~340 days / 11 months), dogs have an average gestation of ~63 days (9 weeks), and cats ~65 days. The countdown and scan schedules are fully configurable per species.", "ARCHITECTURE PREPARED ✅")
    add_bullet("Dog-Specific Milestone Scans", "Day 25–30 ultrasound check for gestational sac confirmation; Day 45–55 radiographic X-ray for puppy skeletal count; whelping date calculations.", "READY FOR CLIENT CONTENT ⏳")
    add_bullet("Cat / Feline Workflow", "Tracey is currently working on the Cat content in Thunkable. Once ready, the team will review her content and integrate it with 100% visual consistency.", "AWAITING THUNKABLE REVIEW ⏳", is_pending=True)
    add_bullet("Thunkable Access Request", "Tracey is requested to share direct link/access to her Thunkable project so the dev team can inspect her exact dog and cat form fields.", "CLIENT ACTION ⏳", is_pending=True)

    # -------------------------------------------------------------------------
    # SECTION 8: EXECUTIVE SUMMARY TABLE OF OPEN QUESTIONS FOR TRACEY
    # -------------------------------------------------------------------------
    add_h1("8. Executive Checklist of Questions & Confirmations for Tracey")
    add_body(
        "To ensure full alignment before commencing execution, we have summarized all open questions into this quick-reference checklist. "
        "Notice that all pricing decisions are left entirely to the client:"
    )

    qa_summary_table = doc.add_table(rows=1, cols=3)
    qa_summary_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    qa_summary_table.autofit = False
    qa_summary_table.columns[0].width = Inches(1.8)
    qa_summary_table.columns[1].width = Inches(3.6)
    qa_summary_table.columns[2].width = Inches(1.6)

    q_hdr = qa_summary_table.rows[0].cells
    for i, title in enumerate(["Topic / Scope Item", "Specific Confirmation Question for Client", "Status / Next Action"]):
        set_cell_background(q_hdr[i], "0A192F")
        p = q_hdr[i].paragraphs[0]
        p.paragraph_format.space_before = Pt(4)
        p.paragraph_format.space_after = Pt(4)
        r = p.add_run(title)
        r.font.bold = True
        r.font.size = Pt(8.5)
        r.font.color.rgb = RGBColor(255, 255, 255)

    client_questions_list = [
        ("1. Subscription Tiers & Pricing", "Does Tracey confirm the tier animal limits (Free: 1, Basic: 10, Pro: 50, Enterprise: 200 animals), and what specific Monthly and Annual price rates (and any annual discount %) does she wish to set for each tier?", "Awaiting Client Rates"),
        ("2. Feature Gating", "Should the Foal Suite (birth log, IgG test, foal certificate, buyer record) be exclusive to Pro & Enterprise tiers, or available on Basic?", "Awaiting Client Decision"),
        ("3. Payment Gateways (Stripe vs IAP)", "Does Tracey approve the recommended hybrid model: Stripe on Web Landing Page (saving 30% fees) + Apple/Google In-App Purchases on mobile?", "Awaiting Client Confirmation"),
        ("4. Event QR Code Strategy", "Does Tracey confirm Option A (QR code points to modern Web Landing Page with smart app store links & event promo) for the October Australian event?", "Awaiting Client Confirmation"),
        ("5. Web Admin Dashboard Scope", "Does Tracey approve the 7-feature Web Admin Dashboard scope (Customer directory, Subscription monitor, Animal registry, IgG test logs, CSV export)?", "Awaiting Client Confirmation"),
        ("6. Apple Developer Account Transfer", "What is the solicitor's timeline for completing the new company registration and Apple D-U-N-S number to transfer away from 'The Flying Dutchman'?", "Awaiting Solicitor Update"),
        ("7. Android APK Beta Testing", "Can Tracey confirm which email addresses / testers should receive the first Android APK build for hands-on phone testing?", "Awaiting Tester Emails"),
        ("8. Thunkable Dog & Cat Review", "Can Tracey share login/viewer access or project links to her current Thunkable Dog and Cat work for field verification?", "Awaiting Thunkable Links"),
        ("9. Solicitor Legal Terms & Privacy", "When can the solicitor provide the finalized legal Terms & Conditions and Privacy Policy for drop-in to the /disclaimer screen?", "Awaiting Solicitor Text"),
        ("10. Foal Due Date UI Placement", "Where does Tracey prefer the Foal Due Date to be most prominently displayed (Top of Mare Profile, Pregnancy Tab, Dashboard Widget, or Stud Diary)? What exact format/countdown style is preferred?", "Awaiting Client UI Preference"),
        ("11. Certificate Presentation & Location", "How and where should the Certificate option be presented (Direct button inside Foal/Mare Profile, a centralized 'Certificates Vault' tab, or inside Buyer Sales workflow)?", "Awaiting Client UI Preference")
    ]

    for cat_t, q_t, stat_t in client_questions_list:
        row_cells = qa_summary_table.add_row().cells
        set_cell_margins(row_cells[0], top=40, bottom=40, left=50, right=50)
        set_cell_margins(row_cells[1], top=40, bottom=40, left=50, right=50)
        set_cell_margins(row_cells[2], top=40, bottom=40, left=50, right=50)

        p0 = row_cells[0].paragraphs[0]
        r0 = p0.add_run(cat_t)
        r0.font.bold = True
        r0.font.size = Pt(8)
        r0.font.color.rgb = C_NAVY_DARK

        p1 = row_cells[1].paragraphs[0]
        r1 = p1.add_run(q_t)
        r1.font.size = Pt(8)
        r1.font.color.rgb = C_TEXT

        p2 = row_cells[2].paragraphs[0]
        r2 = p2.add_run(stat_t)
        r2.font.bold = True
        r2.font.size = Pt(7.5)
        r2.font.color.rgb = C_AMBER

    set_table_borders(qa_summary_table)
    doc.add_paragraph().paragraph_format.space_after = Pt(8)

    # -------------------------------------------------------------------------
    # SECTION 9: NEW SCOPE BREAKDOWN & DETAILED IMPLEMENTATION TIMELINES
    # -------------------------------------------------------------------------
    add_h1("9. New Work Scope Breakdown & Detailed Delivery Timelines")
    add_body(
        "As noted in Meeting Point 21, the complete subscription architecture, marketing landing page, web admin dashboard, "
        "and multi-species expansion represent NEW deliverables that were not part of the original project scope. "
        "To provide full project-management transparency, below is the comprehensive scope breakdown and estimated delivery timelines for each new item:"
    )

    add_h2("Detailed Breakdown of New Development Items")

    add_bullet(
        "New Deliverable 1: Subscription Backend, Quota Enforcement & Stripe Integration",
        "Architecture updates in Supabase PostgreSQL: user subscription status tracking, dynamic animal quota counters, "
        "in-app upgrade modals when limits are reached, Stripe checkout on web (monthly/annual recurring billing, webhooks for automatic renewal/cancellation), "
        "and StoreKit / Google Play Billing synchronization. "
        "Estimated Timeline: 5 to 7 Working Days (Accelerated Sprint).",
        "ACCELERATED (5-7 DAYS) ⏳",
        is_pending=True
    )

    add_bullet(
        "New Deliverable 2: Marketing Landing Page & October Event QR Code Generation",
        "High-conversion responsive landing page hosted at the official domain (e.g. animalbirthdaypredictor.com). Includes visual feature tours, "
        "interactive due date calculator teaser, smart 1-tap download badges for iOS & Android, Australian event promotional banner, "
        "and high-resolution vector QR code package for printed banners/merchandise. "
        "Estimated Timeline: 3 to 5 Working Days (Guaranteed ready well before late October event).",
        "FAST-TRACK (3-5 DAYS) ⏳",
        is_pending=True
    )

    add_bullet(
        "New Deliverable 3: Web-Based Admin Dashboard Portal",
        "Clean, responsive web portal for Tracey accessible on Mac/PC. Delivers all 7 core operational features: Secure admin login, "
        "customer directory, subscription & quota monitor, manual VIP quota override, multi-species registry, clinical IgG test audit log, and CSV/Excel export. "
        "Estimated Timeline: 4 to 6 Working Days (7 core features).",
        "RAPID DELIVERY (4-6 DAYS) ⏳",
        is_pending=True
    )

    add_bullet(
        "New Deliverable 4: Canine (Dog) & Feline (Cat) Module Implementation",
        "Detailed review of Tracey's Thunkable Dog/Cat content, configuring species-specific gestation timelines (~63 days for dogs, ~65 days for cats), "
        "canine ultrasound/x-ray scan schedules, puppy/kitten whelping logs, and form fields under the unified UI system. "
        "Estimated Timeline: 4 to 5 Working Days (Starting upon receiving Thunkable content).",
        "RAPID SPRINT (4-5 DAYS) ⏳",
        is_pending=True
    )

    add_bullet(
        "New Deliverable 5: Native Android APK Beta Build Delivery",
        "Compiling release Android APK with production Supabase backend, packaged for direct sideloading and testing on Android devices. "
        "Estimated Timeline: Immediate Delivery (Within 24 Hours).",
        "IMMEDIATE (24 HRS) ✅",
        is_done=True
    )

    add_bullet(
        "New Deliverable 6: Apple TestFlight & App Store Publishing Preparation",
        "Setting up iOS TestFlight builds, provisioning profiles, store listing metadata, screenshots, legal notices, and assisting solicitor with entity transfer. "
        "Estimated Timeline: 3 to 5 Working Days (Ready for Apple submission).",
        "RAPID SUBMISSION (3-5 DAYS) ⏳",
        is_pending=True
    )

    add_h2("Master Phased Delivery Schedule & Timeline Matrix")
    add_body(
        "The following matrix outlines the proposed chronological sequencing of all new deliverables, strategically aligned with "
        "the Australian October horse event and the upcoming Northern Hemisphere breeding season:"
    )

    # Timeline Table
    timeline_table = doc.add_table(rows=1, cols=5)
    timeline_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    timeline_table.autofit = False
    timeline_table.columns[0].width = Inches(1.5)
    timeline_table.columns[1].width = Inches(1.2)
    timeline_table.columns[2].width = Inches(1.1)
    timeline_table.columns[3].width = Inches(1.8)
    timeline_table.columns[4].width = Inches(1.4)

    tl_headers = ["Phase & Deliverable", "Scope Type", "Duration", "Key Dependencies", "Target Delivery Window"]
    for i, h_text in enumerate(tl_headers):
        cell = timeline_table.rows[0].cells[i]
        set_cell_background(cell, "0A192F")
        set_cell_margins(cell, top=60, bottom=60, left=60, right=60)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h_text)
        r.font.bold = True
        r.font.size = Pt(8.5)
        r.font.color.rgb = RGBColor(255, 255, 255)

    timeline_data = [
        ("Phase 1: Android APK Build Delivery", "Core Milestone Delivery", "24 Hours", "Client confirms tester email addresses", "Immediate (Within 24 hrs)"),
        ("Phase 2: Marketing Landing Page & Vector QR Code", "New Deliverable (Event Priority)", "3 to 5 Days", "Domain name confirmation & event details", "Mid September 2026 (Ready Weeks Before Event)"),
        ("Phase 3: Subscription Backend & Stripe Web Integration", "New Deliverable (Commercial Architecture)", "5 to 7 Days", "Client confirms final tier pricing rates & Stripe account", "Late September 2026"),
        ("Phase 4: Web Admin Dashboard Portal (7 Features)", "New Deliverable (Management Tool)", "4 to 6 Days", "Supabase schema & admin access", "Early October 2026"),
        ("Phase 5: Dog & Cat Workflow Alignment", "New Deliverable (Multi-Species Expansion)", "4 to 5 Days", "Client shares Thunkable project access & content", "Early to Mid October 2026"),
        ("Phase 6: Apple TestFlight & App Store Submission", "New Deliverable (Store Launch)", "3 to 5 Days", "Solicitor entity transfer & Apple Developer account invite", "Mid October 2026 (Store Approval Dependent)")
    ]

    for row_data in timeline_data:
        cells = timeline_table.add_row().cells
        for i, val in enumerate(row_data):
            set_cell_margins(cells[i], top=40, bottom=40, left=50, right=50)
            p = cells[i].paragraphs[0]
            if i in [1, 2, 4]:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            else:
                p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            r = p.add_run(val)
            r.font.size = Pt(8)
            if i == 0:
                r.font.bold = True
                r.font.color.rgb = C_NAVY_DARK
            elif i == 2:
                r.font.bold = True
                r.font.color.rgb = C_GOLD_DARK
            elif i == 4:
                r.font.bold = True
                r.font.color.rgb = C_GREEN if "Immediate" in val or "Mid September" in val else C_TEXT
            else:
                r.font.color.rgb = C_TEXT

    set_table_borders(timeline_table)
    doc.add_paragraph().paragraph_format.space_after = Pt(8)

    add_body(
        "SUMMARY OF SEASONAL READINESS: This accelerated timeline guarantees that the Marketing Landing Page and Event QR Code are 100% "
        "deployed and tested weeks before the Australian horse event at the end of October, and that the entire multi-species subscription platform "
        "is completely battle-tested and published well ahead of the Northern Hemisphere breeding season."
    )

    # Closing Signature Block
    p_close = doc.add_paragraph()
    p_close.paragraph_format.space_before = Pt(16)
    p_close.paragraph_format.space_after = Pt(2)
    r_close = p_close.add_run("Submitted with complete technical rigor and commitment to excellence,\n")
    r_close.font.size = Pt(9.5)
    r_close.font.italic = True
    r_close.font.color.rgb = C_GRAY
    r_team = p_close.add_run("The Animal Birthday Predictor (ABP) Engineering & Design Team")
    r_team.font.bold = True
    r_team.font.size = Pt(10)
    r_team.font.color.rgb = C_NAVY_DARK

    # Save Document
    primary_filename = "ABP_Development_Handover_Review_and_Client_Alignment_Notes_Final.docx"
    doc.save(primary_filename)
    print(f"Master Client Handover & Alignment Notes DOCX with In-Place Visual Proofs Successfully Generated: {primary_filename}")
    for secondary_fn in [
        "ABP_Development_Handover_Review_and_Client_Alignment_Notes_Updated.docx",
        "ABP_Development_Handover_Review_and_Client_Alignment_Notes.docx"
    ]:
        try:
            doc.save(secondary_fn)
            print(f"Also updated {secondary_fn}")
        except PermissionError:
            print(f"Notice: {secondary_fn} was locked by Word. Primary file saved to {primary_filename}")

if __name__ == "__main__":
    build_handover_document()
