# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mv_mozextension-r1
RESTRICT="mirror"

DESCRIPTION="legacy add-on: edit the saved history of forms"
HOMEPAGE="http://www.formhistory.blogspot.com/"
SRC_URI="https://addons.cdn.mozilla.net/user-media/addons/12021/${PN//-/_}-${PV}-sm+fx.xpi"

LICENSE="MPL-1.1"
SLOT="legacy"
KEYWORDS="~amd64 ~x86"
IUSE=""

moz_defaults palemoon
