const webpack = require('webpack');
const path = require('path')

module.exports = {
	entry: './src/index.js',
	output: {
		path: path.resolve(__dirname, 'dist/bundles/'),
		publicPath: '/bundles/',
		filename: '[name].js'
	},
	module: {
		rules: [
			{
				test: /\.tag$/,
				exclude: /node_modules/,
				use: {
					loader: 'riot-tag-loader',
				}
			},
			{
				test: /\.js$/,
				exclude: /node_modules/,
				use: {
					loader: 'babel-loader',
					options: {
						presets: ['env']
					}
				}
			},
			{
				test: /\.css$/,
				use: ['style-loader', 'css-loader']
			},
			{
				test: /\.(ttf|eot|woff|otf|svg)$/,
				use: {
					loader: 'url-loader',
					options: {
						limit: 8192,
					}
				}
			}
		]
	},
	plugins: [
		new webpack.EnvironmentPlugin([
			'DEBUG',
		]),
	],
};
