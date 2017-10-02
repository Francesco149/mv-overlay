# Copyright 2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
WANT_LIBTOOL=none
AUTOTOOLS_AUTO_DEPEND=no
MESON_AUTO_DEPEND=no
PLOCALES="de ru"
inherit autotools bash-completion-r1 l10n meson_optional tmpfiles toolchain-funcs

case ${PV} in
99999999*)
	EGIT_REPO_URI="https://github.com/vaeth/${PN}.git"
	inherit git-r3
	SRC_URI=""
	PROPERTIES="live";;
*)
	RESTRICT="mirror"
	EGIT_COMMIT="a3c5b4b9ba0aa2add69e00a8511197c211baf4a2"
	SRC_URI="https://github.com/vaeth/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-${EGIT_COMMIT}";;
esac

DESCRIPTION="Search and query ebuilds"
HOMEPAGE="https://github.com/vaeth/eix/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug +dep doc +meson nls optimization +required-use security strong-optimization strong-security sqlite swap-remote tools"

BOTHDEPEND="nls? ( virtual/libintl )
	sqlite? ( >=dev-db/sqlite-3:= )"
RDEPEND="${BOTHDEPEND}
	>=app-shells/push-2.0-r2
	>=app-shells/quoter-3.0-r2"
DEPEND="${BOTHDEPEND}
	meson? (
		>=dev-util/meson-0.41.0
		>=dev-util/ninja-1.7.2
	)
	!meson? ( ${AUTOTOOLS_DEPEND} )
	>=sys-devel/gettext-0.19.6"

mesonflto() {
	use meson && use strong-optimization || return 0
	einfo "Checking whether compiler supports -flto and static archives"
	local -x AR=$(tc-getAR)
	local -x CXX=$(tc-getCXX)
	bash contrib/meson-flto-test.sh && return
	eerror "For app-portage/eix[meson strong-optimization] it is necessary"
	eerror "that your compiler can access static archives with -flto."
	eerror "This is perhaps not the case on your system:"
	eerror "A linker lto plugin might be required."
	eerror "To establish this plugin, execute as root something like"
	eerror "	mkdir -p /usr/*/binutils-bin/lib/bfd-plugins"
	eerror "	cd /usr/*/binutils-bin/lib/bfd-plugins"
	eerror "	ln -sfn /usr/libexec/gcc/*/*/liblto_plugin.so.*.*.* ."
	die "app-portage/eix[meson strong-optimization] requires flto plugin"
}

pkg_setup() {
	# remove stale cache file to prevent collisions
	local old_cache="${EROOT}var/cache/${PN}"
	test -f "${old_cache}" && rm -f -- "${old_cache}"
}

src_prepare() {
	sed -i -e "s'/'${EPREFIX}/'" -- "${S}"/tmpfiles.d/eix.conf || die
	default
	use meson || {
		eautopoint
		eautoreconf
	}
	mesonflto
}

src_configure() {
	local emesonargs
	emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${P}" \
		-Dhtmldir="${EPREFIX}/usr/share/doc/${P}/html" \
		-Dsqlite=$(usex sqlite true false) \
		-Dextra-doc=$(usex doc true false) \
		-Dnls=$(usex nls true false) \
		-Dseparate-tools=$(usex tools true false) \
		-Dsecurity=$(usex security true false) \
		-Doptimization=$(usex optimization true false) \
		-Dstrong-secutiry=$(usex strong-security true false) \
		-Dstrong-optimization=$(usex strong-optimization true false) \
		-Ddebugging=$(usex debug true false) \
		-Dswap-remote=$(usex swap-remote true false) \
		-Dalways-accept-keywords=$(usex prefix true false) \
		-Ddep-default=$(usex dep true false) \
		-Drequired-use-default=$(usex required-use true false) \
		-Dzsh-completion="${EPREFIX}/usr/share/zsh/site-functions" \
		-Dportage-rootpath="${ROOTPATH}" \
		-Deprefix-default="${EPREFIX}"
	)
	if use meson; then
		meson_src_configure
	else
		econf \
		$(use_with sqlite) \
		$(use_with doc extra-doc) \
		$(use_enable nls) \
		$(use_enable tools separate-tools) \
		$(use_enable security) \
		$(use_enable optimization) \
		$(use_enable strong-security) \
		$(use_enable strong-optimization) \
		$(use_enable debug debugging) \
		$(use_enable swap-remote) \
		$(use_with prefix always-accept-keywords) \
		$(use_with dep dep-default) \
		$(use_with required-use required-use-default) \
		--with-zsh-completion \
		--with-portage-rootpath="${ROOTPATH}" \
		--with-eprefix-default="${EPREFIX}"
	fi
}

src_compile() {
	if use meson; then
		meson_src_compile
	else
		default
	fi
}

src_test() {
	if use meson; then
		meson_src_test
	else
		default
	fi
}

src_install() {
	if use meson; then
		meson_src_install
	else
		default
	fi
	dobashcomp bash/eix
	dotmpfiles tmpfiles.d/eix.conf
}

pkg_postinst() {
	local obs="${EROOT}var/cache/eix.previous"
	if test -f "${obs}"; then
		ewarn "Found obsolete ${obs}, please remove it"
	fi
	tmpfiles_process eix.conf
}

pkg_postrm() {
	if [ -z "${REPLACED_BY_VERSION}" ]; then
		rm -rf -- "${EROOT}var/cache/${PN}"
	fi
}