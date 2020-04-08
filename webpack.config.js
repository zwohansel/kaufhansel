const HtmlWebPackPlugin = require("html-webpack-plugin");
const CopyWebPackPlugin = require("copy-webpack-plugin");
const path = require("path");

module.exports = {
  entry: "./src/index.tsx",
  devtool: "inline-source-map",
  module: {
    rules: [
      {
        test: /\.(js|jsx|tsx?)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: [
              "@babel/preset-env",
              "@babel/preset-react",
              "@babel/preset-typescript",
            ],
            plugins: [
              [
                "import",
                {
                  libraryName: "antd",
                  libraryDirectory: "es",
                  style: "css",
                },
              ],
            ],
          },
        },
      },
      {
        test: /\.html$/,
        use: "html-loader",
      },
      {
        test: /\.tsx?$/,
        use: "ts-loader",
        exclude: /node_modules/,
      },
      {
        test: /\.js$/,
        use: ["source-map-loader"],
        enforce: "pre",
      },
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"],
      },
    ],
  },
  resolve: {
    extensions: [".tsx", ".ts", ".js"],
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: "./public/index.html",
      filename: "./index.html",
    }),
    new CopyWebPackPlugin([{ from: "public" }]),
  ],
  output: {
    path: path.resolve(__dirname, "build"),
    filename: "main.js",
  },
  devServer: {
    contentBase: path.join(__dirname, "public"),
  },
};
