/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './*.html',
    './landing-i18n.js',
    './landing-i18n-runtime-embed.js',
  ],
  theme: {
    extend: {
      colors: {
        gold: {
          300: '#fcd34d',
          400: '#fbbf24',
          500: '#f59e0b',
        },
      },
    },
  },
  plugins: [],
};
