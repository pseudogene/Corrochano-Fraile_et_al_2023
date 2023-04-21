#!/bin/bash
echo "Biophysical model..."

# Source code compilation (Java)
echo -e "Manifest-Version: 1.0\nClass-Path: lib/netcdfAll-5.5.2.jar lib/commons-io-2.11.0.jar\nMain-Class: particle_track/Particle_track\n" >MANIFEST.MF

mkdir lib
wget -o lib/netcdfAll-5.5.2.jar https://repo.osgeo.org/repository/release/edu/ucar/netcdfAll/5.5.2/netcdfAll-5.5.2.jar
wget -o lib/commons-io-2.11.0.jar https://repo1.maven.org/maven2/commons-io/commons-io/2.11.0/commons-io-2.11.0.jar

wget https://github.com/tomadams1982/BioTracker/archive/9fbf1bb688903cf0499431572b998cb2228bcf56.zip
unzip 9fbf1bb688903cf0499431572b998cb2228bcf56.zip
cd BioTracker-9fbf1bb688903cf0499431572b998cb2228bcf56

javac -d ./build/ -g:none  -cp ../lib/netcdfAll-5.5.2.jar:../lib/commons-io-2.11.0.jar  extUtils/*.java particle_track/*.java
jar --create --file ../particle_track.jar -m ../MANIFEST.MF -C build .
cd ..
rm -rf 9fbf1bb688903cf0499431572b998cb2228bcf56.zip BioTracker-9fbf1bb688903cf0499431572b998cb2228bcf56 MANIFEST.MF


# Parameters preparation
sed 's?/home/ubuntu/?'$(pwd)'?g' data/bivalves.2020.properties > bivalves.2020.properties
sed 's?/home/ubuntu/?'$(pwd)'?g' data/bivalves.2021.properties > bivalves.2021.properties
sed 's?/home/ubuntu/?'$(pwd)'?g' data/bivalves.2022.properties > bivalves.2022.properties


# Download the hybrographic data
mkdir westcoms2

mkdir westcoms2/netcdf_2020
cd westcoms2/netcdf_2020
wget -i ../../data/westcoms2_2020.txt
cd ../..

mkdir westcoms2/netcdf_2021
cd westcoms2/netcdf_2021
wget -i ../../data/westcoms2_2021.txt
cd ../..

mkdir westcoms2/netcdf_2022
cd westcoms2/netcdf_2022
wget -i ../../data/westcoms2_2022.txt
cd ../..



# Run the model
java -jar particle_track.jar bivalves.2020.properties
java -jar particle_track.jar bivalves.2021.properties
java -jar particle_track.jar bivalves.2022.properties

echo "[done]"
