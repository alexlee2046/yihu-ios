import { defineConfig } from 'astro/config';
import react from '@astrojs/react';

export default defineConfig({
  site: 'https://getyihu.com',
  integrations: [react()],
  output: 'static',
  devToolbar: { enabled: false },
});
