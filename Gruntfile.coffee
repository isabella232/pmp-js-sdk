#
# grunt config
#
module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    # banner for built files
    banner:
      """
      # ==============================================================
      # <%= pkg.title %> v<%= pkg.version %>
      # <%= pkg.description %>
      # <%= pkg.homepage %>
      # ==============================================================
      # Copyright (c) 2014 <%= pkg.author %>
      # Licensed under http:#en.wikipedia.org/wiki/MIT_License
      # ==============================================================
      """
    bannerjs: "<%= banner.replace(/^#/gm, '//') %>"

    # clean build directory
    clean:
      build: 'build'

    # coffeescript compiling
    coffee:
      compile:
        files:
          'build/pmpsdk.js' : 'src/pmpsdk.coffee'

    # banner for the build files (with the correct kind of comments)
    wrap:
      js:
        src: 'build/pmpsdk.js'
        dest: '.'
        options: wrapper: ['<%= bannerjs %>', '']
      coffee:
        src: 'src/pmpsdk.coffee'
        dest: 'build/pmpsdk.coffee'
        options: wrapper: ['<%= banner %>', '']

    # minify js
    uglify:
      options: banner: '<%= bannerjs %>\n'
      build:
        src: 'build/pmpsdk.js'
        dest: 'build/pmpsdk.min.js'

    # watcher
    watch:
      mochaWatch:
        files: ['src/**/*.coffee', 'test/**/*.coffee']
        tasks: ['test']

    # tests
    mochaTest:
      mocha:
        options:
          reporter: 'spec',
          require: 'coffee-script/register'
        src: 'test/**/*.coffee'

  # externals
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.loadNpmTasks('grunt-wrap')

  # test
  grunt.registerTask 'test', ['mochaTest']

  # build
  grunt.registerTask 'build', ['clean', 'coffee', 'wrap', 'uglify']
  grunt.registerTask 'default', ['build']

