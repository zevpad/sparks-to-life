// Best-effort admin ping when a visitor taps Send in the booking modal
// (or the direct-message link). Client fires navigator.sendBeacon just
// before opening the wa.me URL — this can only confirm the button was
// tapped, not that the WhatsApp message was delivered.
//
// Reads ADMIN_PHONE and CALLMEBOT_APIKEY from Cloudflare Pages
// environment variables — never hardcoded. Fails silently: whatever
// happens here, the visitor gets a 204 and their WhatsApp redirect is
// never affected (the client doesn't even wait for this response).

export async function onRequestPost(context) {
  try {
    const { ADMIN_PHONE, CALLMEBOT_APIKEY } = context.env;
    if (ADMIN_PHONE && CALLMEBOT_APIKEY) {
      let data = {};
      try { data = await context.request.json(); } catch (e) { /* ignore bad payloads */ }

      const clip = (v) => String(v).slice(0, 200);
      const parts = [];
      if (data.direct) parts.push('direct message tapped');
      if (data.size) parts.push(`${clip(data.size)} people`);
      if (data.level) parts.push(clip(data.level));
      if (data.time) parts.push(clip(data.time));
      if (data.wish) parts.push(`wish: ${clip(data.wish)}`);

      const text = `McLevy site inquiry: ${parts.join(', ') || 'booking button tapped'}`;
      const url = 'https://api.callmebot.com/whatsapp.php' +
        `?phone=${encodeURIComponent(ADMIN_PHONE)}` +
        `&text=${encodeURIComponent(text)}` +
        `&apikey=${encodeURIComponent(CALLMEBOT_APIKEY)}`;

      // Don't hold the response open for CallMeBot.
      context.waitUntil(fetch(url).catch(() => {}));
    }
  } catch (e) { /* never surface errors to the visitor */ }

  return new Response(null, { status: 204 });
}
