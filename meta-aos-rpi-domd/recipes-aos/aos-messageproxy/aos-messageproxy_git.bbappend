FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://optee-identity.conf \
"

FILES:${PN} += " \
    ${sysconfdir} \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/system/${PN}.service.d
    install -m 0644 ${WORKDIR}/optee-identity.conf ${D}${sysconfdir}/systemd/system/${PN}.service.d/10-optee-identity.conf
}
