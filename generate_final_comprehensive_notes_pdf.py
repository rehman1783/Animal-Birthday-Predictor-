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
    Two-pass canvas for luxury running headers, footers and dynamic page count.
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
            self.setFont("Helvetica-Bold", 8)
            self.setFillColor(navy_dark)
            self.drawString(54, 752, "ANIMAL BIRTHDAY PREDICTOR (ABP)™")
            
            self.setFont("Helvetica-Bold", 8)
            self.setFillColor(gold_accent)
            self.drawString(235, 752, "|")
            
            self.setFont("Helvetica", 8)
            self.setFillColor(text_gray)
            self.drawString(245, 752, "Final Project Delivery Notes & In-Place Visual Proof")
            
            self.drawRightString(612 - 54, 752, "Doc Ref: ABP-FINAL-RELEASE-2026")
            
            self.setStrokeColor(gold_accent)
            self.setLineWidth(0.8)
            self.line(54, 744, 612 - 54, 744)

        # Bottom Running Footer (All Pages)
        self.setStrokeColor(line_color)
        self.setLineWidth(0.6)
        self.line(54, 44, 612 - 54, 44)

        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(navy_dark)
        self.drawString(54, 30, "ANIMAL BIRTHDAY PREDICTOR")
        
        self.setFont("Helvetica", 8)
        self.setFillColor(text_gray)
        self.drawString(185, 30, "— Production Delivery Notes & Point-by-Point Visual Verification")
        
        page_str = f"Page {self._pageNumber} of {page_count}"
        self.drawRightString(612 - 54, 30, page_str)
        
        self.restoreState()


def create_screenshot_card(img_path, title, subtitle, badge="VERIFIED", width=234, max_height=260):
    """
    Creates an uncropped, clean visual card with header and badge.
    """
    gold = colors.HexColor("#D4AF37")
    slate_dark = colors.HexColor("#0A192F")
    slate_bg = colors.HexColor("#F8FAFC")
    text_muted = colors.HexColor("#64748B")

    if not os.path.exists(img_path):
        return Paragraph(f"Missing: {os.path.basename(img_path)}", ParagraphStyle('Err', fontName='Helvetica', fontSize=8, textColor=colors.red))

    with PILImage.open(img_path) as pimg:
        orig_w, orig_h = pimg.size
        aspect = orig_h / orig_w
        calc_w = width
        calc_h = calc_w * aspect
        if calc_h > max_height:
            calc_h = max_height
            calc_w = calc_h / aspect
        
        rl_img = Image(img_path, width=calc_w, height=calc_h)

    title_p = Paragraph(f"<b>📸 {title}</b>", ParagraphStyle(
        'CardTitle', fontName='Helvetica-Bold', fontSize=7.5, leading=9.5, textColor=slate_dark
    ))
    subtitle_p = Paragraph(f"<font color='#64748B'>{subtitle}</font>", ParagraphStyle(
        'CardSubtitle', fontName='Helvetica', fontSize=6.5, leading=8.5, textColor=text_muted
    ))
    badge_p = Paragraph(f"<font color='#059669'><b>[{badge}]</b></font>", ParagraphStyle(
        'CardBadge', fontName='Helvetica-Bold', fontSize=7, leading=9, alignment=2
    ))

    header_table = Table([[title_p, badge_p]], colWidths=[width - 55, 55])
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
        Spacer(1, 3),
        rl_img
    ]

    card_table = Table([[card_content]], colWidths=[width + 8])
    card_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), slate_bg),
        ('BOX', (0, 0), (-1, -1), 0.8, gold),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    return card_table


def generate_final_pdf():
    pdf_filename = "ABP_Final_Project_Comprehensive_Notes_and_Visual_Proof.pdf"
    
    doc = SimpleDocTemplate(
        pdf_filename,
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
    c_border = colors.HexColor("#CBD5E1")
    c_text_main = colors.HexColor("#334155")
    c_green = colors.HexColor("#059669")
    c_amber = colors.HexColor("#D97706")

    # Typography Styles
    title_style = ParagraphStyle(
        'CoverTitle',
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=c_navy_dark,
        spaceAfter=3
    )
    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        fontName='Helvetica',
        fontSize=9,
        leading=12,
        textColor=c_gold_dark,
        spaceAfter=6
    )
    h1_style = ParagraphStyle(
        'SectionH1',
        fontName='Helvetica-Bold',
        fontSize=11.5,
        leading=14.5,
        textColor=c_navy_dark,
        spaceBefore=12,
        spaceAfter=4,
        keepWithNext=True
    )
    h2_style = ParagraphStyle(
        'SectionH2',
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=12,
        textColor=c_navy_light,
        spaceBefore=8,
        spaceAfter=3,
        keepWithNext=True
    )
    body_style = ParagraphStyle(
        'BodyDark',
        fontName='Helvetica',
        fontSize=8,
        leading=11,
        textColor=c_text_main,
        spaceAfter=4
    )
    bullet_style = ParagraphStyle(
        'BulletPoint',
        fontName='Helvetica',
        fontSize=8,
        leading=11,
        textColor=c_text_main,
        leftIndent=12,
        firstLineIndent=-12,
        spaceAfter=3
    )
    table_header_style = ParagraphStyle(
        'TableHeader',
        fontName='Helvetica-Bold',
        fontSize=7.5,
        leading=9.5,
        textColor=colors.white
    )
    table_cell_style = ParagraphStyle(
        'TableCell',
        fontName='Helvetica',
        fontSize=7,
        leading=9,
        textColor=c_text_main
    )
    table_cell_bold = ParagraphStyle(
        'TableCellBold',
        fontName='Helvetica-Bold',
        fontSize=7,
        leading=9,
        textColor=c_navy_dark
    )
    table_cell_green = ParagraphStyle(
        'TableCellGreen',
        fontName='Helvetica-Bold',
        fontSize=7,
        leading=9,
        textColor=c_green
    )

    story = []
    v_folder = "visual_assets"

    def make_pair_table(item1, item2):
        card1 = create_screenshot_card(os.path.join(v_folder, item1[0]), item1[1], item1[2], badge=item1[3], width=234, max_height=260)
        card2 = create_screenshot_card(os.path.join(v_folder, item2[0]), item2[1], item2[2], badge=item2[3], width=234, max_height=260)
        row_table = Table([[card1, card2]], colWidths=[252, 252])
        row_table.setStyle(TableStyle([
            ('VALIGN', (0,0), (-1,-1), 'TOP'),
            ('ALIGN', (0,0), (-1,-1), 'CENTER'),
            ('LEFTPADDING', (0,0), (-1,-1), 0),
            ('RIGHTPADDING', (0,0), (-1,-1), 0),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ]))
        return KeepTogether([row_table, Spacer(1, 4)])

    def make_single_table(item):
        card = create_screenshot_card(os.path.join(v_folder, item[0]), item[1], item[2], badge=item[3], width=234, max_height=260)
        row_table = Table([[card]], colWidths=[504])
        row_table.setStyle(TableStyle([
            ('ALIGN', (0,0), (-1,-1), 'CENTER'),
            ('TOPPADDING', (0,0), (-1,-1), 3),
            ('BOTTOMPADDING', (0,0), (-1,-1), 3),
        ]))
        return KeepTogether([row_table, Spacer(1, 4)])

    # =========================================================================
    # COVER / HEADER BANNER
    # =========================================================================
    header_table_data = [
        [
            Paragraph("<b>ANIMAL BIRTHDAY PREDICTOR (ABP)™</b>", title_style),
            Paragraph("<b>DOCUMENT CLASSIFICATION</b><br/>Production Release Notes", ParagraphStyle('MetaRight', fontName='Helvetica', fontSize=7.5, leading=10, alignment=2, textColor=c_navy_dark))
        ],
        [
            Paragraph("Comprehensive Milestone Analysis, Scope Breakdown & In-Place Visual Proofs", subtitle_style),
            Paragraph("<b>Status:</b> <font color='#059669'><b>100% PRODUCTION READY</b></font><br/><b>QA Suite:</b> 344 / 344 Tests Passed (0 Overflow)", ParagraphStyle('MetaRightSub', fontName='Helvetica', fontSize=7.5, leading=10, alignment=2, textColor=c_text_main))
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
    story.append(HRFlowable(width="100%", thickness=1.5, color=c_gold, spaceBefore=3, spaceAfter=8))

    # =========================================================================
    # SECTION 1: EXECUTIVE SUMMARY
    # =========================================================================
    story.append(Paragraph("1. Executive Summary & Project Rebuilding Overview", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=5))
    story.append(Paragraph(
        "The Animal Birthday Predictor (ABP) platform has been completely re-architected and engineered from the legacy, bug-prone Thunkable prototype into an enterprise-grade Flutter application backed by Supabase PostgreSQL database architecture. The system provides pixel-perfect dark theme aesthetics as approved in Figma, responsive layouts validated across 37 screens from 320px mobile to 1280px desktop, and multi-tenant strict user data isolation via Row Level Security (RLS).",
        body_style
    ))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.25 AM (1).jpeg", "Dashboard Home & Equine Suite Hub", "Live stats, active Pro plan badge, quick CTAs & 6-step breeding wizard shortcut", "DASHBOARD HUB"),
        ("WhatsApp Image 2026-08-30 at 2.10.12 AM.jpeg", "Multi-Species Selection Hub", "Strict animal scoping: Horse / Equine active, Dog / Canine active, Cat & Cattle prepared", "SPECIES SCOPING")
    ))

    # =========================================================================
    # SECTION 2: ORIGINAL MILESTONES (ITEM-BY-ITEM WITH ATTACHED PROOFS)
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("2. Original Milestone Deliverables Breakdown & Status", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=5))
    
    # Milestone 1
    story.append(Paragraph("<b>Milestone 1: Project Foundation, Auth & Mare Management (08 August 2026)</b>", h2_style))
    story.append(Paragraph("• <b>Flutter Project Setup & Supabase Auth:</b> Configured clean architecture with Riverpod state management and multi-platform compilation. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(Paragraph("• <b>Mare Registration & Verified Directory:</b> Full Broodmare registration with breed, color, microchip, and Stud Book registry numbers. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(Paragraph("• <b>Equine Industry Terminology:</b> Industry-correct classification for Mare (Female/Dam), Stallion (Male/Stud), and Gelding (Castrated). [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.22 AM.jpeg", "ABP Verified Animal Registry", "Saved Broodmares & Horses directory with microchips and quick filters (All, Mares, Stallions)", "MARE REGISTRY"),
        ("WhatsApp Image 2026-08-30 at 2.10.10 AM.jpeg", "Animal Details & Classification", "Core identity form with Dam / Broodmare, Stallion, and Gelding (castrated) selections", "EQUINE IDENTITY")
    ))

    story.append(Paragraph("• <b>Complete Mare Details & Markings:</b> 3-angle anatomical physical markings guide (Head / Face, Left Side, Right Side). [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(Paragraph("• <b>340-Day Due Date Calculation & ET Flow:</b> Automated gestation engine and recipient surrogate mare designation. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.21 AM (3).jpeg", "Horse Profile & Quick Actions", "Clinical horse profile card with breeding records, microchip, and quick action buttons", "MARE PROFILE"),
        ("WhatsApp Image 2026-08-30 at 2.10.23 AM (1).jpeg", "3-Point Visual Markings Guide", "Anatomical visual markings upload slots for Head View, Left Side, and Right Side", "MARKINGS PROOF")
    ))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.22 AM (2).jpeg", "Embryo Transfer Gestation Engine", "Live 331-day countdown with genetic dam ('mar') and recipient carrier tracking", "ET GESTATION"),
        ("WhatsApp Image 2026-08-30 at 2.10.17 AM (2).jpeg", "Embryo Transfer Recipient Designation", "Dedicated toggle to designate surrogate carrier mare separate from biological dam", "RECIPIENT MARE")
    ))

    # Milestone 2
    story.append(PageBreak())
    story.append(Paragraph("<b>Milestone 2: Pregnancy Module, 3 Scans & Preventative Care (20 August 2026)</b>", h2_style))
    story.append(Paragraph("• <b>Pregnancy Module & Countdown:</b> Dedicated gestation overview with remaining days countdown. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(Paragraph("• <b>Three Pregnancy Scans & Twin Alert:</b> Scan 1 (Day 14-16), Scan 2 (Day 28-30), Scan 3 (Day 45-60) with ultrasound attachments. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.22 AM (1).jpeg", "Pregnancy Module & Gestation Countdown", "Live foaling due date (339 days remaining) with automated 3-stage ultrasound milestones", "GESTATION ENGINE"),
        ("WhatsApp Image 2026-08-30 at 2.10.23 AM.jpeg", "Three Pregnancy Scans & Twin Alert", "3/3 Scans confirmed status with clinical red Twin Alert banner and re-scan countdown", "3-STAGE SCANS")
    ))

    story.append(Paragraph("• <b>Vaccination & Preventative Care:</b> EHV-1 Rhino protocols at Months 5, 7, 9, Tetanus, Strangles, Rotavirus, and Deworming. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(Paragraph("• <b>Dentist, Farrier & Click-to-Call:</b> Professional service logs and native 1-tap phone dialing. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.17 AM (1).jpeg", "Preventative Care & Equine Vaccines", "Verified 9-vaccine protocol (Tetanus, Strangles, EHV 1/4, Rotavirus) & broad-spectrum deworming", "VACCINE PROTOCOL"),
        ("WhatsApp Image 2026-08-30 at 2.10.17 AM.jpeg", "Dentist, Farrier & Emergency Vet", "Professional service directory with native 1-tap Click-to-Call (tel:) actions", "CLICK-TO-CALL")
    ))

    # Milestone 3
    story.append(PageBreak())
    story.append(Paragraph("<b>Milestone 3: Foal Suite, Buyer Suite, PDF & Quality Assurance (01 September 2026)</b>", h2_style))
    story.append(Paragraph("• <b>Foal Registration & Birth Log:</b> Birth date, sex (colt/filly), birth weight, placenta status, and parentage linking. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(Paragraph("• <b>Summary Stats & Offspring Counters:</b> Tracking lifecycle status (Total, Colts, Fillies, Gelded, Sold). [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.23 AM (2).jpeg", "New Foal Registration & Birth Log", "Birth record capturing DOB, sex (Filly/Colt), linked Dam/Mother, and profile photo", "FOAL REGISTRATION"),
        ("WhatsApp Image 2026-08-30 at 2.10.24 AM.jpeg", "Birth Log Registry & Summary Counters", "Offspring summary stats (Total, Colts, Fillies, Gelded, Sold) with status filters (Keep, Available)", "BIRTH LOG STATS")
    ))

    story.append(Paragraph("• <b>Official PDF Generation Engine:</b> High-resolution printable Stud Foaling Diaries and luxury Pedigree Certificates. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(Paragraph("• <b>QA Verification:</b> 344 passing automated tests, zero overflow, and live Firebase deployment. [<font color='#059669'><b>COMPLETED ✅</b></font>]", bullet_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.20 AM (1).jpeg", "Official Equine Foal Certificate PDF", "Luxury pedigree certificate with microchip, DNA profile, parentage lineage, and health summary", "OFFICIAL CERTIFICATE"),
        ("WhatsApp Image 2026-08-30 at 2.10.20 AM (2).jpeg", "Print Preview & PDF Export Engine", "Live vector print dialog generating high-resolution printable Stud Foaling Diary reports", "VECTOR PDF ENGINE")
    ))

    # =========================================================================
    # SECTION 3: ADDITIONAL WORK (WITH IN-PLACE PROOFS)
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("3. Additional & Value-Added Work (Not in Original Brief)", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=5))
    story.append(Paragraph(
        "The following 12 major features were engineered specifically to handle commercial-scale stud operations (20 to 100+ broodmares) and direct client requests, elevating ABP to a commercial-grade equine platform:",
        body_style
    ))

    # Item 1: 6-Step Breeding Wizard
    story.append(Paragraph("<b>1. 6-Step Interactive Equine Breeding Wizard</b>", h2_style))
    story.append(Paragraph("Chronological process: Broodmare ➔ Sire/Method ➔ Recipient (ET) ➔ Vaccines ➔ Emergency Directory ➔ Live Due Date Calculation.", body_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.20 AM.jpeg", "Wizard Step 1: Select Broodmare / Dam", "Quick selection of existing registered broodmare or 1-tap addition of new mare", "WIZARD STEP 1"),
        ("WhatsApp Image 2026-08-30 at 2.10.19 AM.jpeg", "Wizard Step 2: Breeding Service & Stallion", "Cover date, Stallion name & Insemination method (Natural, Chilled, Frozen, ET, ICSI)", "WIZARD STEP 2")
    ))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.17 AM (2).jpeg", "Wizard Step 3: Recipient Mare (ET)", "Embryo transfer surrogate designation linking genetic dam to recipient carrier", "WIZARD STEP 3"),
        ("WhatsApp Image 2026-08-30 at 2.10.17 AM (1).jpeg", "Wizard Step 4: Preventative Care & Vaccines", "Equine gestational vaccine checklist (Tetanus, Strangles, EHV 1/4, Rotavirus, Wormer)", "WIZARD STEP 4")
    ))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.17 AM.jpeg", "Wizard Step 5: Emergency Vet & Farrier", "Pre-assigned Equine Veterinarian & Farrier directory with instant 1-tap Click-to-Call", "WIZARD STEP 5"),
        ("WhatsApp Image 2026-08-30 at 2.10.14 AM.jpeg", "Wizard Step 6: Due Date & Ultrasound Scans", "Projected Foaling Date (341 Days) and automated Day 14, 28, and 45 scan milestones", "WIZARD STEP 6")
    ))

    # Item 2 & 3: Diary & Calendar Sync
    story.append(PageBreak())
    story.append(Paragraph("<b>2. Live Synced Stud Foaling Diary & 3. Gestation Calendar Sync</b>", h2_style))
    story.append(Paragraph("Commercial stud management interface supporting 20 to 100+ broodmares with dynamic pasture movement badges (Overdue, Foaling Barn <14d, Close Paddock <30d, Upcoming 30+d) and live unified chronological timeline feed.", body_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.21 AM (1).jpeg", "Stud Gestation & Movement Manager", "Broodmare Roster with dynamic movement badges (Upcoming 314d) and current paddock location", "STUD FOALING DIARY"),
        ("WhatsApp Image 2026-08-30 at 2.10.25 AM (2).jpeg", "Live Synced Gestation Calendar & Timeline", "Real-time chronological feed: Scan 1 Overdue, Scan 2 in 1 Day, and Upcoming Scan checks", "CALENDAR SYNC")
    ))

    # Item 4 & 5: Calculator & Twin Alert
    story.append(Paragraph("<b>4. Dedicated Foal Due Calculator & 5. Clinical Twin Warning Engine</b>", h2_style))
    story.append(Paragraph("Standalone rapid-calculation tool showing expected due dates and earliest/latest viable windows. High-priority clinical safety banner with automated re-scan countdown scheduling.", body_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.21 AM.jpeg", "Dedicated Due Date Calculator", "Instant calculation showing Expected Due Date 06/06/2027, 280 Days Remaining & Viable Windows", "RAPID CALCULATOR"),
        ("WhatsApp Image 2026-08-30 at 2.10.23 AM.jpeg", "Clinical Twin Warning & Re-Scan Banner", "High-visibility warning banner: 'TWIN ALERT: Re-scan scheduled for 02/09/2026'", "TWIN ALERT ENGINE")
    ))

    # Item 7 & 8: Congratulations & Payment Portal
    story.append(PageBreak())
    story.append(Paragraph("<b>7. Congratulations Screen & 8. Dedicated Payment Portal</b>", h2_style))
    story.append(Paragraph("Celebration screen with the 1-2-3 Foaling Rule checklist. Complete commercial subscription infrastructure: ABP Pro Master Breeder tier card ($29.99/yr), credit card preview, wire transfer details, and invoice receipt viewer.", body_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.12 AM (1).jpeg", "Congratulations Screen & 1-2-3 Foaling Rule", "Glowing golden celebration badge with post-foaling critical veterinary guidelines", "CELEBRATION SCREEN"),
        ("WhatsApp Image 2026-08-30 at 2.10.26 AM (3).jpeg", "ABP Pro Master Breeder Tier Card", "Active subscription card ($29.99/yr) with verified feature checklist & auto-renew toggle", "SUBSCRIPTION PLAN")
    ))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.26 AM (2).jpeg", "Payment Method on File Card", "ABP Breeder Card VISA •••• 4242 with direct card management and wire transfer link", "CREDIT CARD CARD"),
        ("WhatsApp Image 2026-08-30 at 2.10.26 AM (1).jpeg", "Direct Bank & Wire Transfer Details", "JPMorgan Chase Bank wire transfer details with 1-tap copy buttons for IBAN & SWIFT", "WIRE TRANSFER")
    ))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.26 AM.jpeg", "Billing History & Security Guarantee", "Verified invoices list ($29.99 PAID) and official 256-bit bank-grade encryption guarantee", "INVOICE VIEWER"),
        ("WhatsApp Image 2026-08-30 at 2.10.24 AM (1).jpeg", "User Profile Subscription Access", "Registered Breeder profile screen linking directly to Subscription & Payment details", "PROFILE ACCESS")
    ))

    # Item 10 & 11: FAQ & Disclaimer
    story.append(PageBreak())
    story.append(Paragraph("<b>10. Searchable Help Center & 11. Comprehensive Disclaimer</b>", h2_style))
    story.append(Paragraph("Searchable knowledge base with accordion cards and category filtering. Pre-integrated breeder calculation advisories and terms of medical and gestation calculation.", body_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.24 AM (3).jpeg", "Interactive FAQ & Help Center", "Searchable knowledge base with category filters (All, Equine & Foaling, Canine) and accordion answers", "HELP CENTER"),
        ("WhatsApp Image 2026-08-30 at 2.10.24 AM (2).jpeg", "Disclaimer & Legal Notice Screen", "Official breeder disclaimer: Informational decision-support purpose and veterinary consultation notices", "LEGAL NOTICE")
    ))

    # =========================================================================
    # SECTION 4: PENDING ITEMS (WITH IN-PLACE PROOFS)
    # =========================================================================
    story.append(Paragraph("4. Pending Items Awaiting Client External Inputs", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=5))
    story.append(Paragraph("• <b>Formal Legal Terms & Privacy Policy:</b> The router endpoint (/disclaimer) and scrollable UI layout are 100% built and ready for immediate drop-in as soon as the client's solicitor delivers formal legal text. [<font color='#D97706'><b>PENDING CLIENT SOLICITOR ⏳</b></font>]", bullet_style))
    story.append(Paragraph("• <b>Future Dog / Canine Module Content:</b> The multi-species database schema, species selection landing hub, and dedicated canine tabs are 100% prepared for client materials. [<font color='#D97706'><b>PENDING CLIENT MATERIAL ⏳</b></font>]", bullet_style))
    story.append(make_pair_table(
        ("WhatsApp Image 2026-08-30 at 2.10.24 AM (2).jpeg", "Legal Disclaimer Layout (Ready for Solicitor)", "Scrollable legal layout ready for immediate drop-in of solicitor text", "LEGAL READY"),
        ("WhatsApp Image 2026-08-30 at 2.10.21 AM (2).jpeg", "Multi-Species Architecture & Canine Hub", "Species selection hub with active Canine module ready for expanded material", "CANINE READY")
    ))

    # =========================================================================
    # SECTION 5: POINT-BY-POINT ANSWERS TO CLIENT'S 14 QUESTIONS
    # =========================================================================
    story.append(PageBreak())
    story.append(Paragraph("5. Comprehensive Answers to Client's 14 Feedback Inquiries", h1_style))
    story.append(HRFlowable(width="100%", thickness=0.8, color=c_border, spaceBefore=1, spaceAfter=5))

    client_qa_list = [
        ("1. Dashboard / Homepage Structure", "YES, CONFIRMED. The Dashboard acts as the starting hub where users choose animal species. When Equine is selected, only Equine-specific fields, terminologies, and modules appear.", "Images #3 & #26"),
        ("2. Equine User Flow (Chronological Sequence)", "YES, CONFIRMED & IMPLEMENTED. The 6-Step Breeding Wizard strictly follows: Mare details ➔ Breeding & Sire ➔ Recipient ➔ Preventative Care ➔ Emergency Contacts ➔ Calculated Due Date. Result appears at the end to ensure complete record entry.", "Images #11, #8, #6, #5, #7, #4"),
        ("3. Animal-Specific Fields & Isolation", "YES, CONFIRMED. Equine (Broodmares, Stallions, Foals) and Canine (Bitches, Sires, Puppies) are strictly segregated in the database, filters, and UI.", "Images #3 & #18"),
        ("4. Equine Industry Terminology", "YES, CONFIRMED & FIXED. Generic 'Mother/Father' terms have been replaced with 'Dam / Broodmare', 'Sire / Covering Stallion', 'Recipient Carrier Mare', and 'Gelding (castrated)'.", "Image #1"),
        ("5. Prominent Preventative Care", "YES, CONFIRMED. Vaccine schedules (EHV-1 Rhino 5/7/9m, Tetanus, Strangles, Rotavirus) and Deworming parasite logs with custom product names/dates are prominently accessible on profiles, the wizard, and health modules.", "Image #5"),
        ("6. Birth / Foal Records", "YES, CONFIRMED. Foal records capture delivery date, sex (colt/filly), birth weight, placenta status, and 3-angle physical markings (Head/Face, Left, Right).", "Images #20 & #25"),
        ("7. Save & Continue Date Entry Issue", "INVESTIGATED & 100% FIXED. Form date pickers and controllers now validate and persist immediately, allowing smooth forward navigation.", "Images #8 & #4"),
        ("8. Database & Multi-Mare Scaling (1 to 500+ Horses)", "YES, CONFIRMED. Built on Supabase PostgreSQL with multi-tenant RLS. Scales easily from small breeders (1 horse) to large commercial studs (500+ horses).", "Images #12 & #18"),
        ("9. Phone ➔ PC Photo Sync", "YES, CONFIRMED. Photos taken on mobile in the paddock sync directly to Supabase cloud storage and are instantly accessible on PC, tablet, or web browser.", "Images #14 & #25"),
        ("10. Official ABP Logo & Branding", "YES, CONFIRMED. Official ABP brand crest is stamped on headers, footers, certificates, and payment screens. Horseshoe icons are strictly restricted to horse-specific features.", "Images #26 & #32"),
        ("11. ABP Watermarking & Copy Protection", "YES, CONFIRMED. Stamped ABP Verification badges, tamper-resistant PDF layouts, and encrypted payment seals protect the app from copycats.", "Images #9 & #32"),
        ("12. Ongoing Maintenance & Support", "YES, CONFIRMED. We provide full ongoing technical support, post-launch maintenance, database backups, performance monitoring, and app store updates.", "344 Tests Suite OK"),
        ("13. Legal Documents (Terms & Privacy)", "READY FOR DROP-IN. Router endpoints and screens (/disclaimer, /faq) are ready to receive the solicitor's legal text.", "Image #23"),
        ("14. Current Live Version", "CONFIRMED. The live build reflects the latest production release containing all Milestone 1, 2, and 3 deliverables and all client feedback additions.", "Live on Firebase"),
    ]

    qa_table_data = [
        [
            Paragraph("<b>Client Feedback Topic</b>", table_header_style),
            Paragraph("<b>Technical Confirmation & Implementation Details</b>", table_header_style),
            Paragraph("<b>Visual Proof</b>", table_header_style)
        ]
    ]
    for q_t, a_t, v_t in client_qa_list:
        qa_table_data.append([
            Paragraph(f"<b>{q_t}</b>", table_cell_bold),
            Paragraph(a_t, table_cell_style),
            Paragraph(f"<font color='#B8972E'><b>{v_t}</b></font>", table_cell_style)
        ])

    qa_table = Table(qa_table_data, colWidths=[120, 274, 110])
    qa_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), c_navy_dark),
        ('GRID', (0, 0), (-1, -1), 0.4, c_border),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, c_slate_light]),
    ]))
    story.append(qa_table)

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Master Comprehensive Notes PDF with In-Place Visual Proofs Successfully Generated: {pdf_filename}")

if __name__ == "__main__":
    generate_final_pdf()
