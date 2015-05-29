"use strict"

camelize = require 'camelize'
gulpPlugins = require('gulp-load-plugins')()
for pluginName in [
    'gulp', 'connect-resource-pipeline', 'connect-livereload', 'serve-index', 'path'
]
    global[camelize pluginName] = require pluginName

gulp.task 'deploy', ->
  gulp.src('./index.html')
    .pipe(gulpPlugins.ghPages())

gulp.task 'default', ->
    watches = null
    middlewares = [
        # Serve root directory listing
        serveIndex './', icons: true, view: 'details'
        # Add livereload watch to any requested file.
        (request, response, next) ->
            filePath = path.join './', request.url
            if watches?
                watches.add filePath
            else
                watches = gulp.watch filePath, (event) ->
                    gulp.src(event.path).pipe gulpPlugins.connect.reload()
            next()
        # Inject livereload.js to each html asset.
        connectLivereload()
        # Handle source asset requests.
        connectResourcePipeline root: './', [
            url: /.*\.jade$/
            mimeType: 'text/html'
            pipeline: (files) -> jade files
        ]
        connectResourcePipeline root: './', [
            url: /.*\.(scss|sass)$/
            mimeType: 'text/css'
            pipeline: (files) -> sass files
        ]
        connectResourcePipeline root: './', [
            url: /.*\.less$/
            mimeType: 'text/css'
            pipeline: (files) -> less files
        ]
        connectResourcePipeline root: './', [
            url: /.*\.coffee$/
            mimeType: 'text/js'
            pipeline: (files) -> coffeeScript files
        ]
    ]
    # Start the server.
    gulpPlugins.connect.server(
        root: ['./'], middleware: (-> middlewares), port: 8080
        livereload: true
    )
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
