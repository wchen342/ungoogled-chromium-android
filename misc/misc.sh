#!/usr/bin/env bash
# This file is not acturally used
# extension is only for syntax highlighting


# Source files: .py, .pyc, .java, .h, .c, .cc, .cpp, .m, .mm, .asm, .rb, .mojom, .hlsl, .bat, .sh, .am, .map, .go, .aidl, .ac, .m4, .idl, .fidl, .yaml, .nc, .el, .tcl
# Media: .png, .gif, .svg, .jpg, .wav, .webp, .webm, .tiff, .bmp, .ico, .icon, .icns, .mp3, .pdf, .flac, .ogg, .ai, .cur, .xcf
# Web: .xml, .css, .htm, .html, .xhtml, .js, .json, .json5, .jsonp, .headers, .xsl, .ttf, .woff, .woff2
# Config files: .info, .golden, .ninja, .gn, .gni, .config, .cfg, .flags, .proto, .ver, .def, .vim, .gradle, gradlew, .jinja, .jinja2, .typemap, .settings, .pydeps
# Other text: .test, .ps1, .pyl, .csv, .ztf, .filter, .asciipb, .version, .skeletons, .fbs, .lst, .list, .sig, .sigs, .fragment, .grd, .grdp, .tmpl, .template, .md5, .sha1, .plist, .xtb, .in, .manifest, .properties, .chromium, .txt, .yml, .md, .diff, .patch, .cmake, Makefile, Dockerfile, pylintrc, resource_ids, .README, README, COPYING, AUTHORS, DEPS, OWNERS, VERSION, LICENSE, PKG-INFO, WORKSPACE, BUILD, .BUILD, .gitignore, .git-blame-ignore-revs


## Create second pruning list
pruning_list_2="pruning_2.list"
pushd src
find . ! '(' -size 0 -o -size 1 -o -name '*.py' -o -name '*.pyc' -o -name '*.java' -o -name '*.h' -o -name '*.c' -o -name '*.cc' -o -name '*.m' -o -name '*.mm' -o -name '*.cpp' -o -name '*.asm' -o -name '*.rb' -o -name '*.mojom' -o -name '*.hlsl' -o -name '*.bat' -o -name '*.sh' -o -name '*.am' -o -name '*.map' -o -name '*.go' -o -name '*.aidl' -o -name '*.ac' -o -name '*.m4' -o -name '*.idl' -o -name '*.fidl' -o -name '*.yaml' -o -name '*.nc' -o -name '*.el' -o -name '*.tcl' -o -iname '*.png' -o -iname '*.gif' -o -name '*.svg' -o -iname '*.jpg' -o -iname '*.wav' -o -name '*.webp' -o -name '*.webm' -o -name '*.tiff' -o -iname '*.bmp' -o -name '*.ico' -o -name '*.icon' -o -name '*.icns' -o -name '*.mp3' -o -name '*.pdf' -o -name '*.flac' -o -name '*.ogg' -o -name '*.ai' -o -name '*.cur' -o -name '*.xcf' -o -name '*.xml' -o -name '*.css' -o -name '*.htm' -o -name '*.html' -o -name '*.xhtml' -o -name '*.js' -o -name '*.json' -o -name '*.json5' -o -name '*.jsonp' -o -name '*.headers' -o -name '*.xsl' -o -name '*.ttf' -o -name '*.woff' -o -name '*.woff2' -o -name '*.info' -o -name '*.golden' -o -name '*.ninja' -o -name '*.gn' -o -name '*.gni' -o -name '*.config' -o -name '*.cfg' -o -name '*.flags' -o -name '*.proto' -o -name '*.ver' -o -name '*.def' -o -name '*.vim' -o -name '*.gradle' -o -name 'gradlew' -o -name '*.jinja' -o -name '*.jinja2' -o -name '*.typemap' -o -name '*.settings' -o -name '*.pydeps' -o -name '*.test' -o -name '*.ps1' -o -name '*.pyl' -o -name '*.csv' -o -name '*.ztf' -o -name '*.filter' -o -name '*.asciipb' -o -name '*.version' -o -name '*.skeletons' -o -name '*.fbs' -o -name '*.lst' -o -name '*.list' -o -name '*.sig' -o -name '*.sigs' -o -name '*.fragment' -o -name '*.grd' -o -name '*.grdp' -o -name '*.tmpl' -o -name '*.template' -o -name '*.md5' -o -name '*.sha1' -o -name '*.plist' -o -name '*.xtb' -o -name '*.in' -o -name '*.manifest' -o -name '*.properties' -o -name '*.chromium' -o -name '*.txt' -o -name '*.yml' -o -name '*.md' -o -name '*.diff' -o -name '*.patch' -o -name '*.cmake' -o -name 'Makefile' -o -name 'Dockerfile' -o -name 'pylintrc' -o -name 'resource_ids' -o -name '*.README' -o -name 'README' -o -name 'COPYING' -o -name 'AUTHORS' -o -name 'DEPS' -o -name 'OWNERS' -o -name 'VERSION' -o -name 'LICENSE' -o -name 'PKG-INFO' -o -name 'WORKSPACE' -o -name 'BUILD' -o -name '*.BUILD' -o -name '.gitignore' -o -name '.git-blame-ignore-revs' ')' -type f -exec grep -IL . "{}" \; | grep -v -E '/\.git/|/test/data/|/test_data/|/examples/|/web_tests/|/testdata/|/eu-strip/|/android_sdk/|/android_tools/|icudtl\.dat|chromium-debug\.keystore|gradle-wrapper\.jar|afdo\.prof|/ulp_language_code_locator/' > "../${pruning_list_2}"
popd


## Create second domain substitution list
substitution_list_temp="domain_sub.tmp"
substitution_list_2="domain_sub_2.list"
pushd src
if [ -f "../${substitution_list_temp}" ] ; then
    rm "../${substitution_list_temp}"
fi
if [ -f "../${substitution_list_2}" ] ; then
    rm "../${substitution_list_2}"
fi
touch "../${substitution_list_temp}"
while read line
do
   line="$(echo "$line" | cut -d '#' -f1)"
   grep -RIl --include="*.gn" --include="*.gni" --include="*.proto" --include="*.def" --include="*.jinja" --include="*.jinja2" --include="*.xml" --include="*.css" --include="*.htm" --include="*.html" --include="*.xhtml" --include="*.js" --include="*.json" --include="*.json5" --include="*.jsonp" --include="*.py" --include="*.java" --include="*.h" --include="*.c" --include="*.cc" --include="*.cpp" --include="*.m" --include="*.mm" --include="*.asm" --include="*.rb" --include="*.mojom" --include="*.hlsl" --include="*.am" --include="*.map" --include="*.go" --include="*.aidl" --include="*.ac" --include="*.m4" --include="*.idl" --include="*.fidl" --include="*.yaml" --include="*.nc" --include="*.el" --include="*.tcl" -P "$line" . | grep -v -E '/\.git/|/android_sdk/|/android_tools/' >> "../${substitution_list_temp}"
done < ../ungoogled-chromium/domain_regex.list
# Not working correctly? awk '{!seen[$0]++};END{for(i in seen) if(seen[i]==1)print i}' "../${substitution_list_temp}" > "../${substitution_list_2}"
sort -u "../${substitution_list_temp}" | uniq > "../${substitution_list_2}"
rm "../${substitution_list_temp}"
popd

