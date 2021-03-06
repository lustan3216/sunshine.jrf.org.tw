path     = require 'path'
gulp     = require 'gulp'
replace  = require 'gulp-replace'
notify   = require 'gulp-error-notifier'
{ exec } = require "child_process"
# responsive = require 'gulp-responsive'

#
# 修改路徑來使用 Rails Sprockets path helper
# START

# 取得 publicPath
{ publicPath } = require './package.json'

gulp.task 'resolve-url', ->
  sourcemap_pattern = /\/\*#\ssourceMappingURL.+\*\//ig

  assets_pattern    = ///
    url\(
      #{publicPath}
      images\/
      (.+\.(png|jpe?g|gif|svg))
    \)
  ///ig

  replace_assets_path = (_full, $1) ->
    result = "asset-url('#{$1}')"
    console.log """
      Resolve: #{_full}
      To: #{result}
    """
    result

  gulp.src path.join("app/assets", "stylesheets/webpack_*.+(css|scss)")
      .pipe notify.handleError replace(assets_pattern, replace_assets_path)
      .pipe notify.handleError replace(sourcemap_pattern, "")
      .pipe gulp.dest path.join("app/assets", "stylesheets")

# 修改路徑來使用 Rails Sprockets path helper
# END
#

run = (cmd, cb) ->
  task = exec cmd
  task.stdout.on "data", (data) -> console.log data.toString()
  task.stderr.on "data", (data) -> console.log data.toString()
  task.on "exit", -> cb()

gulp.task 'update', (cb) ->
  run "git add -A --ignore-errors && git commit -m 'Precompile f2e assets.'", cb

#
# Build Responsive Image
# START

# 產生 retina list
# retina = (width) -> [{
#   width: width
# },{
#   width: width * 2
#   rename: { prefix: "2x_" }
# }]

# gulp.task 'responsive', ->
#   gulp.src 'client/lorem/*.{png,jpg}'
#     .pipe responsive
#       'demo_*.jpg': retina(1920)
#     .pipe gulp.dest 'app/assets/images/lorem'
