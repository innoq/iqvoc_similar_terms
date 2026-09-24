// Entry point for the esbuild build script in package.json - this is what
// Propshaft actually serves for iqvoc_similar_terms' own standalone use.
// Other gems importing 'iqvoc_similar_terms' get ./manifest instead - the
// same content minus starting Rails/UJS.
import Rails from '@rails/ujs'
Rails.start()

import './manifest'
