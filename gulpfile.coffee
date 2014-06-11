pkg     = require('./package.json')
gulp    = require('gulp')
browify = require('gulp-browserify')
coffee  = require('gulp-coffee')
header  = require('gulp-header')
mocha   = require('gulp-mocha')
rename  = require('gulp-rename')
uglify  = require('gulp-uglify')
gutil   = require('gulp-util')

# run tests
gulp.task 'default', ['test']
gulp.task 'test', ->
  gulp.src('test/test-*.coffee', read: false)
      .pipe(mocha(reporter: 'spec'))

# watch tests
gulp.task 'watch', ->
  gulp.watch(['src/**', 'test/**'], ['test'])

# compile coffeescript
gulp.task 'compile', ->
  gulp.src('src/**/*.coffee')
      .pipe(coffee(bare: true).on('error', gutil.log))
      .pipe(gulp.dest('compile'))

# browser compatible version
banner =
  """
  /**
   * <%= pkg.name %> v<%= pkg.version %>
   * <%= pkg.description %>
   * <%= pkg.homepage %>
   * Copyright (c) 2014 <%= pkg.owner %>, Licensed under <%= pkg.license %>
   */

  """
gulp.task 'build', ['compile'], ->
  gulp.src('compile/index.js', read: false)
      .pipe(browify())
      .pipe(rename('pmpsdk.js'))
      .pipe(header(banner, pkg: pkg))
      .pipe(gulp.dest('build'))
      .pipe(uglify())
      .pipe(header(banner, pkg: pkg))
      .pipe(rename('pmpsdk.min.js'))
      .pipe(gulp.dest('build'))
