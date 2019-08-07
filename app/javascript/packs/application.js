// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

import Rails from 'rails-ujs'
import Turbolinks from 'turbolinks'

require("channels")
require("jquery")
require("datatables.net");

require("estate/estate_table")

const application = Application.start()
const context = require.context("controllers", true, /.js$/)
application.load(definitionsFromContext(context))

Turbolinks.start()
Rails.start()