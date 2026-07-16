/* ============================================================
   CONFIG — edit this block, everything else updates itself.
   ============================================================ */

const CONFIG = {
  // TODO: replace with the artist's real name / studio name
  studioName: 'Sparks to Life Studio',
  artistName: 'the artist',

  // TODO: replace with the real WhatsApp number in international
  // format, digits only (e.g. Israeli 050-123-4567 -> 972501234567)
  whatsappNumber: '972500000000',

  // TODO: replace with the real dialable number for click-to-call
  phoneDisplay: '050-000-0000',
  phoneDial: '+972500000000',
};

/* ============================================================
   PHOTO MANIFEST — 9 real photos + open slots for later.

   Drop the 9 JPGs into the repo's /images/ folder using these
   exact filenames (or edit `src` here to match your filenames).
   work-01.jpg must be the best group shot — it is also the
   hero background. Fill in captions/alt from the planning
   manifest; a tile with an empty caption shows no label.
   ============================================================ */

const MANIFEST = [
  { src: '../images/work-01.jpg', caption: '', alt: 'Group of handmade pieces' }, // hero + gallery
  { src: '../images/work-02.jpg', caption: '', alt: 'Handmade piece' },
  { src: '../images/work-03.jpg', caption: '', alt: 'Handmade piece' },
  { src: '../images/work-04.jpg', caption: '', alt: 'Handmade piece' },
  { src: '../images/work-05.jpg', caption: '', alt: 'Handmade piece' },
  { src: '../images/work-06.jpg', caption: '', alt: 'Handmade piece' },
  { src: '../images/work-07.jpg', caption: '', alt: 'Handmade piece' },
  { src: '../images/work-08.jpg', caption: '', alt: 'Handmade piece' },
  { src: '../images/work-09.jpg', caption: '', alt: 'Handmade piece' },
  // Open slots — add `src` when the photos exist, they render as
  // "coming soon" tiles until then.
  { comingSoon: true, caption: 'Biblical scenes' },
  { comingSoon: true, caption: 'Chess sets' },
];

/* ============================================================ */

const HERO_IMAGE = MANIFEST[0].src;

function buildGallery() {
  const grid = document.getElementById('gallery-grid');

  MANIFEST.forEach((item, i) => {
    const tile = document.createElement('figure');
    tile.className = 'tile';

    if (item.comingSoon || !item.src) {
      tile.classList.add('tile-soon');
      tile.innerHTML = `
        <div class="tile-soon-inner">
          <span class="tile-soon-label">${item.caption || 'New piece'}</span>
          <span class="tile-soon-sub">coming soon</span>
        </div>`;
    } else {
      const img = document.createElement('img');
      img.src = item.src;
      img.alt = item.alt || 'Handmade piece';
      img.loading = 'lazy';
      // Until the JPG is dropped into /images/, show a styled
      // placeholder instead of a broken-image icon.
      img.onerror = () => {
        tile.classList.add('tile-soon');
        tile.innerHTML = `
          <div class="tile-soon-inner">
            <span class="tile-soon-label">${item.caption || 'Photo ' + (i + 1)}</span>
            <span class="tile-soon-sub">photo coming soon</span>
          </div>`;
      };
      img.onclick = () => openLightbox(item);
      tile.appendChild(img);

      if (item.caption) {
        const cap = document.createElement('figcaption');
        cap.textContent = item.caption;
        tile.appendChild(cap);
      }
    }

    grid.appendChild(tile);
  });
}

/* ---------- lightbox ---------- */

function openLightbox(item) {
  const lb = document.getElementById('lightbox');
  const img = document.getElementById('lightbox-img');
  img.src = item.src;
  img.alt = item.alt || '';
  document.getElementById('lightbox-caption').textContent = item.caption || '';
  lb.hidden = false;
  document.body.style.overflow = 'hidden';
}

function closeLightbox() {
  document.getElementById('lightbox').hidden = true;
  document.body.style.overflow = '';
}

/* ---------- WhatsApp modal ---------- */

function openModal() {
  document.getElementById('wa-modal').hidden = false;
  document.body.style.overflow = 'hidden';
  document.getElementById('wa-name').focus();
}

function closeModal() {
  document.getElementById('wa-modal').hidden = true;
  document.body.style.overflow = '';
}

function sendWhatsApp(event) {
  event.preventDefault();

  const name = document.getElementById('wa-name').value.trim();
  const interest = document.getElementById('wa-interest').value;
  const timing = document.getElementById('wa-timing').value.trim();
  const wishlist = document.getElementById('wa-wishlist').value.trim();

  let msg = `Hi! I found your gallery online. My name is ${name}. ` +
            `I'm interested in ${interest.toLowerCase()}.`;
  if (timing) msg += ` Timing: ${timing}.`;
  if (wishlist) msg += ` Wish list: ${wishlist}.`;

  const url = `https://wa.me/${CONFIG.whatsappNumber}?text=${encodeURIComponent(msg)}`;
  window.open(url, '_blank', 'noopener');
  closeModal();
}

/* ---------- init ---------- */

document.addEventListener('DOMContentLoaded', () => {
  // Inject config into the page
  document.querySelectorAll('[data-studio-name]').forEach(el => {
    el.textContent = CONFIG.studioName;
  });
  const callLinks = document.querySelectorAll('[data-call-link]');
  callLinks.forEach(a => {
    a.href = `tel:${CONFIG.phoneDial}`;
    a.querySelector('[data-phone-display]')?.replaceChildren(
      document.createTextNode(CONFIG.phoneDisplay)
    );
  });

  // Hero background (falls back to the CSS gradient if missing)
  const heroProbe = new Image();
  heroProbe.onload = () => {
    document.querySelector('.hero').style.backgroundImage =
      `linear-gradient(rgba(30, 22, 16, 0.55), rgba(30, 22, 16, 0.75)), url('${HERO_IMAGE}')`;
  };
  heroProbe.src = HERO_IMAGE;

  buildGallery();

  document.getElementById('wa-form').addEventListener('submit', sendWhatsApp);
  document.querySelectorAll('[data-open-modal]').forEach(b =>
    b.addEventListener('click', openModal));
  document.querySelectorAll('[data-close-modal]').forEach(b =>
    b.addEventListener('click', closeModal));
  document.getElementById('lightbox').addEventListener('click', closeLightbox);

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') { closeModal(); closeLightbox(); }
  });
});
