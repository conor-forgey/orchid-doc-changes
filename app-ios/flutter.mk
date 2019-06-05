# Orchid - WebRTC P2P VPN Market (on Ethereum)
# Copyright (C) 2017-2019  The Orchid Authors

# GNU Affero General Public License, Version 3 {{{ */
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# }}}


ifeq ($(target),sim)
mode := debug
else
mode := release
endif

assets := $(bundle)/Frameworks/App.framework/flutter_assets

include shared/flutter.mk

$(bundle)/Frameworks/App.framework/Info.plist: flutter/packages/flutter_tools/templates/app/ios.tmpl/Flutter/AppFrameworkInfo.plist
	@mkdir -p $(dir $@)
	cp -af $< $@
	touch $@

$(bundle)/Frameworks/App.framework/App:
	@mkdir -p $(dir $@)
	echo "static const int Moo = 88;" | $(cycc) -dynamiclib -o $@ \
	    -x c - -Wno-unused-const-variable \
	    -Xlinker -rpath -Xlinker '@executable_path/Frameworks' \
	    -Xlinker -rpath -Xlinker '@loader_path/Frameworks' \
	    -install_name '@rpath/App.framework/App'

signed += $(bundle)/Frameworks/App.framework$(signature)
$(bundle)/Frameworks/App.framework$(signature): $(output)/ents-$(target)-dart.xml $(bundle)/Frameworks/App.framework/Info.plist $(bundle)/Frameworks/App.framework/App $(assets)/kernel_blob.bin
	@rm -rf $(dir $@)
	$(environ) codesign --deep -fs $(codesign) --entitlement $< -v $(bundle)/Frameworks/App.framework
	@touch $@

$(bundle)/Frameworks/Flutter.framework/Flutter: flutter/bin/cache/artifacts/engine/ios/Flutter.framework/Flutter
	@mkdir -p $(dir $@)
	$(environ) lipo $(patsubst %,-extract %,$(arch)) $< -output $@
	@touch $@

$(bundle)/Frameworks/Flutter.framework/%: flutter/bin/cache/artifacts/engine/ios/Flutter.framework/%
	@mkdir -p $(dir $@)
	cp -af $< $@
	touch $@

signed += $(assets)/kernel_blob.bin
build/app%dill %flutter-plugins $(assets)/kernel_blob%bin ios/Runner/GeneratedPluginRegistrant%m: $(shell find lib/ -name '*.dart') flutter/packages/flutter/pubspec%lock pubspec%lock
	rm -rf build $(assets) $(output)/snapshot_blob.bin.d $(output)/snapshot_blob.bin.d.fingerprint
	@mkdir -p build $(output) $(assets)
	$(environ) flutter/bin/flutter --suppress-analytics --verbose build bundle --target-platform=ios --target=lib/main.dart --$(mode) --depfile="$(output)/snapshot_blob.bin.d" --asset-dir="$(assets)"

# XXX: -include out-ios/snapshot_blob.bin.d

flutter := Flutter Info.plist icudtl.dat

$(patsubst %,flutter/bin/cache/artifacts/engine/ios/Flutter.framework/%,$(flutter)): .flutter-plugins

signed += $(bundle)/Frameworks/Flutter.framework$(signature)
$(bundle)/Frameworks/Flutter.framework$(signature): $(output)/ents-$(target)-flutter.xml $(patsubst %,$(bundle)/Frameworks/Flutter.framework/%,$(flutter))
	@rm -rf $(dir $@)
	$(environ) codesign --deep -fs $(codesign) --entitlement $< -v $(bundle)/Frameworks/Flutter.framework
	@touch $@
