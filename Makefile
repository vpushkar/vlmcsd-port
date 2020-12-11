# Created by: Volodymyr Pushkar <vladimir.pushkar@gmail.com>
# $FreeBSD: head/sysutils/vlmcsd/Makefile 460016 2020-01-27 18:10:51Z sunpoet $

PORTNAME=	vlmcsd
PORTVERSION=	1113
CATEGORIES=	sysutils

MAINTAINER=	vladimir.pushkar@gmail.com
COMMENT=	KMS Emulator for Microsoft products in C

LICENSE=	GPLv2

USES=           gmake
MAKE_JOBS_UNSAFE=yes
USE_RC_SUBR=    vlmcsd

PLIST_FILES=	bin/vlmcs sbin/vlmcsd man/man1/vlmcs.1.gz \
		man/man7/vlmcsd.7.gz man/man8/vlmcsd.8.gz \
		man/man5/vlmcsd.ini.5.gz etc/vlmcsd/vlmcsd.ini.sample \
		etc/vlmcsd/vlmcsd.kmd.sample

USE_GITHUB=	yes
GH_ACCOUNT=	Wind4
GH_PROJECT=	vlmcsd
GH_TAGNAME=	svn1113

MAKE_ARGS=	INI=/usr/local/etc/vlmcsd/vlmcsd.ini\
		DATA=/usr/local/etc/vlmcsd/vlmcsd.kmd\
		VERBOSE=3

OPTIONS_DEFINE= STATIC GCC
OPTIONS_DEFAULT=STATIC
OPTIONS_SUB=    yes

STATIC_DESC=	build static binary
GCC_DESC=	build with gcc

.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MGCC}
USE_GCC=	yes
MAKE_ARGS+=	CFLAGS="-flto=12 -static-libgcc -pipe -fwhole-program -fno-common -fno-exceptions -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables -fmerge-all-constants"
.else
MAKE_ARGS+=	CC=clang CFLAGS="-pipe -fno-common -fno-exceptions -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables -fmerge-all-constants"
LDVAR=	"-lpthread"
.endif

.if ${PORT_OPTIONS:MSTATIC}
LDVAR+=	"-static"
.endif

LDVAR+="-Wl,-z,norelro -Wl,--hash-style=gnu -Wl,--build-id=none"

MAKE_ARGS+= LDFLAGS="${LDVAR}"

do-install:
	@${MKDIR} ${STAGEDIR}${PREFIX}/etc/vlmcsd
	${INSTALL_PROGRAM} ${WRKSRC}/bin/vlmcs ${STAGEDIR}${PREFIX}/bin
	${INSTALL_PROGRAM} ${WRKSRC}/bin/vlmcsd ${STAGEDIR}${PREFIX}/sbin
	@${AWK} '{ sub(/(\r$)/, ""); print }' ${WRKSRC}/etc/vlmcsd.ini > ${STAGEDIR}${PREFIX}/etc/vlmcsd/vlmcsd.ini.sample
	${INSTALL_DATA} ${WRKSRC}/etc/vlmcsd.kmd ${STAGEDIR}${PREFIX}/etc/vlmcsd/vlmcsd.kmd.sample
	${INSTALL_MAN} ${WRKSRC}/man/vlmcs.1 ${STAGEDIR}${MANPREFIX}/man/man1
	${INSTALL_MAN} ${WRKSRC}/man/vlmcsd.ini.5 ${STAGEDIR}${MANPREFIX}/man/man5
	${INSTALL_MAN} ${WRKSRC}/man/vlmcsd.7 ${STAGEDIR}${MANPREFIX}/man/man7
	${INSTALL_MAN} ${WRKSRC}/man/vlmcsd.8 ${STAGEDIR}${MANPREFIX}/man/man8

.include <bsd.port.mk>
