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
            self.drawString(230, 752, "Milestone 2 Final Deliverables & Gestation Architecture Report")
            
            self.drawRightString(612 - 54, 752, "Doc Ref: ABP-MS2-FINAL")
            
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
        self.drawString(185, 30, "— Milestone 2: Mare Management, 3-Stage Scans & Gestation Protocols")

        self.drawRightString(612 - 54, 30, f"Page {self._pageNumber} of {page_count}")
        
        self.restoreState()


def create_screenshot_card(img_path, title, subtitle, badge="MS2 VERIFIED", width=230, max_height=295):
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


def build_milestone_2_pdf(filename="ABP_Milestone_2_Report.pdf"):
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
            Paragraph("<b>MILESTONE 2 DELIVERABLES</b><br/>Production Release Report", ParagraphStyle('MetaRight', fontName='Helvetica', fontSize=7.5, leading=10, alignment=2, textColor=c_navy_dark))
        ],
        [
            Paragraph("Mare Management, Breeding Inseminations, 3-Stage Scans & Gestation Protocols", subtitle_style),
            Paragraph("<b>Status:</b> <font color='#059669'><b>100% COMPLETED</b></font><br/><b>Database:</b> Supabase PostgreSQL Sync OK", ParagraphStyle('MetaRightSub', fontName='Helvetica', fontSize=7.5, leading=10, alignment=2, textColor=c_text_main))
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
    story.append(Paragraph("1. Milestone 2 Deliverables & Scope Summary", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=6))
    story.append(Paragraph(
        "Milestone 2 establishes the core clinical and gestational foundation of the Animal Birthday Predictor. It covers end-to-end Broodmare lifecycle management, physical 3-angle markings and brand records, insemination / breeding logs with sire genetics, 3-stage veterinary ultrasound scanning schedules (with automated twin warnings), and gestational preventative care (Rhinopneumonitis EHV-1 vaccination protocols at months 5, 7, and 9).",
        body_style
    ))
    story.append(Spacer(1, 4))

    # Summary Table
    ms2_table_data = [
        [
            Paragraph("<b>Feature Component</b>", table_header_style),
            Paragraph("<b>Clinical Scope & Architecture</b>", table_header_style),
            Paragraph("<b>Status</b>", table_header_style)
        ],
        [
            Paragraph("<b>Saved Broodmare & Horse Registry</b>", table_cell_bold),
            Paragraph("Direct creation, editing, microchip tracking, dam/sire lineage, photo storage, and species filtering (Horse vs Dog).", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Physical Markings (3-Angle Diagrams)</b>", table_cell_bold),
            Paragraph("Left side, right side, and head view visual marking diagrams and freeform identification notes.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Breeding & Insemination Records</b>", table_cell_bold),
            Paragraph("Tracking cover date, Natural / AI / ET methods, donor mare, recipient carrier, and sire stallion details.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>3-Stage Vet Scans & Twin Warning</b>", table_cell_bold),
            Paragraph("Scan 1 (Day 14-16, 98% accuracy + twin check), Scan 2 (Day 28-30 heartbeat), Scan 3 (Day 45 organogenesis) with ultrasound photo attachments.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ],
        [
            Paragraph("<b>Advanced Gestational Health & Rhino</b>", table_cell_bold),
            Paragraph("Months 5, 7, 9 EHV-1 vaccination milestones, Caslick procedure tracking, and deworming protocols.", table_cell_style),
            Paragraph("<font color='#059669'><b>100% OK</b></font>", table_cell_green)
        ]
    ]
    ms2_table = Table(ms2_table_data, colWidths=[150, 260, 94])
    ms2_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy_dark),
        ('GRID', (0, 0), (-1, -1), 0.4, c_border),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 5),
        ('RIGHTPADDING', (0, 0), (-1, -1), 5),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, c_slate_light]),
    ]))
    story.append(ms2_table)
    story.append(Spacer(1, 10))

    # Technical Details
    story.append(Paragraph("2. Technical & Clinical Specifications", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=6))
    story.append(Paragraph(
        "<b>A. Twin Warning Protocol:</b> Multiple gestations in equines represent a critical clinical risk (spontaneous late abortion or dystocia). Scan 1 triggers automatic twin detection flags allowing early manual reduction prior to embryo fixation at Day 16.",
        body_style
    ))
    story.append(Paragraph(
        "<b>B. Rhinopneumonitis (EHV-1) Vaccination Safeguards:</b> Advanced pregnancy tracking incorporates EHV-1 abortion prevention protocol timelines at 5, 7, and 9 months with completed date tracking.",
        body_style
    ))
    story.append(Paragraph(
        "<b>C. Database Isolation & Resilient Upsert:</b> All records are secured under PostgreSQL Row-Level Security (RLS) policies scoped strictly to authenticated users (<code>auth.uid() = user_id</code>), preventing data cross-leakage.",
        body_style
    ))
    story.append(Spacer(1, 10))

    # Visual Exhibits
    story.append(PageBreak())
    story.append(Paragraph("3. Milestone 2 Visual Implementation Exhibits", h1_style))
    story.append(HRFlowable(width="100%", thickness=1.2, color=c_gold, spaceBefore=2, spaceAfter=8))
    story.append(Paragraph(
        "The following gallery showcases unaltered visual evidence demonstrating all Milestone 2 capabilities:",
        body_style
    ))
    story.append(Spacer(1, 6))

    ms2_visuals = [
        ("Saved Animals Registry — Horse Directory", "Mares list with microchip & species categorization", "REGISTRY", "WhatsApp Image 2026-08-28 at 1.15.50 PM.jpeg"),
        ("Saved Animals Registry — Species Scoping", "Strict separation of Horses vs Dogs with sub-tabs", "SCOPING", "WhatsApp Image 2026-08-28 at 1.15.59 PM (1).jpeg"),
        ("Horse Profile View — Pedigree & Microchip", "Full overview card with actions for Markings & Care", "PROFILE", "WhatsApp Image 2026-08-28 at 1.15.59 PM.jpeg"),
        ("Physical Markings — 3-Angle Anatomical Guide", "Left side, Right side & Head view diagram registry", "MARKINGS", "WhatsApp Image 2026-08-28 at 1.15.56 PM (1).jpeg"),
        ("Breeding Details — Donor Mare & Sire Form", "Direct entry form for Cover Date, Stallion & Insemination", "BREEDING", "WhatsApp Image 2026-08-28 at 1.15.56 PM.jpeg"),
        ("Pregnancy & Breeding Tracker — Broodmare List", "Live Scan status badges, gestation progress & alerts", "TRACKER", "WhatsApp Image 2026-08-28 at 1.15.58 PM (2).jpeg"),
        ("Pregnancy Details — Active Due Date & Scans", "Gestation period calculation & early scan schedule", "GESTATION", "WhatsApp Image 2026-08-28 at 1.15.47 PM.jpeg"),
        ("Veterinarian Scans Overview — 3/3 Confirmed", "Complete 3-scan progress status with Carrier Mare", "VET SCANS", "WhatsApp Image 2026-08-28 at 1.15.55 PM (2).jpeg"),
        ("Veterinarian Scans — Scan 1 Ultrasound Confirmed", "Day 14-16 vesicle verification & photo attachment", "SCAN 1", "WhatsApp Image 2026-08-28 at 1.15.55 PM (1).jpeg"),
        ("Veterinarian Scans — Twin Warning & Detection", "Clinical twin detection banner & management alert", "TWIN ALERT", "WhatsApp Image 2026-08-28 at 1.15.55 PM.jpeg"),
        ("Mare Preventative Care — Deworming Schedule", "Deworming interval tracking, custom date & brand logs", "HEALTH", "WhatsApp Image 2026-08-28 at 1.15.53 PM (1).jpeg"),
        ("Advanced Pregnancy — Rhino (EHV-1) Protocols", "Months 5, 7, 9 vaccination & fetal sexing logs", "ADV PREG", "WhatsApp Image 2026-08-28 at 1.15.53 PM.jpeg"),
    ]

    v_folder = "visual_assets"
    for i in range(0, len(ms2_visuals), 2):
        pair = ms2_visuals[i:i+2]
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
    print(f"Milestone 2 PDF Successfully Generated: {filename}")

if __name__ == "__main__":
    build_milestone_2_pdf()
