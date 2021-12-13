This repo is inspired by https://github.com/lukechilds/dockerpi. 
It tries to be same tool, but made simpler.

## Turn on ssh on local image
By default, on Debian ssh is off. 
It can be enabled on first boot by putting `/boot/ssh` file in image.  

    touch /tmp/ssh
    sudo virt-copy-in -m /dev/sda1 -a /tmp/2021-10-30-raspios-bullseye-armhf-lite.img /tmp/ssh /

## Modify qemu args

To emulate raspberry with custom qemu parameters.

    docker run -p 5022:22 --rm -v /tmp/2021-10-30-raspios-bullseye-armhf-lite.img:/sd.img  \
      --name rpi -it clutroth/dockerpi:vmlatest \
      -m 1024 -M raspi3 \
      -kernel kernel8.img -dtb bcm2710-rpi-3-b-plus.dtb -sd /sd.img \
      -append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait rootfstype=ext4" \
      -nographic \
      -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::22-:22

In fact, this image provides `qemu-system-aarch64`, kernel, and optionally disk image.
You can make use of default configuration or adjust it to your needs.