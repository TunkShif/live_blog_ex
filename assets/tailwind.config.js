module.exports = {
  mode: "jit",
  purge: ["./js/**/*.js", "../lib/*_web/**/*.heex", "../lib/*_web/**/*.ex"],
  darkMode: "class", // or 'media' or 'class'
  theme: {
    fontFamily: {
      mono: [
        "IBM Plex Mono",
        "ui-monospace",
        "SFMono-Regular",
        "Menlo",
        "Monaco",
        "Consolas",
        "Liberation Mono",
        "Courier New",
        "monospace",
      ],
    },
    extend: {
      colors: {
        silver: "#a9b4c6",
        whitesmoke: "#f0f3f5",
        slategray: "#838892",
        dogerblue: "#1b95e0",
        cornflower: "#5cb1f7",
      },
      fontFamily: {
        cursive: ["Pacifico"],
        oswald: ["Oswald"],
        outfit: ["Outfit"],
      },
      listStyleType: {
        square: "square",
      },
      typography: (theme) => ({
        DEFAULT: {
          css: {
            a: {
              color: theme("colors.dogerblue"),
            },
            h1: {
              fontFamily: "Outfit",
              color: theme("colors.gray.700"),
            },
            h2: {
              fontFamily: "Outfit",
              color: theme("colors.gray.700"),
            },
            h3: {
              fontFamily: "Outfit",
              color: theme("colors.gray.700"),
            },
            h4: {
              fontFamily: "Outfit",
              color: theme("colors.gray.700"),
            },
            h5: {
              fontFamily: "Outfit",
            },
            h6: {
              fontFamily: "Outfit",
            },
          },
        },
      }),
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require("@tailwindcss/typography")],
};
