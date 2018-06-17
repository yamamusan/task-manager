const { environment } = require('@rails/webpacker')
const vue =  require('./loaders/vue')
const webpack = require('webpack')

environment.loaders.append('vue', vue)
environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Tether: 'tether',
    'window.Tether': 'tether',
    Popper: ['popper.js', 'default']
  })
)
module.exports = environment
