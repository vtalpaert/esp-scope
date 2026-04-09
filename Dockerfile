FROM espressif/idf:v5.5 AS firmware-builder
SHELL ["/bin/bash", "-c"]

ARG TARGET=esp32
ARG LED_BUILTIN=2
ARG BSP_CONFIG_GPIO=9
ARG BOARD_SPECIFIC_INIT="boards/default.h"

COPY CMakeLists.txt /workspace/
COPY main /workspace/main
COPY sdkconfig.defaults /workspace/sdkconfig.defaults
WORKDIR /workspace
RUN sed -i "s/^CONFIG_LED_BUILTIN=.*/CONFIG_LED_BUILTIN=${LED_BUILTIN}/" sdkconfig.defaults && \
    sed -i "s/^CONFIG_BSP_CONFIG_GPIO=.*/CONFIG_BSP_CONFIG_GPIO=${BSP_CONFIG_GPIO}/" sdkconfig.defaults && \
    sed -i "s|^CONFIG_BOARD_SPECIFIC_INIT=.*|CONFIG_BOARD_SPECIFIC_INIT=\"${BOARD_SPECIFIC_INIT}\"|" sdkconfig.defaults
RUN source /opt/esp/idf/export.sh > /dev/null 2>&1 && \
    idf.py set-target ${TARGET} && idf.py build && \
    if [ "${TARGET}" = "esp32c6" ]; then \
      esptool.py --chip ${TARGET} merge_bin \
          -o build/merged-firmware.bin \
          0x0 build/bootloader/bootloader.bin \
          0x8000 build/partition_table/partition-table.bin \
          0x10000 build/esp-scope.bin; \
    else \
      esptool.py --chip ${TARGET} merge_bin \
          -o build/merged-firmware.bin \
          --flash_mode dio --flash_freq 80m --flash_size 2MB \
          0x1000 build/bootloader/bootloader.bin \
          0x8000 build/partition_table/partition-table.bin \
          0x10000 build/esp-scope.bin; \
    fi
