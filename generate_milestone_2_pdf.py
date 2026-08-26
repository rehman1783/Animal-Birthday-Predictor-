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
    Two-pass canvas for page numbering, branded header and footer.
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
            self.drawRightString(612 - 54, 752, "Milestone 2 Deliverables & Progress Report")
            
            self.setStrokeColor(line_color)
            self.setLineWidth(0.6)
            self.line(54, 744, 612 - 54, 744)

        # Bottom Running Footer (All pages)
        self.setStrokeColor(line_color)
        self.setLineWidth(0.6)
        self.line(54, 44, 612 - 54, 44)

        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(primary_gold)
        self.drawString(54, 31, "ABP Milestone 2 Deliverable Documentation")

        self.setFont("Helvetica", 8)
        self.setFillColor(text_gray)
        self.drawRightString(612 - 54, 31, f"Page {self._pageNumber} of {page_count}")
        
        self.restoreState()


def build_milestone_2_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Colors
    c_navy = colors.HexColor("#0D1B2A")
    c_navy_light = colors.HexColor("#1E3A8A")
    c_gold = colors.HexColor("#B8860B")
    c_gold_banner = colors.HexColor("#FDF8ED")
    c_gold_border = colors.HexColor("#EAD7A1")
    c_text_dark = colors.HexColor("#1E293B")
    c_text_muted = colors.HexColor("#64748B")
    c_green_text = colors.HexColor("#107E44")

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
        spaceAfter=10
    )

    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11.5,
        leading=15,
        textColor=c_navy,
        spaceBefore=10,
        spaceAfter=5,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'SectionH2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13,
        textColor=c_navy_light,
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
        spaceAfter=2.5
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
    # HEADER BANNER & METADATA
    # ----------------------------------------------------
    story.append(Paragraph("ANIMAL BIRTHDAY PREDICTOR (ABP)", title_style))
    story.append(Paragraph("MILESTONE 2: DELIVERABLES & TECHNICAL PROGRESS REPORT", subtitle_style))

    meta_table_data = [
        [
            Paragraph("<b>Project:</b> Animal Birthday Predictor Mobile App", body_style),
            Paragraph("<b>Milestone Start Date:</b> 20 August 2026", body_style),
        ],
        [
            Paragraph("<b>Milestone Scope:</b> Equine Pregnancy, Scans & Care Module", body_style),
            Paragraph("<b>Milestone Status:</b> <font color='#107E44'><b>100% COMPLETED (21/21 Deliverables)</b></font>", body_style),
        ]
    ]
    meta_table = Table(meta_table_data, colWidths=[250, 254])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), c_gold_banner),
        ('BOX', (0, 0), (-1, -1), 1, c_gold),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, c_gold_border),
        ('TOPPADDING', (0, 0), (-1, -1), 4.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 8))

    story.append(Paragraph("<b>Milestone Executive Summary:</b> Milestone 2 encompassed the complete architecture, implementation, database synchronization, and end-to-end testing of the <b>Equine Pregnancy & Gestation Engine</b>, <b>Ultrasound Scans Module</b>, <b>Preventative Care Protocol</b>, <b>Recipient Mare Workflow</b>, and <b>Native Mobile Utilities</b>. All 21 specified deliverables have been successfully implemented and verified.", body_style))
    story.append(Spacer(1, 6))

    # ----------------------------------------------------
    # SECTION 1: DELIVERABLES CHECKLIST TABLE (ALL 21 ITEMS)
    # ----------------------------------------------------
    story.append(Paragraph("1. Milestone 2 Deliverables Checklist & Technical Notes", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceAfter=5, spaceBefore=0))

    deliverables_data = [
        [
            Paragraph("<b>#</b>", table_header_style),
            Paragraph("<b>Deliverable</b>", table_header_style),
            Paragraph("<b>Status</b>", table_header_style),
            Paragraph("<b>Implementation Details & Technical Notes</b>", table_header_style)
        ],
        [
            Paragraph("1", table_cell_bold),
            Paragraph("<b>Pregnancy Module</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Full equine gestation module supporting Natural, Chilled Semen, Frozen Semen, & ICSI/Embryo Transfer.", table_cell_style)
        ],
        [
            Paragraph("2", table_cell_bold),
            Paragraph("<b>Pregnancy Details</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Live circular progress ring, remaining days countdown, and trimester breakdown indicator.", table_cell_style)
        ],
        [
            Paragraph("3", table_cell_bold),
            Paragraph("<b>Three Pregnancy Scans</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Automated scheduling and tracking for Scan 1 (14–16d), Scan 2 (30d Heartbeat), and Scan 3 (45d Organogenesis).", table_cell_style)
        ],
        [
            Paragraph("4", table_cell_bold),
            Paragraph("<b>Advanced Pregnancy Info</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Biological milestone timeline detailing embryonic development, physiological changes, and care tips.", table_cell_style)
        ],
        [
            Paragraph("5", table_cell_bold),
            Paragraph("<b>Caslick Information</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Dedicated Caslick procedure tracking, surgical history logging, and pre-foaling opening reminders.", table_cell_style)
        ],
        [
            Paragraph("6", table_cell_bold),
            Paragraph("<b>Fetal Sex</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Fetal gender recording (Colt, Filly, Unknown) captured and persisted during veterinary ultrasound scans.", table_cell_style)
        ],
        [
            Paragraph("7", table_cell_bold),
            Paragraph("<b>Preventative Care</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Comprehensive preventative health manager for mares, foals, and canines with historical logs and reminders.", table_cell_style)
        ],
        [
            Paragraph("8", table_cell_bold),
            Paragraph("<b>Vaccination Module</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Equine vaccine scheduler: Pneumabort-K at 5, 7, 9 months; Tetanus/Flu boosters at 10 months; Deworming cycles.", table_cell_style)
        ],
        [
            Paragraph("9", table_cell_bold),
            Paragraph("<b>Dentist Records</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Equine dental checkup logging, tooth floating records, veterinarian notes, and recurring exam alerts.", table_cell_style)
        ],
        [
            Paragraph("10", table_cell_bold),
            Paragraph("<b>Farrier Records</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Hoof trimming, corrective shoeing log, practitioner details, and 6–8 week recurring care schedule.", table_cell_style)
        ],
        [
            Paragraph("11", table_cell_bold),
            Paragraph("<b>Phone Dial Integration</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("AppPhoneLauncher integrated with native telephone dialer (`tel:`) and non-mobile clipboard fallback.", table_cell_style)
        ],
        [
            Paragraph("12", table_cell_bold),
            Paragraph("<b>Record Detail Menu</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Contextual bottom sheets and popup menus for quick actions (Edit, View Profile, Log Scan, Add Care).", table_cell_style)
        ],
        [
            Paragraph("13", table_cell_bold),
            Paragraph("<b>Complete Record Detail View</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Consolidated mare/foal profile screen displaying pedigree, chip ID, breeding history, scans, and care timeline.", table_cell_style)
        ],
        [
            Paragraph("14", table_cell_bold),
            Paragraph("<b>Edit Existing Records</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Full update capability across animal profiles, breeding entries, dates, and medical notes.", table_cell_style)
        ],
        [
            Paragraph("15", table_cell_bold),
            Paragraph("<b>Pregnancy Scan Editing</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Real-time editing of scan dates, confirmation toggles, ultrasound attachments, and vet comments.", table_cell_style)
        ],
        [
            Paragraph("16", table_cell_bold),
            Paragraph("<b>Persist Scan Confirmations</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Permanent database persistence for Scans 1, 2, and 3 confirmation flags across application lifecycles.", table_cell_style)
        ],
        [
            Paragraph("17", table_cell_bold),
            Paragraph("<b>Recipient Photo Saving</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Dedicated photo capture and cloud/local storage integration for recipient/surrogate mares.", table_cell_style)
        ],
        [
            Paragraph("18", table_cell_bold),
            Paragraph("<b>Android Image Rendering Fix</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Resolved memory handling and aspect ratio rendering issues for camera/gallery image previews on Android.", table_cell_style)
        ],
        [
            Paragraph("19", table_cell_bold),
            Paragraph("<b>Multiple Images Support</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Multi-photo management for animal avatars, ultrasound scans, and identification markings.", table_cell_style)
        ],
        [
            Paragraph("20", table_cell_bold),
            Paragraph("<b>Complete CRUD Operations</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("Full Create, Read, Update, and Delete operations verified across Animals, Pregnancies, Logs, & Contacts.", table_cell_style)
        ],
        [
            Paragraph("21", table_cell_bold),
            Paragraph("<b>Testing of Horse Workflow</b>", table_cell_bold),
            Paragraph("<font color='#107E44'><b>DONE (✅)</b></font>", table_cell_style),
            Paragraph("End-to-end verification of complete equine breeding lifecycle on live device environments.", table_cell_style)
        ],
    ]

    deliv_table = Table(deliverables_data, colWidths=[15, 120, 65, 304])
    deliv_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('BOX', (0, 0), (-1, -1), 1, c_navy),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(deliv_table)
    story.append(Spacer(1, 10))

    # ----------------------------------------------------
    # SECTION 2: DEEP TECHNICAL BREAKDOWN
    # ----------------------------------------------------
    story.append(PageBreak())
    story.append(Paragraph("2. Deep Technical Breakdown by Architecture Layer", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceAfter=8, spaceBefore=0))

    story.append(Paragraph("<b>A. Equine Breeding & Calculation Engine</b>", h2_style))
    story.append(Paragraph("• <b>Mathematical Precision:</b> Implemented exact equine gestation periods based on ABP Section 4 specifications: Natural Cover (341 days), Chilled Semen (341 days), Frozen Semen (340 days), and ICSI / Embryo Transfer (332 days from transfer date / 340 days from donor ovulation).", bullet_style))
    story.append(Paragraph("• <b>Dual Mare Architecture:</b> Fully segregated genetic Dam from Recipient/Surrogate Mare to ensure accurate pedigree recording while calculating gestation milestones against the recipient's transfer dates.", bullet_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>B. Ultrasound Scans & Milestone Persistence</b>", h2_style))
    story.append(Paragraph("• <b>Scan 1 (Day 14–16):</b> Confirms embryonic vesicle and detects twins prior to fixation.", bullet_style))
    story.append(Paragraph("• <b>Scan 2 (Day 30):</b> Confirms positive heartbeat and checks viability.", bullet_style))
    story.append(Paragraph("• <b>Scan 3 (Day 45):</b> Verifies complete organogenesis and endometrial cup formation before wintering.", bullet_style))
    story.append(Paragraph("• <b>Data Persistence:</b> Confirmation toggles, scan images, attending vet notes, and fetal sex entries persist permanently in Supabase database tables.", bullet_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>C. Preventative Care & Health Management</b>", h2_style))
    story.append(Paragraph("• <b>Vaccination Protocol:</b> Automated tracking of critical anti-abortion vaccines (Pneumabort-K at months 5, 7, and 9) and pre-foaling passive immunity booster (Tetanus/Flu at month 10).", bullet_style))
    story.append(Paragraph("• <b>Dental & Hoof Care:</b> Historical logging and 6–8 week recurring alerts for Farrier trims and Equine Dentist floating.", bullet_style))
    story.append(Paragraph("• <b>Caslick Surgery Tracker:</b> Flagging mares with Caslick sutures with opening alerts 2–4 weeks prior to expected foaling.", bullet_style))
    story.append(Spacer(1, 4))

    story.append(Paragraph("<b>D. Mobile Device & Platform Optimizations</b>", h2_style))
    story.append(Paragraph("• <b>Android Image Rendering Fix:</b> Implemented downsampling and caching handlers to prevent out-of-memory crashes on Android devices when taking high-res camera photos.", bullet_style))
    story.append(Paragraph("• <b>AppPhoneLauncher:</b> One-touch native telephone dialer (`tel:`) and email composer (`mailto:`) with clipboard fallback for devices without cellular capabilities.", bullet_style))
    story.append(Paragraph("• <b>Full CRUD Interface:</b> Contextual bottom sheets and edit screens enabling full record management.", bullet_style))
    story.append(Spacer(1, 10))

    # ----------------------------------------------------
    # SECTION 3: MILESTONE SIGN-OFF BOX
    # ----------------------------------------------------
    signoff_data = [
        [
            Paragraph("<b>MILESTONE 2 COMPLETION SIGN-OFF</b>", ParagraphStyle('SignTitle', parent=styles['Normal'], fontName='Helvetica-Bold', fontSize=9, textColor=c_navy)),
        ],
        [
            Paragraph("<b>Scope Status:</b> All 21 Deliverables built, integrated, and verified.<br/>"
                      "<b>Code Quality:</b> Dart static analysis passed with zero errors.<br/>"
                      "<b>Ready For:</b> Stage 3 / Milestone 3 (45-Day Scan Certificates, Stud Foaling Diary, Twin Warnings & Advanced Celebratory UI).", body_style)
        ]
    ]
    signoff_table = Table(signoff_data, colWidths=[504])
    signoff_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F0FDF4")),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#107E44")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    story.append(signoff_table)

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Successfully generated dedicated Milestone 2 PDF at: {filename}")


if __name__ == '__main__':
    output_path = r"c:\projects\internship_2\animal_birthday_predictor\ABP_Milestone_2_Report.pdf"
    build_milestone_2_pdf(output_path)
