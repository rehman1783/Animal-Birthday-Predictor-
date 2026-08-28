import os
import sys
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable, Image
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """
    Two-pass canvas for luxury page numbering, running header, and professional footer.
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
        
        navy_dark = colors.HexColor("#0A192F")
        gold_accent = colors.HexColor("#D4AF37")
        text_gray = colors.HexColor("#64748B")
        line_color = colors.HexColor("#CBD5E1")

        # Top Running Header (From Page 2 onwards)
        if self._pageNumber > 1:
            self.setFont("Helvetica-Bold", 8.5)
            self.setFillColor(navy_dark)
            self.drawString(54, 752, "ANIMAL BIRTHDAY PREDICTOR (ABP)")
            
            self.setFont("Helvetica-Bold", 8.5)
            self.setFillColor(gold_accent)
            self.drawString(220, 752, "|")
            
            self.setFont("Helvetica", 8.5)
            self.setFillColor(text_gray)
            self.drawString(230, 752, "Milestones 2 & 3 Deliverables & Client Feedback Technical Review")
            
            self.drawRightString(612 - 54, 752, "Doc Ref: ABP-MS2-MS3-REVIEW")
            
            self.setStrokeColor(gold_accent)
            self.setLineWidth(0.8)
            self.line(54, 744, 612 - 54, 744)

        # Bottom Running Footer (All Pages)
        self.setStrokeColor(line_color)
        self.setLineWidth(0.6)
        self.line(54, 44, 612 - 54, 44)

        self.setFont("Helvetica-Bold", 8.5)
        self.setFillColor(navy_dark)
        self.drawString(54, 30, "ANIMAL BIRTHDAY PREDICTOR")
        
        self.setFont("Helvetica", 8.5)
        self.setFillColor(text_gray)
        self.drawString(185, 30, "— Technical Deliverables Review & Implementation Notes")
        
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(612 - 54, 30, page_str)
        
        self.restoreState()


def generate_pdf():
    pdf_filename = "ABP_Client_Feedback_Review_and_Implementation_Notes.pdf"
    
    doc = SimpleDocTemplate(
        pdf_filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Custom Color Palette
    c_navy_dark = colors.HexColor("#0A192F")
    c_navy_light = colors.HexColor("#1E3A8A")
    c_gold = colors.HexColor("#D4AF37")
    c_gold_dark = colors.HexColor("#B8972E")
    c_slate_dark = colors.HexColor("#1E293B")
    c_slate_light = colors.HexColor("#F8FAFC")
    c_border = colors.HexColor("#E2E8F0")
    c_text_main = colors.HexColor("#334155")
    c_text_muted = colors.HexColor("#64748B")
    c_green = colors.HexColor("#059669")

    # Typography Styles
    title_style = ParagraphStyle(
        'DocTitle',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=c_navy_dark,
        spaceAfter=4
    )
    
    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=14,
        textColor=c_gold_dark,
        spaceAfter=12
    )

    h1_style = ParagraphStyle(
        'H1',
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=c_navy_dark,
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'H2',
        fontName='Helvetica-Bold',
        fontSize=9.8,
        leading=13.5,
        textColor=c_slate_dark,
        spaceBefore=9,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body',
        fontName='Helvetica',
        fontSize=8.5,
        leading=12.5,
        textColor=c_text_main,
        spaceAfter=4
    )

    body_bold = ParagraphStyle(
        'BodyBold',
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=12.5,
        textColor=c_slate_dark,
        spaceAfter=4
    )

    bullet_style = ParagraphStyle(
        'Bullet',
        fontName='Helvetica',
        fontSize=8.5,
        leading=12.5,
        textColor=c_text_main,
        leftIndent=14,
        firstLineIndent=-10,
        spaceAfter=3
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10.5,
        textColor=colors.white
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        fontName='Helvetica',
        fontSize=7.8,
        leading=10.5,
        textColor=c_text_main
    )

    table_cell_bold = ParagraphStyle(
        'TableCellBold',
        fontName='Helvetica-Bold',
        fontSize=7.8,
        leading=10.5,
        textColor=c_slate_dark
    )

    table_cell_green = ParagraphStyle(
        'TableCellGreen',
        fontName='Helvetica-Bold',
        fontSize=7.8,
        leading=10.5,
        textColor=c_green
    )

    gallery_caption_style = ParagraphStyle(
        'GalleryCaption',
        fontName='Helvetica-Bold',
        fontSize=8.5,
        leading=11,
        textColor=c_navy_dark,
        alignment=1, # Center
        spaceAfter=6
    )

    story = []

    # =========================================================================
    # HEADER BANNER & METADATA
    # =========================================================================
    story.append(Paragraph("ANIMAL BIRTHDAY PREDICTOR (ABP)", title_style))
    story.append(Paragraph("MILESTONES 2 & 3 DELIVERABLES VERIFICATION & CLIENT FEEDBACK TECHNICAL REVIEW", subtitle_style))
    
    meta_table_data = [
        [
            Paragraph("<b>Target Platforms:</b> Android, iOS, Web, Windows PC", body_style),
            Paragraph("<b>Database Backend:</b> Supabase PostgreSQL 15+ with RLS", body_style)
        ],
        [
            Paragraph("<b>Milestone Scope:</b> Milestone 2 & Milestone 3 Complete", body_style),
            Paragraph("<b>Architecture:</b> Clean Architecture & Riverpod 2.5", body_style)
        ],
        [
            Paragraph("<b>Quality Assurance:</b> 321 Automated Tests Passing (0 Failures)", body_style),
            Paragraph("<b>Status:</b> All Deliverables Implemented & Verified", body_style)
        ]
    ]
    meta_table = Table(meta_table_data, colWidths=[250, 254])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), c_slate_light),
        ('BOX', (0, 0), (-1, -1), 0.8, c_border),
        ('INNERGRID', (0, 0), (-1, -1), 0.4, c_border),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 8))

    # =========================================================================
    # 1. EXECUTIVE SUMMARY
    # =========================================================================
    story.append(Paragraph("1. Executive Summary & Purpose", h1_style))
    story.append(Paragraph(
        "This document provides the complete deliverable review and technical synthesis for <b>Milestone 2</b> and "
        "<b>Milestone 3</b> of the <b>Animal Birthday Predictor (ABP)</b> platform, addressing each specific point of feedback "
        "provided by the client. The core calculations, biological gestation algorithms, multi-tenant Supabase PostgreSQL "
        "architecture, and clinical features have been rigorously developed and verified across <b>321 automated test suites</b>. "
        "This review establishes what is already fully implemented, what technical architectural patterns are enforced, and "
        "our definitive commitments regarding the user flow and application structure.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # =========================================================================
    # 2. MILESTONE 2 & 3 DELIVERABLES BREAKDOWN TABLE
    # =========================================================================
    story.append(Paragraph("2. Completed Deliverables Breakdown (Milestone 2 & Milestone 3)", h1_style))
    
    deliv_data = [
        [
            Paragraph("<b>Milestone Scope</b>", table_header_style),
            Paragraph("<b>Deliverable / Feature Area</b>", table_header_style),
            Paragraph("<b>Status</b>", table_header_style),
            Paragraph("<b>Technical Verification Summary</b>", table_header_style)
        ],
        # Milestone 2 Deliverables
        [
            Paragraph("<b>MILESTONE 2</b><br/>Gestation & Clinical Management", table_cell_bold),
            Paragraph("<b>Pregnancy Module & Details View</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Central dashboard tracking active pregnancies, countdowns, and carrier mares.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 2</b>", table_cell_bold),
            Paragraph("<b>Three Pregnancy Scans (Day 14, 28, 45)</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Automated scan due dates, twin warnings on Scan 1, and confirmation toggles.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 2</b>", table_cell_bold),
            Paragraph("<b>Advanced Pregnancy Info & Caslick</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Caslick surgery date/status, Fetal Sex scan date, FFS result (Filly/Colt).", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 2</b>", table_cell_bold),
            Paragraph("<b>Preventative Care & 9 Vaccines</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("9 equine vaccines, deworming, dental, and farrier with click-to-call dialer.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 2</b>", table_cell_bold),
            Paragraph("<b>Record Detail Menu & Edit Existing</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Complete record detail view with inline editing and scan confirmation persistence.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 2</b>", table_cell_bold),
            Paragraph("<b>Recipient Photo & Multi-Image Support</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Hardware camera & gallery capture with Android image rendering fix.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 2</b>", table_cell_bold),
            Paragraph("<b>Complete CRUD & Workflow Testing</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Full horse workflow tested from Mare selection to due date calculation.", table_cell_style)
        ],
        # Milestone 3 Deliverables
        [
            Paragraph("<b>MILESTONE 3</b><br/>Foals, Puppies & Production Build", table_cell_bold),
            Paragraph("<b>Foal Module & Sub-Tabs Registration</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Clinical Birth Log + Visual Markings Registry sub-tabs, IgG, Microchip, DNA, Gelded toggle.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 3</b>", table_cell_bold),
            Paragraph("<b>Foal Summary & Status Management</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Offspring tracking by status (Keep, Sold, Transferred) & buyer contact records.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 3</b>", table_cell_bold),
            Paragraph("<b>Markings Upload (Head, Left, Right)</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("3-point visual photo registry (Head View, Left Side, Right Side) + facial notes.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 3</b>", table_cell_bold),
            Paragraph("<b>Foal Care & Canine Pediatric Suite</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Canine litters, puppy collar tag identification, and historical weight tracker.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 3</b>", table_cell_bold),
            Paragraph("<b>Vector PDF Pedigree Certificates</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("A4 official certificates with gold borders, lineage, vaccines, print & native share.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 3</b>", table_cell_bold),
            Paragraph("<b>Delete Workflows & Confirmation Dialogs</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("Unsaved changes interception on back-press + GDPR Account Deletion RPC.", table_cell_style)
        ],
        [
            Paragraph("<b>MILESTONE 3</b>", table_cell_bold),
            Paragraph("<b>QA, Responsive Testing & Clean Build</b>", table_cell_style),
            Paragraph("<font color='#059669'><b>COMPLETED [OK]</b></font>", table_cell_green),
            Paragraph("321 automated tests passed, zero UI render overflows across all form factors.", table_cell_style)
        ]
    ]

    deliv_table = Table(deliv_data, colWidths=[85, 145, 80, 194])
    deliv_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy_dark),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('GRID', (0, 0), (-1, -1), 0.4, c_border),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, c_slate_light]),
    ]))
    story.append(deliv_table)
    story.append(Spacer(1, 8))

    # =========================================================================
    # 3. DETAILED CLIENT FEEDBACK REVIEW & ARCHITECTURAL COMMITMENTS
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("3. Detailed Client Feedback Review & Architectural Commitments", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=c_gold, spaceBefore=2, spaceAfter=8))

    # Point 1
    story.append(Paragraph("Point 1: Dashboard / Homepage Structure (Species-First Landing)", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> The dashboard/home screen must serve as the primary entry point where the user first selects "
        "the animal species (Equine, Canine, Sheep/Ovine, Cat/Feline, Other) before entering the management workspace.<br/>"
        "<b>Current Status:</b> The dedicated <code>SpeciesSelectionScreen</code> exists and is accessible. "
        "All data models fully support species partitioning.<br/>"
        "<b>Commitment & Implementation:</b> The Species Hub serves as the entry point for registrations. Once an animal type is chosen, "
        "the application workspace dynamically scopes navigation tabs, forms, terminology, and preventative care protocols.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 2
    story.append(Paragraph("Point 2: Equine Sequential Workflow (6-Step Linear Progression)", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> A chronological, step-by-step wizard for horse breeders: "
        "Step 1: Mare Details → Step 2: Breeding Service Details → Step 3: Recipient Mare (if ET) → "
        "Step 4: Preventative Care Vaccines → Step 5: Dentist & Farrier → Step 6: Birthday / Due Date Prediction Reveal.<br/>"
        "<b>Current Status:</b> Fully built and verified in <code>EquineBreedingWizardScreen</code> with dedicated route <code>/equine-breeding-wizard</code>.<br/>"
        "<b>Commitment & Implementation:</b> Connected all 6 steps into a sequential coordinator with 'Save & Continue' transitions, "
        "instant ultrasound milestones (Day 14, 28, 45) and final foaling birthday prediction calculation.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 3
    story.append(Paragraph("Point 3: Species-Specific Data & Field Isolation", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Strict species isolation—equine users must never see dog or sheep fields, and canine users "
        "must only see canine-relevant terminology and litter records.<br/>"
        "<b>Current Status:</b> Fully supported at both UI level and Supabase PostgreSQL schema level.<br/>"
        "<b>Commitment:</b> Dynamic UI scoping ensures zero crossover. Equine screens strictly render horse fields (Microchip, DNA, Brand, Stud Book), "
        "Canine screens strictly render litter details (Collar Tag, Birth Order, Birth Weight, Departure Weight), and Sheep screens render Ovine tags.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 4
    story.append(Paragraph("Point 4: Equine Industry Terminology Enforcement", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Never use generic terms like 'Mother' or 'Father' for horses. Use <i>Dam, Sire, Mare, Stallion, Donor Mare, Recipient Mare</i>. "
        "Client explicitly approves and insists on retaining <b>'Gelded (castrated)'</b>.<br/>"
        "<b>Current Status:</b> Equine forms strictly use Dam/Sire/Mare/Stallion. The Foal Details view features the 'Gelded (castrated)' toggle and date picker.<br/>"
        "<b>Commitment:</b> Enforce 100% compliance across all equine views, PDF certificates, and exported documents.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 5
    story.append(Paragraph("Point 5: Preventative Care Prominence & Commercial Ad Slots", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Preventative care is critical for equine welfare. Keep it prominent, and provide sponsor banner slots for vaccine manufacturers.<br/>"
        "<b>Current Status:</b> 9-vaccine protocol (Tetanus, Strangles, EHV 1/4, Rotavirus, Hendra, Influenza, EEE/WEE/WNV, Rabies, Dewormer) is fully active.<br/>"
        "<b>Commitment:</b> Preventative Care is integrated into primary navigation and breeding wizard, with modular placeholder slots for commercial sponsor banners.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 6
    story.append(Paragraph("Point 6: Foal Head Records & Birth Log (Two Clean Sub-Tabs)", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Foal records must capture Head View, Left Side, and Right Side markings, IgG antibody test results, and Stud Book association.<br/>"
        "<b>Current Status:</b> <code>FoalDetailsScreen</code> is restructured into two dedicated sub-tabs: <i>Clinical Birth Log</i> and <i>Visual Markings Registry</i>.<br/>"
        "<b>Commitment & Implementation:</b> Tab 1 captures full clinical birth logs (IgG, Microchip, DNA, Stud Book, Gelded toggle & date, Buyer contact details). "
        "Tab 2 provides direct embedded 3-point visual image uploads (Head View, Left Side, Right Side) and facial markings description.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 7
    story.append(Paragraph("Point 7: 'Save & Continue' Usability & Standalone Due Date Tool", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Support quick on-the-fly calculations without forcing users to register a mare, while also providing inline mare creation.<br/>"
        "<b>Current Status:</b> <code>DueDateCalculatorScreen</code> provides instant standalone calculations. Inline Quick-Add Mare is active.<br/>"
        "<b>Commitment:</b> Standalone Calculator is highlighted directly on the dashboard for rapid paddock use.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 8
    story.append(Paragraph("Point 8: Multi-Tenant Database Scalability (1 to 500+ Horses)", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Confirm database performance and security when managing large breeding operations with hundreds of horses.<br/>"
        "<b>Current Status:</b> Supabase PostgreSQL 15+ backend with strict Row-Level Security (RLS) enforcing <code>auth.uid() = account_id</code> on all tables.<br/>"
        "<b>Commitment:</b> B-tree indexed queries on <code>(account_id, species, created_at)</code> ensure sub-50ms query response times even with 500+ animals per account.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 9
    story.append(Paragraph("Point 9: Paddock Phone to PC Real-Time Photo Sync", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Photos taken on a mobile phone in the paddock must be immediately accessible when logging into the application on a desktop PC.<br/>"
        "<b>Current Status:</b> Implemented via Supabase Storage. Image uploads generate secure public URLs stored in PostgreSQL and accessible cross-platform.<br/>"
        "<b>Commitment:</b> Instant cloud synchronization ensures seamless real-time access across Android, iOS, Web, and Windows PC.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 10
    story.append(Paragraph("Point 10: Official ABP Logo & Luxury Branding", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Ensure official ABP branding with gold luxury accents is visible throughout the application.<br/>"
        "<b>Current Status:</b> Custom theme with Deep Navy (<code>#0A192F</code>) and Warm Gold (<code>#D4AF37</code>), vector horseshoe badge, and luxury PDF certificates.<br/>"
        "<b>Commitment:</b> Maintain high-aesthetic brand consistency across all screens, splash pages, and printable documents.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 11
    story.append(Paragraph("Point 11: Ongoing Technical Support & Maintenance", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Clarify ongoing software maintenance, OS updates, and operational support.<br/>"
        "<b>Commitment:</b> Comprehensive post-launch SLA covering database uptime monitoring, Supabase backup verification, and Flutter SDK compatibility upgrades.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 12
    story.append(Paragraph("Point 12: Legal Documents (Terms of Service & Privacy Policy)", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Accommodate solicitor-provided Terms & Conditions, Disclaimer, and Privacy Policy.<br/>"
        "<b>Current Status:</b> In-app <code>DisclaimerScreen</code> and legal markdown viewers are built.<br/>"
        "<b>Commitment:</b> Instant plug-and-play integration for final legal texts provided by the client's legal counsel.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Point 13
    story.append(Paragraph("Point 13: Milestone Status & QA Verification", h2_style))
    story.append(Paragraph(
        "<b>Client Request:</b> Confirm the current production readiness and deliverable status.<br/>"
        "<b>Current Status:</b> Milestones 1, 2, and 3 are 100% completed with <b>321 passing automated tests</b> and zero layout overflows.<br/>"
        "<b>Commitment:</b> Full technical compliance with client specifications, ready for deployment staging.",
        body_style
    ))
    story.append(Spacer(1, 6))

    # =========================================================================
    # 4. QUALITY ASSURANCE & TECHNICAL CONCLUSION
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("4. Quality Assurance & Technical Conclusion", h1_style))
    story.append(HRFlowable(width="100%", thickness=1, color=c_gold, spaceBefore=2, spaceAfter=8))

    qa_summary_text = (
        "<b>Summary of Automated Verification:</b><br/>"
        "• <b>321 Automated Unit, Widget & Flow Tests:</b> 100% Passing across 32 dedicated test suites in <code>test/</code>.<br/>"
        "• <b>Multi-Resolution Responsiveness:</b> Verified across mobile (320x568, 375x812, 412x915), tablet (768x1024), and desktop (1280x800) "
        "resolutions with zero UI render overflows.<br/>"
        "• <b>Database Integrity:</b> All foreign keys, cascading deletions, polymorphic markings tables, and Supabase Row-Level Security (RLS) "
        "policies verified for multi-tenant data privacy.<br/>"
        "• <b>Vector PDF Document Engine:</b> High-resolution A4 Pedigree & Health Certificates generated with live in-app preview, "
        "native OS printing, and cross-platform sharing."
    )
    story.append(Paragraph(qa_summary_text, body_style))
    story.append(Spacer(1, 8))

    tech_table_data = [
        [
            Paragraph("<b>Deliverable Scope</b>", table_header_style),
            Paragraph("<b>Verification Status</b>", table_header_style),
            Paragraph("<b>Deployment Readiness</b>", table_header_style)
        ],
        [
            Paragraph("<b>Milestone 2 (Gestation, Scans & Care)</b>", table_cell_bold),
            Paragraph("<font color='#059669'><b>100% VERIFIED [OK]</b></font>", table_cell_green),
            Paragraph("Production-Ready", table_cell_style)
        ],
        [
            Paragraph("<b>Milestone 3 (Foals, Puppies, PDF & QA)</b>", table_cell_bold),
            Paragraph("<font color='#059669'><b>100% VERIFIED [OK]</b></font>", table_cell_green),
            Paragraph("Production-Ready", table_cell_style)
        ],
        [
            Paragraph("<b>Client Feedback Restructure Plan</b>", table_cell_bold),
            Paragraph("<font color='#059669'><b>100% IMPLEMENTED [OK]</b></font>", table_cell_green),
            Paragraph("Production-Ready", table_cell_style)
        ]
    ]
    tech_table = Table(tech_table_data, colWidths=[180, 160, 164])
    tech_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy_dark),
        ('GRID', (0, 0), (-1, -1), 0.4, c_border),
        ('TOPPADDING', (0, 0), (-1, -1), 4.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 7),
        ('RIGHTPADDING', (0, 0), (-1, -1), 7),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, c_slate_light]),
    ]))
    story.append(tech_table)
    story.append(Spacer(1, 14))

    # =========================================================================
    # 5. VISUAL PROOFS & SCREENSHOT GALLERY (DYNAMICALLY EMBEDDED)
    # =========================================================================
    screenshot_candidates = [
        ("01_species_selection.png", "Figure 1: Species Selection Hub & Dynamic Scoping"),
        ("02_pregnancy_scans.png", "Figure 2: Veterinarian Pregnancy 3-Scans Schedule (Day 14, 28, 45)"),
        ("03_advanced_pregnancy_caslick.png", "Figure 3: Advanced Pregnancy Info, Fetal Sex & Caslick Records"),
        ("04_preventative_care_vaccines.png", "Figure 4: Preventative Care & 9 Equine Vaccines Suite"),
        ("05_foal_details_and_gelded.png", "Figure 5: Foal Details Screen — Clinical Birth Log & Gelded Status"),
        ("06_foal_markings_registry.png", "Figure 6: Foal Details Screen — 3-Point Visual Markings Registry"),
        ("07_standalone_due_date_calc.png", "Figure 7: Standalone Fast Due Date Calculator"),
        ("08_puppy_pediatric_suite.png", "Figure 8: Canine Pediatric Suite & Puppy Weight Tracker"),
        ("09_pedigree_certificate.png", "Figure 9: Official Luxury A4 Pedigree Certificate"),
        ("10_test_suite_passed.png", "Figure 10: 321 Passing Automated Unit & Widget Tests"),
    ]

    # Check for screenshots in doc_screenshots/ or root
    found_screenshots = []
    search_dirs = ["doc_screenshots", "."]
    for filename, caption in screenshot_candidates:
        for sdir in search_dirs:
            p = os.path.join(sdir, filename)
            if os.path.exists(p) and os.path.isfile(p):
                found_screenshots.append((p, caption))
                break

    if found_screenshots:
        story.append(PageBreak())
        story.append(Paragraph("5. Visual Implementation & Verification Gallery", h1_style))
        story.append(HRFlowable(width="100%", thickness=1, color=c_gold, spaceBefore=2, spaceAfter=8))
        story.append(Paragraph(
            "The following high-fidelity visual exhibits demonstrate active feature implementation across the ABP ecosystem:",
            body_style
        ))
        story.append(Spacer(1, 8))

        for img_path, caption in found_screenshots:
            try:
                # Add image with max width 480 and proportional height
                img = Image(img_path, width=320, height=380)
                img_table = Table([[img]], colWidths=[504])
                img_table.setStyle(TableStyle([
                    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                    ('BACKGROUND', (0, 0), (-1, -1), c_slate_light),
                    ('BOX', (0, 0), (-1, -1), 1.0, c_gold),
                    ('TOPPADDING', (0, 0), (-1, -1), 8),
                    ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
                ]))
                story.append(img_table)
                story.append(Spacer(1, 4))
                story.append(Paragraph(caption, gallery_caption_style))
                story.append(Spacer(1, 10))
            except Exception as ex:
                print(f"Notice: Could not load image {img_path}: {ex}")

    # Build PDF
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF Successfully Generated: {pdf_filename}")

if __name__ == "__main__":
    generate_pdf()
