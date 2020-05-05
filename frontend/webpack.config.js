const HtmlWebPackPlugin = require("html-webpack-plugin");
const CopyWebPackPlugin = require("copy-webpack-plugin");
const path = require("path");

module.exports = {
  target: "web",
  context: path.resolve(__dirname, "./src"),
  entry: "./index.tsx",
  devtool: "inline-source-map",
  module: {
    rules: [
      {
        test: /\.(js|jsx|tsx?)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-env", "@babel/preset-react", "@babel/preset-typescript"],
            plugins: [
              [
                "import",
                {
                  libraryName: "antd",
                  libraryDirectory: "es",
                  style: "css"
                }
              ]
            ]
          }
        }
      },
      {
        test: /\.html$/,
        use: "html-loader"
      },
      {
        test: /\.tsx?$/,
        use: "ts-loader",
        exclude: /node_modules/
      },
      {
        test: /\.js$/,
        use: ["source-map-loader"],
        enforce: "pre"
      },
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"]
      },
      {
        enforce: "pre",
        test: /\.(js|tsx?)$/,
        exclude: /node_modules/,
        loader: "eslint-loader"
      }
    ]
  },
  resolve: {
    extensions: [".tsx", ".ts", ".js"]
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: "./public/index.html",
      filename: "./index.html"
    }),
    new CopyWebPackPlugin([{ from: "public" }])
  ],
  output: {
    path: path.resolve(__dirname, "build/"),
    filename: "main.js"
  },
  devServer: {
    https: true,
    contentBase: path.join(__dirname, "public"),
    port: 8081,
    historyApiFallback: true,
    proxy: {
      "/graphql": {
        target: "https://localhost:8080/",
        secure: false,
        changeOrigin: true
      }
    }
  },
  optimization: {
    splitChunks: {
      cacheGroups: {
        commons: {
          test: /[\\/]node_modules[\\/]/,
          name: "vendors",
          chunks: "all"
        }
      }
    }
  }
};
