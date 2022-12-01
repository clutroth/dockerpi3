FROM ubuntu:22.04 AS image
ENV IMG_URL="http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf-lite.zip"
ENV IMG_SHA256="008d7377b8c8b853a6663448a3f7688ba98e2805949127a1d9e8859ff96ee1a9"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq install libguestfs-tools linux-image-generic qemu-utils unzip  wget

RUN wget --quiet -O raspios-bullseye-armhf-lite.zip ${IMG_URL}
RUN echo "${IMG_SHA256} raspios-bullseye-armhf-lite.zip" | sha256sum --check
RUN unzip raspios-bullseye-armhf-lite.zip

ENV LIBGUESTFS_BACKEND=direct
RUN virt-copy-out -m /dev/sda1 -a *-raspios-bullseye-armhf-lite.img /kernel8.img /bcm2710-rpi-3-b-plus.dtb ./
RUN touch /tmp/ssh
RUN virt-copy-in -m /dev/sda1 -a *-raspios-bullseye-armhf-lite.img /tmp/ssh /

FROM alpine:3.17.0 AS vm
RUN apk add --no-cache qemu-system-aarch64
COPY --from=image kernel8.img kernel8.img
COPY --from=image bcm2710-rpi-3-b-plus.dtb bcm2710-rpi-3-b-plus.dtb
EXPOSE 5022
CMD ["-m", "1024", "-M", "raspi3", \
  "-kernel", "kernel8.img", "-dtb", "bcm2710-rpi-3-b-plus.dtb", "-sd", "/sd.img", \
  "-append", "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4", \
  "-nographic", \
  "-device", "usb-net,netdev=net0", "-netdev", "user,id=net0,hostfwd=tcp::5022-:22" \
  ]

ENTRYPOINT ["qemu-system-aarch64"]

FROM vm AS full
RUN apk add --no-cache qemu-img
COPY --from=image *-raspios-bullseye-armhf-lite.img /sd.img
RUN qemu-img resize /sd.img 2G
