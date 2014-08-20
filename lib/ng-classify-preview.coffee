PreviewView = require './NgClassifyPreviewView'
url         = require 'url'

preview =
	activate: (state) ->
		lang = null

		atom.workspaceView.command 'ng-classify-preview:coffee', =>
			lang = 'coffee'
			@toggle()

		atom.workspaceView.command 'ng-classify-preview:js', =>
			lang = 'js'
			@toggle()

		atom.workspace.registerOpener (uriToOpen) =>
			try
				{protocol, host, pathname} = url.parse uriToOpen
			catch error
				return

			return unless protocol is 'ng-classify-preview:'

			try
				pathname = decodeURI(pathname) if pathname
			catch error
				return

			if host is 'editor'
				new PreviewView {lang, editorId: pathname.substring 1}
			else
				new PreviewView {lang, filePath: pathname}

	toggle: ->
		editor = atom.workspace.getActiveEditor()

		return unless editor?

		uri         = "ng-classify-preview://editor/#{editor.id}"
		previewPane = atom.workspace.paneForUri uri

		return if previewPane
			previewPane.destroyItem previewPane.itemForUri uri

		previousActivePane = atom.workspace.getActivePane()

		atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (previewView) ->
			if previewView instanceof PreviewView
				previewView.renderPreview()
				previousActivePane.activate()

module.exports = preview