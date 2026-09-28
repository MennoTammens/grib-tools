FROM debian:trixie-slim AS build
ARG TARGETARCH
COPY grib2.patch /grib2.patch
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    gfortran \
    cmake \
 && wget -nv https://www.ftp.cpc.ncep.noaa.gov/wd51we/gribw/gribw.tar -O - | tar xv \
 && make -C gribw -f gribwlib.make \
 && make -C gribw/ggrib -f ggrib.make \
 && wget -nv https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz -O - | tar zxv \
 && if [ "$TARGETARCH" = "arm64" ]; then patch -d grib2 -p1 < /grib2.patch; fi \
 && CC=gcc FC=gfortran make -C grib2 \
 && mkdir wgrib \
 && wget -nv https://web.archive.org/web/20250706123034/https://ftp.cpc.ncep.noaa.gov/wd51we/wgrib/wgrib.tar -O - | tar xvC wgrib \
 && make -C wgrib
 
FROM debian:trixie-slim
COPY --from=build /gribw/ggrib/ggrib /grib2/wgrib2/wgrib2 /wgrib/wgrib /usr/local/bin/
RUN apt-get update && apt-get install -y \
    python3-grib \
    python3-xarray \
    python3-eccodes \
    python3-requests \
    python3-aiohttp \
    python3-boto3 \
    python3-paho-mqtt \
    libeccodes-tools \
    wget \
    libgfortran5 \
    libgomp1 \
 && rm -rf /var/lib/apt/lists/*

