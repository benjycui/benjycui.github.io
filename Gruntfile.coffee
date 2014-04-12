module.exports = (grunt) ->
  grunt.initConfig
    stylus:
      compile:
        options:
          compress: true
        files: './styles/screen.min.css': './styles/screen.styl'

    less:
      compile:
        options:
          cleancss: true
        files: './styles/screen.min.css': './styles/screen.less'

    coffee:
      compile:
        options:
          join: true
          bare: true
        files: './scripts/app.js': './scripts/*.coffee'

    uglify:
      compress:
        files: './scripts/app.min.js': './scripts/app.js'

    watch:
      stylus:
        files: './styles/*.styl'
        tasks: 'stylus'
      less:
        files: './styles/*.less'
        tasks: 'less'

      coffee:
        files: './scripts/*.coffee'
        tasks: 'coffee'

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', ['watch']
  grunt.registerTask 'publish', ['uglify']

  return
