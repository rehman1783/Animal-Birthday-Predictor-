import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """
    Two-pass canvas to compute total pages dynamically and draw headers and footers.
    """
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_header_footer(num_pages)
            super(NumberedCanvas, self).showPage()
        super(NumberedCanvas, self).save()

    def draw_header_footer(self, page_count):
        self.saveState()
        
        primary_gold = colors.HexColor("#C59B27")
        navy_dark = colors.HexColor("#0D1B2A")
        text_gray = colors.HexColor("#64748B")
        line_color = colors.HexColor("#CBD5E1")

        # Top Running Header (From Page 2 onwards)
        if self._pageNumber > 1:
            self.setFont("Helvetica-Bold", 8)
            self.setFillColor(navy_dark)
            self.drawString(54, 752, "ANIMAL BIRTHDAY PREDICTOR (ABP)")
            
            self.setFont("Helvetica", 8)
            self.setFillColor(text_gray)
            self.drawRightString(612 - 54, 752, "Milestone 2 Progress & Feature Analysis Report")
            
            self.setStrokeColor(line_color)
            self.setLineWidth(0.6)
            self.line(54, 744, 612 - 54, 744)

        # Bottom Running Footer (All pages)
        self.setStrokeColor(line_color)
        self.setLineWidth(0.6)
        self.line(54, 44, 612 - 54, 44)

        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(primary_gold)
        self.drawString(54, 31, "ABP Proprietary & Confidential")

        self.setFont("Helvetica", 8)
        self.setFillColor(text_gray)
        self.drawRightString(612 - 54, 31, f"Page {self._pageNumber} of {page_count}")
        
        self.restoreState()


def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Premium Color Palette
    c_navy = colors.HexColor("#0D1B2A")
    c_navy_accent = colors.HexColor("#1E3A8A")
    c_gold = colors.HexColor("#B8860B")
    c_gold_banner = colors.HexColor("#FDF8ED")
    c_gold_border = colors.HexColor("#EAD7A1")
    c_text_dark = colors.HexColor("#1E293B")
    c_text_muted = colors.HexColor("#64748B")

    # Typography Styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=c_navy,
        spaceAfter=3
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=15,
        textColor=c_gold,
        spaceAfter=12
    )

    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=c_navy,
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'SectionH2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13,
        textColor=c_navy_accent,
        spaceBefore=6,
        spaceAfter=3,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=c_text_dark,
        spaceAfter=3
    )

    bullet_style = ParagraphStyle(
        'BulletItem',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=11.5,
        textColor=c_text_dark,
        leftIndent=10,
        firstLineIndent=-10,
        spaceAfter=2
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.white
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=c_text_dark
    )

    table_cell_bold = ParagraphStyle(
        'TableCellBold',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=10,
        textColor=c_navy
    )

    story = []

    # ----------------------------------------------------
    # DOCUMENT BANNER & METADATA
    # ----------------------------------------------------
    story.append(Paragraph("ANIMAL BIRTHDAY PREDICTOR (ABP)", title_style))
    story.append(Paragraph("MILESTONE 2 PROGRESS & NEXT-STAGE CLIENT REQUIREMENTS REPORT", subtitle_style))

    meta_table_data = [
        [
            Paragraph("<b>Project:</b> Animal Birthday Predictor Mobile App", body_style),
            Paragraph("<b>Milestone 2 Start Date:</b> 20 August 2026", body_style),
        ],
        [
            Paragraph("<b>Technology Stack:</b> Flutter, Dart, Riverpod, Supabase", body_style),
            Paragraph("<b>Milestone 2 Status:</b> <font color='#107E44'><b>100% COMPLETED (All 21 Deliverables)</b></font>", body_style),
        ]
    ]
    meta_table = Table(meta_table_data, colWidths=[250, 254])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), c_gold_banner),
        ('BOX', (0, 0), (-1, -1), 1, c_gold),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, c_gold_border),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 10))

    # ----------------------------------------------------
    # SECTION 1: MILESTONE 2 DELIVERABLES & PROGRESS NOTES
    # ----------------------------------------------------
    story.append(Paragraph("1. Milestone 2 Deliverables & Technical Progress Notes", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceAfter=6, spaceBefore=0))

    m2_deliverables_data = [
        [
            Paragraph("<b>Milestone Deliverable</b>", table_header_style),
            Paragraph("<b>Status</b>", table_header_style),
            Paragraph("<b>Implementation Details & Technical Notes</b>", table_header_style)
        ],
        [
            Paragraph("<b>Pregnancy Module</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Full equine gestation module supporting Natural, Chilled, Frozen, & ICSI/ET methods with live countdown timers and progress tracking.", table_cell_style)
        ],
        [
            Paragraph("<b>Pregnancy Details</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Detailed view with circular progress bar, trimester breakdown, expected foaling countdown, and days elapsed.", table_cell_style)
        ],
        [
            Paragraph("<b>Three Pregnancy Scans</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Automatic calculation & tracking for Scan 1 (Day 14–16), Scan 2 (Day 30 Heartbeat), and Scan 3 (Day 45 Organogenesis).", table_cell_style)
        ],
        [
            Paragraph("<b>Advanced Pregnancy Info</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Comprehensive biological timeline detailing monthly fetal milestones, maternal changes, and veterinary guidance.", table_cell_style)
        ],
        [
            Paragraph("<b>Caslick Information</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Dedicated Caslick procedure tracking, surgical history logging, and pre-foaling opening reminders.", table_cell_style)
        ],
        [
            Paragraph("<b>Fetal Sex</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Ultrasound fetal gender determination logging (Colt, Filly, Unknown) recorded during veterinarian scan sessions.", table_cell_style)
        ],
        [
            Paragraph("<b>Preventative Care</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Complete wellness tracking system for mares, foals, and puppies with historical log entries and due date alerts.", table_cell_style)
        ],
        [
            Paragraph("<b>Vaccination Module</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Standard equine vaccination schedule (Pneumabort-K at 5, 7, 9 months; Tetanus/Flu booster at 10 months).", table_cell_style)
        ],
        [
            Paragraph("<b>Dentist Records</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Equine dental checkup logging, floating records, practitioner notes, and next scheduled exam tracking.", table_cell_style)
        ],
        [
            Paragraph("<b>Farrier Records</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Hoof care and shoeing/trimming log with farrier contact association and 6–8 week recurring cycle tracking.", table_cell_style)
        ],
        [
            Paragraph("<b>Phone Dial Integration</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("AppPhoneLauncher integrated across Vet, Breeder, and Farrier cards with direct native dialer and clipboard fallback.", table_cell_style)
        ],
        [
            Paragraph("<b>Record Detail Menu</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Contextual quick action menus on animal cards providing one-tap navigation to edit, view, scans, and care logs.", table_cell_style)
        ],
        [
            Paragraph("<b>Complete Record Detail View</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Unified profile screen consolidating pedigree, microchip, breeding records, preventative health, and photos.", table_cell_style)
        ],
        [
            Paragraph("<b>Edit Existing Records</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Full multi-attribute editing support for animal profiles, breeding entries, and dates with database synchronization.", table_cell_style)
        ],
        [
            Paragraph("<b>Pregnancy Scan Editing</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("In-place editing of scan dates, confirmation status, ultrasound notes, and attending veterinarian details.", table_cell_style)
        ],
        [
            Paragraph("<b>Persist Scan Confirmations</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Permanent database persistence for Scans 1, 2, and 3 confirmation flags across app restarts and state refreshes.", table_cell_style)
        ],
        [
            Paragraph("<b>Recipient Photo Saving</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Dedicated photo capture and cloud/local storage integration specifically for surrogate/recipient mares in ET workflows.", table_cell_style)
        ],
        [
            Paragraph("<b>Android Image Rendering Fix</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Resolved memory handling and aspect ratio rendering issues for camera/gallery image previews on Android devices.", table_cell_style)
        ],
        [
            Paragraph("<b>Multiple Images Support</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Multi-photo management allowing animal profile avatars, ultrasound scan captures, and markings reference pictures.", table_cell_style)
        ],
        [
            Paragraph("<b>Complete CRUD Operations</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Create, Read, Update, and Delete operations fully wired across Animals, Pregnancy Records, Care Logs, and Contacts.", table_cell_style)
        ],
        [
            Paragraph("<b>Testing of Horse Workflow</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Verified complete equine lifecycle flow: Mare Registration → Breeding Method → Scans 1/2/3 → Foaling Due Date calculation.", table_cell_style)
        ],
    ]

    m2_table = Table(m2_deliverables_data, colWidths=[130, 65, 309])
    m2_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('BOX', (0, 0), (-1, -1), 1, c_navy),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(m2_table)
    story.append(Spacer(1, 10))

    # ----------------------------------------------------
    # SECTION 2: CLIENT FEEDBACK & NEXT STAGE ANALYSIS (12 ITEMS)
    # ----------------------------------------------------
    story.append(PageBreak())
    story.append(Paragraph("2. Client Feedback & Next Stage Feature Analysis (12 Items)", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceAfter=6, spaceBefore=0))

    story.append(Paragraph("The following table evaluates each item requested in the client's latest feedback, categorized by current implementation state:", body_style))
    story.append(Spacer(1, 4))

    client_items_data = [
        [
            Paragraph("<b>#</b>", table_header_style),
            Paragraph("<b>Client Requirement</b>", table_header_style),
            Paragraph("<b>Status</b>", table_header_style),
            Paragraph("<b>Technical Analysis & Next Stage Action</b>", table_header_style)
        ],
        [
            Paragraph("<b>1</b>", table_cell_bold),
            Paragraph("<b>45-Day Scan Certificate</b><br/>(AI & Recipient Mare)", table_cell_style),
            Paragraph("<font color='#C53030'><b>MISSING</b></font>", table_cell_style),
            Paragraph("Day 45 scan data is recorded, but dedicated official 45-Day Scan PDF Certificate generator and UI button must be created.", table_cell_style)
        ],
        [
            Paragraph("<b>2</b>", table_cell_bold),
            Paragraph("<b>Due Date / Foaling Diary</b><br/>(20–100 Mares & PDF)", table_cell_style),
            Paragraph("<font color='#C53030'><b>MISSING</b></font>", table_cell_style),
            Paragraph("Centralized stud foaling calendar, paddock movement planner, and batch exportable PDF foaling diary need to be built.", table_cell_style)
        ],
        [
            Paragraph("<b>3</b>", table_cell_bold),
            Paragraph("<b>Dedicated Due Date Page</b><br/>('When is my foal due?')", table_cell_style),
            Paragraph("<font color='#B7791F'><b>CODE READY / PARTIAL</b></font>", table_cell_style),
            Paragraph("Calculation engine is 100% functional. Standalone prominent 'When is my foal due?' screen needs to be wired to drawer & dashboard.", table_cell_style)
        ],
        [
            Paragraph("<b>4</b>", table_cell_bold),
            Paragraph("<b>Twin Warning on Scan 1</b><br/>(Day 14–16 Alert & Re-scan)", table_cell_style),
            Paragraph("<font color='#C53030'><b>MISSING</b></font>", table_cell_style),
            Paragraph("Interactive twin detection toggle on Scan 1, prominent alert modal, and urgent re-scan schedule prompt must be added.", table_cell_style)
        ],
        [
            Paragraph("<b>5</b>", table_cell_bold),
            Paragraph("<b>Calendar + Diary Sync</b><br/>(Multi-module sync)", table_cell_style),
            Paragraph("<font color='#B7791F'><b>CODE READY / PARTIAL</b></font>", table_cell_style),
            Paragraph("Domain entities exist; system-wide date synchronization and device calendar integration need to be connected.", table_cell_style)
        ],
        [
            Paragraph("<b>6</b>", table_cell_bold),
            Paragraph("<b>Phone Functionality</b><br/>(Native Dialer & Fallback)", table_cell_style),
            Paragraph("<font color='#107E44'><b>IMPLEMENTED</b></font>", table_cell_style),
            Paragraph("AppPhoneLauncher is fully active with direct mobile dialer, clipboard fallback for non-mobile, and email composer.", table_cell_style)
        ],
        [
            Paragraph("<b>7</b>", table_cell_bold),
            Paragraph("<b>Congratulations Section</b><br/>(Celebratory Experience)", table_cell_style),
            Paragraph("<font color='#B7791F'><b>PARTIAL (NEEDS UPGRADE)</b></font>", table_cell_style),
            Paragraph("Screen and routing exist. Celebratory visual enhancements (confetti animations, sound/haptics, milestone badge) are required.", table_cell_style)
        ],
        [
            Paragraph("<b>8</b>", table_cell_bold),
            Paragraph("<b>ABP Branding</b><br/>(Brand Stamping & Seals)", table_cell_style),
            Paragraph("<font color='#B7791F'><b>PARTIAL (NEEDS UPGRADE)</b></font>", table_cell_style),
            Paragraph("Gold theme and logos exist. Consistent app-wide watermarks, header signatures, and certificate seals need enforcement.", table_cell_style)
        ],
        [
            Paragraph("<b>9</b>", table_cell_bold),
            Paragraph("<b>Payment Details Page</b><br/>(Pricing / Subscriptions)", table_cell_style),
            Paragraph("<font color='#C53030'><b>MISSING</b></font>", table_cell_style),
            Paragraph("Dedicated Payment Details / In-App Purchases / Subscription page needs to be created.", table_cell_style)
        ],
        [
            Paragraph("<b>10</b>", table_cell_bold),
            Paragraph("<b>FAQ Page</b><br/>(Client-Managed Q&A)", table_cell_style),
            Paragraph("<font color='#C53030'><b>MISSING</b></font>", table_cell_style),
            Paragraph("Searchable, expandable Frequently Asked Questions page needs to be added to navigation.", table_cell_style)
        ],
        [
            Paragraph("<b>11</b>", table_cell_bold),
            Paragraph("<b>Disclaimer</b><br/>(Global Legal Disclaimer)", table_cell_style),
            Paragraph("<font color='#B7791F'><b>PARTIAL (PENDING TEXT)</b></font>", table_cell_style),
            Paragraph("In-line disclaimers exist. A dedicated Global Legal Disclaimer page/popup is ready to embed client's finalized text.", table_cell_style)
        ],
        [
            Paragraph("<b>12</b>", table_cell_bold),
            Paragraph("<b>Final QA / Overall Flow</b><br/>(End-to-End Workflow)", table_cell_style),
            Paragraph("<font color='#B7791F'><b>PENDING NEW ITEMS</b></font>", table_cell_style),
            Paragraph("Full verification across Equine → Scans → 45d Cert → Diary → Congratulations will be finalized after new features are built.", table_cell_style)
        ],
    ]

    client_table = Table(client_items_data, colWidths=[18, 135, 95, 256])
    client_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOX', (0, 0), (-1, -1), 1, c_navy),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 3.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(client_table)
    story.append(Spacer(1, 10))

    # ----------------------------------------------------
    # SECTION 3: COMPLETE APP CAPABILITIES BREAKDOWN
    # ----------------------------------------------------
    story.append(PageBreak())
    story.append(Paragraph("3. Summary of Core Implemented Architecture", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceAfter=8, spaceBefore=0))

    story.append(Paragraph("<b>A. Authentication & Profile Engine</b>", h2_style))
    story.append(Paragraph("• Supabase Auth with secure session handling, auto-routing, and password reset deep links.", bullet_style))
    story.append(Paragraph("• Email verification screen with automatic poll-and-verify detection.", bullet_style))
    story.append(Paragraph("• Permanent Account Deletion with cascading record cleanup and safety warnings.", bullet_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>B. Multi-Species Registry & Interactive Markings</b>", h2_style))
    story.append(Paragraph("• 9 supported animal species with filterable directories and search.", bullet_style))
    story.append(Paragraph("• Interactive visual marking selector for face (Star, Stripe, Blaze) and legs (Sock, Stocking, Pastern).", bullet_style))
    story.append(Paragraph("• Integrated camera and gallery image capture for animal profile avatars.", bullet_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>C. Equine Gestation & Care Schedule Engine</b>", h2_style))
    story.append(Paragraph("• Exact gestation math according to Section 4 ABP rules (Natural 341d, Chilled 341d, Frozen 340d, ICSI/ET 332d).", bullet_style))
    story.append(Paragraph("• Biological dam vs. surrogate recipient mare tracking for embryo transfer programs.", bullet_style))
    story.append(Paragraph("• Preventative care schedules including Pneumabort-K (5, 7, 9m), deworming, and pre-foaling boosters.", bullet_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>D. Offspring Modules & Official PDF Certificates</b>", h2_style))
    story.append(Paragraph("• Foal registration with pedigree linking to dam, sire, and recipient mare.", bullet_style))
    story.append(Paragraph("• Canine module with dedicated daily/weekly Puppy Weight Growth Tracker.", bullet_style))
    story.append(Paragraph("• Vector PDF birth certificate generator for Foals and Puppies with direct printing and sharing.", bullet_style))
    story.append(Spacer(1, 8))

    # ----------------------------------------------------
    # SECTION 4: NEXT STAGE ACTION PLAN & EXECUTION ROADMAP
    # ----------------------------------------------------
    story.append(Paragraph("4. Next Stage Implementation Plan", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceAfter=6, spaceBefore=0))

    action_phases = [
        ("Phase 1: Milestone 3 Priority Features", [
            "Implement <b>45-Day Scan Certificate Generator</b> (PDF export & in-app viewer).",
            "Add <b>Interactive Twin Warning & Urgent Re-scan Workflow</b> to Scan 1.",
            "Create <b>Dedicated 'When is my Foal Due?' Page</b> accessible from Home/Drawer."
        ]),
        ("Phase 2: Stud Diary & Exportable Schedules", [
            "Build <b>Stud Foaling Diary Matrix</b> supporting 20–100 mares with paddock movement tags.",
            "Implement <b>Exportable Foaling Schedule PDF</b> for stud barn staff."
        ]),
        ("Phase 3: Visual Polish & Essential Pages", [
            "Upgrade <b>Congratulations Screen</b> with celebratory particle animations & sound/haptics.",
            "Enforce comprehensive <b>ABP Brand Watermarks & Seals</b> throughout screens and exports.",
            "Add <b>Payment Details Page</b>, <b>Interactive FAQ Page</b>, and <b>Global Legal Disclaimer</b>."
        ]),
        ("Phase 4: QA & Device Testing", [
            "Perform comprehensive multi-viewport testing across Android, iOS, and tablets.",
            "Validate dialer actions, PDF generation performance, and state persistence."
        ])
    ]

    for title_text, items in action_phases:
        story.append(Paragraph(f"<b>{title_text}</b>", h2_style))
        for itm in items:
            story.append(Paragraph(f"• {itm}", bullet_style))
        story.append(Spacer(1, 3))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Successfully generated updated PDF report at: {filename}")


if __name__ == '__main__':
    output_path = r"c:\projects\internship_2\animal_birthday_predictor\ABP_Feature_Analysis_Report.pdf"
    build_pdf(output_path)
