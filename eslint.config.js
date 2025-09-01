module.exports = [
  {
    files: ["*.ts", "*.tsx", "*.js", "*.jsx"],
    ignores: ["node_modules/**", "dist/**"],
    languageOptions: {
      parser: "@typescript-eslint/parser",
      parserOptions: {
        ecmaVersion: 2018,
        sourceType: "module",
      },
    },
    plugins: {
      "@typescript-eslint": require("@typescript-eslint/eslint-plugin"),
      prettier: require("eslint-plugin-prettier"),
    },
    rules: {
      "@typescript-eslint/no-explicit-any": "off",
      "prettier/prettier": "error",
    },
    extends: ["plugin:@typescript-eslint/recommended", "plugin:prettier/recommended"],
  },
];
