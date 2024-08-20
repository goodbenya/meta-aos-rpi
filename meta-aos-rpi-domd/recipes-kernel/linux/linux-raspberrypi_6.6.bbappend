FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://aos.cfg \
    file://optee.cfg \
"
