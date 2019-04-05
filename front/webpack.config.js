const webpack = require('webpack');
const path = require('path')
const BundleTracker = require('webpack-bundle-tracker')

module.exports = {
	entry: './app/index.js',
	output: {
		path: path.resolve(__dirname, 'assets/bundles/'),
		publicPath: '/static/bundles/',
		filename: '[name]-[hash].js'
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
			'TITLE',
		]),
		new BundleTracker({path: __dirname, filename: './assets/webpack-stats.json'}),
	],
};
