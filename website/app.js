// Animal Birthday Predictor (ABP) - Landing Page Interactive Script

document.addEventListener('DOMContentLoaded', () => {
  // Smooth scroll for in-page anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      const targetId = this.getAttribute('href');
      if (targetId === '#') return;
      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        e.preventDefault();
        targetElement.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });

  // Track app launch click
  const ctaButtons = document.querySelectorAll('.btn-cta');
  ctaButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      console.log('App CTA clicked:', btn.innerText);
    });
  });
});
