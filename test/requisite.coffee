requisite.walk './test/assets/entry',
  exclude: /storage\/xul|storage\/addon-sdk/
, (err, bundle, required, async, excluded) ->
  log '\ndependencies:'
  log v.absolutePath for k, v of required

  log '\nasync modules:'
  log v.requireAs for k, v of async

  log '\nexcluded modules:'
  log v.absolutePath for k, v of excluded
