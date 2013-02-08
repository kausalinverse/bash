#/bin/bash

# Die Variablen Definieren
# ========================
usage="blender_install -a [64/32] "

blender32_url="http://ftp.halifax.rwth-aachen.de/blender/release/Blender2.65/blender-2.65a-linux-glibc211-i686.tar.bz2"
blender64_url="http://ftp.halifax.rwth-aachen.de/blender/release/Blender2.65/blender-2.65a-linux-glibc211-x86_64.tar.bz2"

blender32_tar="blender-2.65a-linux-glibc211-i686.tar.bz2"
blender64_tar="blender-2.65a-linux-glibc211-x86_64.tar.bz2"

#
# PARAMETER UEBERGABE ZERHACKEN
# =============================

while [ $# -gt 0 ]
do
    arg=$1
    wert=$2
    if [ "$arg" = "-a" ]; then
        if [ "$2" = "32" ]; then
            blender_url=$blender32_url
            blender_tar=$blender32_tar
            blender_dir="blender-2.65a-linux-glibc211-i686"
            continue="yes"
        elif [ "$2" = "64" ]; then
            blender_url=$blender64_url
            blender_tar=$blender64_tar
            blender_dir="blender-2.65a-linux-glibc211-x86_64"
            continue="yes"
        else
            echo "FEHLER!! Entweder 32bit oder 64bit"
            echo $usage
            break
        fi
        shift 2
    #elif [ "$arg" = "-l"  ]; then
    # glibc27 oder glibc21
    # mache irgend was
    else
        echo "Fehler! Prameter sind nicht bekannt"
        echo "$usage"
        break
        
    fi
done


#  FUNKTIONENEN
#  ====================
download(){
   echo "Download blender form:  $blender_url " ;
   wget $blender_url
}


unpack(){
    echo  "Entpacke:  $blender_tar " ;
    tar xvjf $blender_tar 
}

set_env() {
    mkdir $HOME/bin
    ln -s $PWD/$blender_dir/blender $HOME/bin/blender
    export PATH=$PATH:$HOME/bin
    echo $PATH
}





# MAIN PROGRAMM
# ==============
download
unpack
set_env
blender -v




 #export BLEND=$PWD/blender-2.62-linux-glibc27-x86_64

# export PATH=$PATH:/home/ec2-user/programme/blender-2.62-linux-glibc27-x86_64
# export PATH=$PATH:/home/$USERNAME/programme/blender-2.62-linux-glibc27-x86_64

#sh $BLEND/blender 



# ldd blender

# libfreetype.so.6 => not found
# libSDL-1.2.so.0 => not found
# libXi.so.6 => not found
#
# emerge -av media-libs/freetype
# emerge -av media-libs/libsdl
# emerge -av x11-libs/libXi
