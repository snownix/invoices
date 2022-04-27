module.exports = {
  darkMode: "class",
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#4353FF',
        secondary: '#52B6BC',
        dark: '#404865',
        light: '#ffffff',
        black: '#2F2F2F',
        low: 'rgb(107 114 128)'
      }
    },
    fontFamily: {
      primary: ['Inter', 'sans-serif']
    }
  },
  plugins: [
    // require('@tailwindcss/typography'),
  ]
}