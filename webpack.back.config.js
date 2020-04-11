const nodeExternals = require("webpack-node-externals");
const path = require("path");

module.exports = {
  target: "node",
  entry: "./src/server.ts",
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
    filename: "server.js"
  },
  externals: [nodeExternals()]
};
