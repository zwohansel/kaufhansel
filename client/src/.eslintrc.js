module.exports = {
  env: {
    browser: true,
    es6: true,
    node: true
  },
  extends: [
    "standard",
    "plugin:react/recommended",
    "prettier",
    "plugin:jest/recommended"
  ],
  globals: {
    Atomics: "readonly",
    SharedArrayBuffer: "readonly"
  },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    },
    ecmaVersion: 2018,
    sourceType: "module"
  },
  plugins: ["react", "@typescript-eslint", "jest"],
  rules: {
    semi: "off",
    quotes: ["error", "double"],
    "space-before-function-paren": "off",
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": "error",
    "no-useless-constructor": "off",
    "@typescript-eslint/no-useless-constructor": "error"
  },
  settings: {
    react: {
      version: "detect"
    }
  }
};
