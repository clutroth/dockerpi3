FROM vm
RUN apk add --no-cache qemu-img
COPY --from=image *-raspios-bullseye-armhf-lite.img /sd.img
RUN qemu-img resize /sd.img 2G
