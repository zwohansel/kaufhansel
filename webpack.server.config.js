const nodeExternals = require("webpack-node-externals");
const path = require("path");

module.exports = {
  target: "node",
  context: path.resolve(__dirname, "./src/server"),
  entry: "./main.ts",
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: "ts-loader",
        exclude: /node_modules/
      },
      {
        enforce: "pre",
        test: /\.(js|tsx?)$/,
        exclude: /node_modules/,
        loader: "eslint-loader"
      },
      {
        test: /\.(graphql|gql)$/,
        exclude: /node_modules/,
        loader: "graphql-tag/loader"
      }
    ]
  },
  output: {
    path: path.resolve(__dirname, "build"),
    filename: "main.js"
  },
  resolve: {
    extensions: [".ts", ".js"]
  },
  externals: [nodeExternals()]
};
