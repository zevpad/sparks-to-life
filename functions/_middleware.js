// Host-based rewrite for the candle-site subdomain.
//
// The Pages project serves the whole repo, so its root is the beta-tester
// page. When the request arrives on the candle domain, serve the McLevy
// site at "/" instead (an internal rewrite — the visitor's URL stays
// tzfatcandles.thehonuway.com). Every other host and path passes through
// untouched, so the tester page and /api/notify keep working everywhere.
//
// Override the hostname with a CANDLE_HOST env var in the Cloudflare
// dashboard if the subdomain ever changes.

const DEFAULT_CANDLE_HOST = 'tzfatcandles.thehonuway.com';

export async function onRequest(context) {
  const url = new URL(context.request.url);
  const candleHost = context.env.CANDLE_HOST || DEFAULT_CANDLE_HOST;

  if (url.hostname === candleHost && (url.pathname === '/' || url.pathname === '/index.html')) {
    url.pathname = '/gallery/';
    return context.env.ASSETS.fetch(new Request(url, context.request));
  }

  return context.next();
}
