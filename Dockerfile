FROM debian:buster-slim AS build
COPY grib2.patch /grib2.patch
RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    gfortran \
 && wget -nv https://www.ftp.cpc.ncep.noaa.gov/wd51we/gribw/gribw.tar -O - | tar xv \
 && make -C gribw -f gribwlib.make \
 && make -C gribw/ggrib -f ggrib.make \
 && wget -nv https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz -O - | tar zxv \
 && CC=gcc FC=gfortran make -C grib2 \
 && mkdir wgrib \
 && wget -nv https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib/wgrib.tar -O - | tar xvC wgrib \
 && make -C wgrib
 
FROM debian:buster-slim
COPY --from=build /gribw/ggrib/ggrib /grib2/wgrib2/wgrib2 /wgrib/wgrib /usr/local/bin/
RUN apt-get update && apt-get install -y \
    python3-grib \
    libeccodes-tools \
    wget \
    libgfortran5 \
    libgomp1 \
 && rm -rf /var/lib/apt/lists/*
 

