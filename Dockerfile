FROM espressif/idf:v5.5 AS firmware-builder
SHELL ["/bin/bash", "-c"]

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
RUN source /opt/esp/idf/export.sh > /dev/null 2>&1 && idf.py set-target esp32 && idf.py build
