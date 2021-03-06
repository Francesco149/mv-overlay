# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit latex-package
RESTRICT="mirror"

DESCRIPTION="Finds useless references in latex files or unnecessarily numbered environments"
HOMEPAGE="http://www-ljk.imag.fr/membres/Jerome.Lelong/soft/chklref/index.html"
SRC_URI="http://www-ljk.imag.fr/membres/Jerome.Lelong/soft/chklref/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="virtual/latex-base
	dev-lang/perl"
DEPEND="${RDEPEND}"

DOCS=( README )

src_prepare() {
	use prefix || sed -i \
		-e '1s"^#!/usr/bin/env sh$"#!'"${EPREFIX}/bin/sh"'"' \
		-- "${S}"/src/chklref.in || die
	eapply_user
}

src_configure() {
	econf --with-texmf-prefix="${EPREFIX}${TEXMF}"
}

src_compile() {
	default
}

src_install() {
	default
}
