import os
import sys
from PIL import Image as PILImage
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable, Image
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
        
        primary_gold = colors.HexColor("#D4AF37")
        navy_dark = colors.HexColor("#0A192F")
        text_gray = colors.HexColor("#64748B")
        line_color = colors.HexColor("#CBD5E1")

        # Top Running Header (From Page 2 onwards)
        if self._pageNumber > 1:
            self.setFont("Helvetica-Bold", 8.5)
            self.setFillColor(navy_dark)
            self.drawString(54, 752, "ANIMAL BIRTHDAY PREDICTOR (ABP)")
            
            self.setFont("Helvetica-Bold", 8.5)
            self.setFillColor(primary_gold)
            self.drawString(220, 752, "|")
            
            self.setFont("Helvetica", 8.5)
            self.setFillColor(text_gray)
            self.drawString(230, 752, "Milestone 3 Final Deliverables & Production Architecture Report")
            
            self.drawRightString(612 - 54, 752, "Doc Ref: ABP-MS3-FINAL")
            
            self.setStrokeColor(primary_gold)
            self.setLineWidth(0.8)
            self.line(54, 744, 612 - 54, 744)

        # Bottom Running Footer (All pages)
        self.setStrokeColor(line_color)
        self.setLineWidth(0.6)
        self.line(54, 44, 612 - 54, 44)

        self.setFont("Helvetica-Bold", 8.5)
        self.setFillColor(navy_dark)
        self.drawString(54, 30, "ANIMAL BIRTHDAY PREDICTOR")

        self.setFont("Helvetica", 8.5)
        self.setFillColor(text_gray)
        self.drawString(185, 30, "— Milestone 3: 6-Step Wizard, Foal/Puppy Suites, PDF Engine & QA")

        self.drawRightString(612 - 54, 30, f"Page {self._pageNumber} of {page_count}")
        
        self.restoreState()


def create_screenshot_card(img_path, title, subtitle, badge="MS3 VERIFIED", width=230, max_height=295):
    gold = colors.HexColor("#D4AF37")
    slate_dark = colors.HexColor("#0A192F")
    slate_bg = colors.HexColor("#F8FAFC")
    text_muted = colors.HexColor("#64748B")

    with PILImage.open(img_path) as pimg:
        orig_w, orig_h = pimg.size
        aspect = orig_h / orig_w
        calc_w = width
        calc_h = calc_w * aspect
        if calc_h > max_height:
            calc_h = max_height
            calc_w = calc_h / aspect
        
        rl_img = Image(img_path, width=calc_w, height=calc_h)

    title_p = Paragraph(f"<b>{title}</b>", ParagraphStyle(
        'CardTitle', fontName='Helvetica-Bold', fontSize=8.5, leading=11, textColor=slate_dark
    ))
    subtitle_p = Paragraph(f"<font color='#64748B'>{subtitle}</font>", ParagraphStyle(
        'CardSubtitle', fontName='Helvetica', fontSize=7.5, leading=9.5, textColor=text_muted
    ))
    badge_p = Paragraph(f"<font color='#059669'><b>[{badge}]</b></font>", ParagraphStyle(
        'CardBadge', fontName='Helvetica-Bold', fontSize=7.5, leading=9.5, alignment=2
    ))

    header_table = Table([[title_p, badge_p]], colWidths=[width - 70, 70])
    header_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('TOPPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))

    card_content = [
        header_table,
        subtitle_p,
        Spacer(1, 4),
        rl_img
    ]

    card_table = Table([[card_content]], colWidths=[width + 12])
    card_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), slate_bg),
        ('BOX', (0, 0), (-1, -1), 0.8, gold),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    return card_table


def build_milestone_3_pdf(filename="ABP_Milestone_3_Report.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    c_navy_dark = colors.HexColor("#0A192F")
    c_navy_light = colors.HexColor("#1E3A8A")
    c_gold = colors.HexColor("#D4AF37")
    c_gold_dark = colors.HexColor("#B8972E")
    c_slate_light = colors.HexColor("#F8FAFC")
    c_border = colors.HexColor("#E2E8F0")
    c_text_main = colors.HexColor("#334155")
    c_green = colors.HexColor("#059669")

    title_style = ParagraphStyle(
        'CoverTitle',
        fontName='Helvetica-Bold',
        fontSize=20,
        leading=24,
        textColor=c_navy_dark,
        spaceAfter=4
    )
    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        fontName='Helvetica',
        fontSize=10.5,
        leading=14,
        textColor=c_gold_dark,
        spaceAfter=10
    )
    h1_style = ParagraphStyle(
        'SectionH1',
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=c_navy_dark,
        spaceBefore=14,
        spaceAfter=6,
        keepWithNext=True
    )
    h2_style = ParagraphStyle(
        'SectionH2',
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=13,
        textColor=c_navy_light,
        spaceBefore=10,
        spaceAfter=4,
        keepWithNext=True
    )
    body_style = ParagraphStyle(
        'BodyDark',
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=c_text_main,
        spaceAfter=5
    )
    table_header_style = ParagraphStyle(
        'TableHeader',
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.white
    )
    table_cell_style = ParagraphStyle(
        'TableCell',
        fontName='Helvetica',
        fontSize=7.5,
        leading=10,
        textColor=c_text_main
    )
    table_cell_bold = ParagraphStyle(
        'TableCellBold',
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=10,
        textColor=c_navy_dark
    )
    table_cell_green = ParagraphStyle(
        'TableCellGreen',
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=10,
        textColor=c_green
    )

    story = []

    # Cover Header
    header_table_data = [
        [
            Paragraph("<b>ANIMAL BIRTHDAY PREDICTOR (ABP)</b>", title_style),
            Paragraph("<b>MILESTONE 3 DELIVERABLES</b><br/>Production Release Report", ParagraphStyle('MetaRight', fontName='Helvetica', fontSize=7.5, leading=10, alignment=2, textColor=c_navy_dark))
        ],
        [
            Paragraph("6-Step Wizard, Foal & Puppy Suites, PDF Engine, Due Date Tools & QA Suite", subtitle_style),
            Paragraph("<b>Status:</b> <font color='#059669'><b>100% COMPLETED</b></font><br/><b>QA Suite:</b> 321 / 321 Tests Passed", ParagraphStyle('MetaRightSub', fontName='Helvetica', fontSize=7.5, leading=10, alignment=2, textColor=c_text_main))
        ]
    ]
    header_table = Table(header_table_data, colWidths=[340, 164])
    header_table.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
        ('TOPPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(header_table)
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceBefore=4, spaceAfter=10))

    # Executive Overview
    story.append(Paragraph("1. Milestone 3 Deliverables & Scope Summary", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=6))
    story.append(Paragraph(
        "Milestone 3 represents the complete production maturation of the Animal Birthday Predictor. It expands the platform with an interactive 6-Step Equine Breeding Wizard, full Equine Foal & Canine Puppy pediatric management, multi-role Contacts Directory (Vets, Farriers, Dentists, Buyers), Stud Foaling Diary, Standalone Due Date Calculator, Luxury PDF Certificate Engine, Celebratory 1-2-3 Foaling Guidance, Knowledge Base / FAQs, and a comprehensive 321-test automated QA test suite.",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Summary Table
    ms3_table_data = [
        [
            Paragraph("<b>Feature Component</b>", table_header_style),
            Paragraph("<b>Architecture & Production Deliverable</b>", table_header_style),
            Paragraph("<b>Status</b>", table_header_style)
        ],
        [
            Paragraph("<b>6-Step Equine Breeding Wizard</b>", table_cell_bold),
            Paragraph("Sequential guided wizard: Donor Mare, Stallion/Cover Date, Recipient Carrier, Vaccines/Care, Emergency Contacts, and Due Date calculation.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Foal Management & Birth Log</b>", table_cell_bold),
            Paragraph("Foal registration, gelded/filly/colt categorization, buyer records, sold status, and 3-point markings registry.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Canine Puppy Pediatric Suite</b>", table_cell_bold),
            Paragraph("Puppy registration, microchip, buyer info, weight charts, and 11-step health schedule tracking dual Date Given & Date Due pairs.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Contacts Directory & Emergency Roles</b>", table_cell_bold),
            Paragraph("Specialized contact registry with categorized tabs (Vets, Farriers, Dentists, Buyers) and direct phone/email launchers.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Stud Foaling Diary & Due Date Calculator</b>", table_cell_bold),
            Paragraph("Broodmare movement tracking, overdue alerts, and fast multi-species calculation with timeline visualization.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>PDF Certificate & Document Engine</b>", table_cell_bold),
            Paragraph("Vectorized luxury Pedigree Certificate and printable Stud Foaling Diary PDF generator.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Celebration Screen (1-2-3 Foaling Rule)</b>", table_cell_bold),
            Paragraph("Arrival celebration screen with golden crest and critical first-hours veterinary guideline (Standing, Nursing, Placenta passing).", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Comprehensive QA & Test Suite</b>", table_cell_bold),
            Paragraph("321 Automated unit, widget, and integration tests ensuring zero regressions, zero layout overflows, and robust security.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK (321/321)</b></font>", table_cell_green)
        ]
    ]
    ms3_table = Table(ms3_table_data, colWidths=[150, 260, 94])
    ms3_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy_dark),
        ('GRID', (0, 0), (-1, -1), 0.4, c_border),
        ('TOPPADDING', (0, 0), (-1, -1), 3.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3.5),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, c_slate_light]),
    ]))
    story.append(ms3_table)
    story.append(Spacer(1, 10))

    # Technical Details
    story.append(Paragraph("2. Technical Highlights & Quality Assurance", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=6))
    story.append(Paragraph(
        "<b>A. Dual-Date Canine Health Model:</b> Implemented explicit tracking of both <code>date_given</code> and <code>date_due</code> for each pediatric milestone (Worming at 2, 4, 6, 8 wks; Core Vaccinations at 6-8, 10-12, 14-16 wks; Vet checks and Microchip), ensuring full transparency for puppy buyers.",
        body_style
    ))
    story.append(Paragraph(
        "<b>B. Client-Side PDF Generation:</b> Powered by Dart <code>pdf</code> & <code>printing</code> libraries, generating high-DPI printable documents with custom typography, brand crests, and dynamic QR codes client-side with 0 network latency.",
        body_style
    ))
    story.append(Paragraph(
        "<b>C. 321-Test Automated Verification:</b> Comprehensive testing across unit models, database repositories, RLS security isolation, responsive screen layouts (320px mobile to 1280px desktop), and dirty-form unsaved changes detection.",
        body_style
    ))
    story.append(Spacer(1, 10))

    # Visual Exhibits
    story.append(PageBreak())
    story.append(Paragraph("3. Milestone 3 Visual Implementation Exhibits", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.2, color=c_gold, spaceBefore=2, spaceAfter=8))
    story.append(Paragraph(
        "The following gallery showcases unaltered visual evidence demonstrating all Milestone 3 capabilities across the ABP platform:",
        body_style
    ))
    story.append(Spacer(1, 6))

    ms3_visuals = [
        ("Equine Wizard — Step 1: Donor Mare Registry", "Selecting Donor Mare from User Registry", "WIZARD S1", "WhatsApp Image 2026-08-28 at 1.15.49 PM (2).jpeg"),
        ("Equine Wizard — Step 1: Live Mare Selection", "Interactive radio selection with microchip data", "WIZARD S1", "WhatsApp Image 2026-08-28 at 1.15.49 PM.jpeg"),
        ("Equine Wizard — Step 2: Breeding Record & Sire", "Cover date, Stallion info & Insemination method", "WIZARD S2", "WhatsApp Image 2026-08-28 at 1.15.49 PM (1).jpeg"),
        ("Equine Wizard — Step 3: Recipient Mare (ET)", "Embryo transfer carrier designation", "WIZARD S3", "WhatsApp Image 2026-08-28 at 1.15.48 PM (1).jpeg"),
        ("Equine Wizard — Step 4: Preventative Care", "Equine gestational vaccine protocols & dewomer", "WIZARD S4", "WhatsApp Image 2026-08-28 at 1.15.47 PM (2).jpeg"),
        ("Equine Wizard — Step 5: Emergency Directory", "Pre-assigned Equine Veterinarian & Farrier", "WIZARD S5", "WhatsApp Image 2026-08-28 at 1.15.48 PM.jpeg"),
        ("Equine Wizard — Step 6: Due Date & Scans", "Projected Foaling Date (341 Days) & Milestones", "WIZARD S6", "WhatsApp Image 2026-08-28 at 1.15.47 PM (1).jpeg"),
        ("Foal Birth Log & Offspring Registry", "Total, Colts, and Fillies categorized counts", "BIRTH LOG", "WhatsApp Image 2026-08-28 at 1.15.59 PM (2).jpeg"),
        ("Stud Foaling Diary — Movement Manager", "Broodmare movement, overdue tracking & foaling barn", "DIARY", "WhatsApp Image 2026-08-28 at 1.15.56 PM (2).jpeg"),
        ("Official Stud Foaling Diary Printable PDF", "Official structured printable report generated live", "PDF ENGINE", "WhatsApp Image 2026-08-28 at 1.15.51 PM.jpeg"),
        ("Official Equine Foal Certificate PDF", "Pedigree, Microchip, Markings & Health Record PDF", "PDF ENGINE", "WhatsApp Image 2026-08-28 at 1.15.52 PM.jpeg"),
        ("Congratulations Screen — 1-2-3 Foaling Rule", "Immediate post-foaling clinical guidelines", "CELEBRATE", "WhatsApp Image 2026-08-28 at 1.15.57 PM (1).jpeg"),
        ("Due Date Calculator — 'When Is My Foal Due?'", "Fast multi-species gestation prediction tool", "CALCULATOR", "WhatsApp Image 2026-08-28 at 1.15.57 PM.jpeg"),
        ("Dashboard Home — Equine Suite & Live Stats", "Saved Mares, Foals, Quick CTAs & Navigation", "DASHBOARD", "WhatsApp Image 2026-08-28 at 1.15.50 PM (1).jpeg"),
        ("Dashboard — Quick Actions & Shortcuts", "Instant access to 6-Step Wizard & Foal Logging", "DASHBOARD", "WhatsApp Image 2026-08-28 at 1.15.58 PM (1).jpeg"),
        ("FAQ & Help Center — Knowledge Base", "Searchable articles on gestation, scans & care", "HELP CENTER", "WhatsApp Image 2026-08-28 at 1.15.58 PM.jpeg"),
        ("Disclaimer & Legal Notice — Breeder Terms", "Official calculation terms, limitations & legal notice", "LEGAL", "WhatsApp Image 2026-08-28 at 1.15.57 PM (2).jpeg"),
    ]

    v_folder = "visual_assets"
    for i in range(0, len(ms3_visuals), 2):
        pair = ms3_visuals[i:i+2]
        cards = []
        for title, subtitle, badge, fname in pair:
            fpath = os.path.join(v_folder, fname)
            if os.path.exists(fpath):
                card = create_screenshot_card(fpath, title, subtitle, badge=badge, width=234, max_height=295)
                cards.append(card)
            else:
                cards.append(Paragraph(f"Missing asset: {fname}", body_style))

        if len(cards) == 2:
            row_table = Table([[cards[0], cards[1]]], colWidths=[252, 252])
            row_table.setStyle(TableStyle([
                ('VALIGN', (0,0), (-1,-1), 'TOP'),
                ('ALIGN', (0,0), (-1,-1), 'CENTER'),
                ('LEFTPADDING', (0,0), (-1,-1), 0),
                ('RIGHTPADDING', (0,0), (-1,-1), 0),
                ('TOPPADDING', (0,0), (-1,-1), 4),
                ('BOTTOMPADDING', (0,0), (-1,-1), 4),
            ]))
            story.append(KeepTogether([row_table, Spacer(1, 6)]))
        elif len(cards) == 1:
            row_table = Table([[cards[0]]], colWidths=[504])
            row_table.setStyle(TableStyle([
                ('ALIGN', (0,0), (-1,-1), 'CENTER'),
                ('TOPPADDING', (0,0), (-1,-1), 4),
                ('BOTTOMPADDING', (0,0), (-1,-1), 4),
            ]))
            story.append(KeepTogether([row_table, Spacer(1, 6)]))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Milestone 3 PDF Successfully Generated: {filename}")

if __name__ == "__main__":
    build_milestone_3_pdf()
