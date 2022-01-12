module.exports = {
  content: ['./js/**/*.js', '../lib/*_web/**/*.heex', '../lib/*_web/**/*.ex'],
  theme: {
    fontFamily: {
      mono: [
        'IBM Plex Mono',
        'ui-monospace',
        'SFMono-Regular',
        'Menlo',
        'Monaco',
        'Consolas',
        'Liberation Mono',
        'Courier New',
        'monospace'
      ]
    },
    extend: {
      colors: {
        silver: '#a9b4c6',
        whitesmoke: '#f0f3f5',
        slategray: '#838892',
        dogerblue: '#1b95e0'
      },
      fontFamily: {
        oswald: ['Oswald'],
        outfit: ['Outfit']
      },
      listStyleType: {
        square: 'square'
      }
    }
  },
  plugins: [require('@tailwindcss/typography')]
}
