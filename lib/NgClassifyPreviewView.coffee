{EditorView} = require 'atom'
_            = require 'underscore-plus'
path         = require 'path'
resourcePath = atom.config.resourcePath
Editor       = require path.resolve resourcePath, 'src', 'editor'
ngClassify   = require 'ng-classify'
TextBuffer   = require path.resolve resourcePath, 'node_modules', 'text-buffer'

class PreviewView extends EditorView
	constructor: ({@editorId, filePath}) ->
		buffer         = new TextBuffer
		@previewEditor = new Editor buffer: buffer
		grammar        = atom.syntax.grammarForScopeName 'source.coffee'

		@previewEditor.setGrammar grammar

		super @previewEditor

		atom.workspaceView.on 'pane-container:active-pane-item-changed', @handleTabChanges

		@debouncedRenderPreview = _.debounce @renderPreview.bind(@), 100

	destroy: ->
		@unsubscribe()
		atom.workspaceView.off 'pane-container:active-pane-item-changed', @handleTabChanges

	getTitle: ->
		'ng-classify Preview'

	focus: ->
		false

	changeHandler: =>
		@debouncedRenderPreview()

	handleEvents: ->
		if @editor?
			@subscribe @editor.getBuffer(), 'contents-modified', @changeHandler

			@subscribe @editor, 'path-changed', =>
				@trigger 'title-changed'

	handleTabChanges: =>
		if @previewEditor?
			@unsubscribe()
			@handleEvents()
			@changeHandler()

	renderPreview: =>
		@trigger 'title-changed'

		cEditor = atom.workspace.getActiveEditor()

		if cEditor?
			@trigger 'title-changed'

			text     = cEditor.getText()
			compiled = ngClassify text
			compiled = compiled + '\n'

			@previewEditor.setText compiled

module.exports = PreviewView