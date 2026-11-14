// Retired download URLs keep an explicit HTTP response instead of empty sample files.
export default function retiredSample(_request, response) {
  response.setHeader('Content-Type', 'text/plain; charset=utf-8');
  response.setHeader('X-Robots-Tag', 'noindex');
  response.statusCode = 410;
  response.end('This sample has been retired. See https://getyihu.com/ for current guides.\n');
}
