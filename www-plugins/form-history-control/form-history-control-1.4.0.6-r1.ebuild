# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

MY_P="${P/-/_}"
MY_P="${MY_P/-/_}"
NAME="${MY_P}-sm+fx.xpi"
DESCRIPTION="<firefox-57 add-on: edit the saved history of forms"
HOMEPAGE="http://www.formhistory.blogspot.com/"
SRC_URI="http://addons.cdn.mozilla.net/user-media/addons/12021/${NAME}"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults '<firefox-57' palemoon seamonkey