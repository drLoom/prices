const {environment} = require('@rails/webpacker')

// environment.splitChunks((config) => Object.assign({}, config, {
//     optimization:
//         {splitChunks: {chunks: 'all'}}
// }))

const webpack = require('webpack')
environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
        $: "jquery",
        jQuery: "jquery"
    })
)

module.exports = environment
