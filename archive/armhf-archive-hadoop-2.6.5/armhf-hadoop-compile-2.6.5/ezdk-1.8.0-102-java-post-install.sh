#!/bin/sh 

LATEST=458
LATEST=$((`LANG=C update-alternatives --display java | grep ^/ | sed -e 's/.* //g' | sort -n | tail -1`+1))
J_INSTALL_DIR=/opt/jdk

#if [ $arch = "arm" ]; then
    #apparently this dir doesn't exist on some arm machines
    mkdir -p /usr/share/man/man1
#fi

# This step is optional, recommended, and affects code below.
ls $J_INSTALL_DIR/man/man1/*.1 >/dev/null 2>&1 && \
  gzip -9 $J_INSTALL_DIR/man/man1/*.1 >/dev/null 2>&1


#link JRE files
for f in $J_INSTALL_DIR/jre/bin/*; do

    name=`basename $f`;

    if [ ! -f "/usr/bin/$name" -o -L "/usr/bin/$name" ]; then  #some files, like jvisualvm might not be links

        if [ -f "$J_INSTALL_DIR/man/man1/$name.1.gz" ]; then

            if [ ! $arch = "arm" ]; then
                update-alternatives --install /usr/bin/$name $name $J_INSTALL_DIR/jre/bin/$name $LATEST --slave /usr/share/man/man1/$name.1.gz $name.1.gz $J_INSTALL_DIR/man/man1/$name.1.gz
                echo "jre $name $J_INSTALL_DIR/jre/bin/$name" >> /opt/.jdk1.8.0_102.jinfo
            else
                # There's no javaws, jvisualvm or jmc on arm
                [ ! $name = "javaws" ] && [ ! $name = "jvisualvm" ] && [ ! $name = "jmc" ] && update-alternatives --install /usr/bin/$name $name $J_INSTALL_DIR/jre/bin/$name $LATEST --slave /usr/share/man/man1/$name.1.gz $name.1.gz $J_INSTALL_DIR/man/man1/$name.1.gz
                [ ! $name = "javaws" ] && [ ! $name = "jvisualvm" ] && [ ! $name = "jmc" ] && echo "jre $name $J_INSTALL_DIR/jre/bin/$name" >> /opt/.jdk1.8.0_102.jinfo
            fi

         else #no man pages available

            # [ ! $name = "javaws.real" ] = skip javaws.real     
            [ ! $name = "javaws.real" ] && update-alternatives --install /usr/bin/$name $name $J_INSTALL_DIR/jre/bin/$name $LATEST
            [ ! $name = "javaws.real" ] && echo "jre $name $J_INSTALL_DIR/jre/bin/$name" >> /opt/.jdk1.8.0_102.jinfo
            
         fi
    fi

done

#link JRE not in jre/bin
[ -f $J_INSTALL_DIR/jre/lib/jexec ]    && update-alternatives --install /usr/bin/jexec    jexec    $J_INSTALL_DIR/jre/lib/jexec    $LATEST --slave /usr/share/binfmts/jar jexec-binfmt $J_INSTALL_DIR/jre/lib/jar.binfmt && echo "jre jexec $J_INSTALL_DIR/jre/lib/jexec" >> /opt/.jdk1.8.0_102.jinfo

#This will issue ignorable warnings for alternatives that are not part of a group
#Link JDK files with/without man pages
if [ -d "$J_INSTALL_DIR/man/man1" ];then

	echo "Link JDK files with man pages"

    for f in $J_INSTALL_DIR/man/man1/*; do

        name=`basename $f .1.gz`;

        #some files, like jvisualvm might not be links. Further assume this for corresponding man page
        if [ ! -f "/usr/bin/$name" -o -L "/usr/bin/$name" ]; then

            if [ ! -f "$J_INSTALL_DIR/man/man1/$name.1.gz" ]; then
                name=`basename $f .1`;          #handle any legacy uncompressed pages
            fi

      		if [ ! -e $J_INSTALL_DIR/jre/bin/$name ]; then #don't link already linked JRE files
				if [ ! $arch = "arm" ]; then
          			update-alternatives --install /usr/bin/$name $name $J_INSTALL_DIR/bin/$name $LATEST --slave /usr/share/man/man1/$name.1.gz $name.1.gz $J_INSTALL_DIR/man/man1/$name.1.gz
          			echo "jdk $name $J_INSTALL_DIR/bin/$name" >> /opt/.jdk1.8.0_102.jinfo
				else
					# There's no javaws, jvisualvm or jmc on arm
					[ ! $name = "javaws" ] && [ ! $name = "jvisualvm" ] && [ ! $name = "jmc" ] && update-alternatives --install /usr/bin/$name $name $J_INSTALL_DIR/bin/$name $LATEST --slave /usr/share/man/man1/$name.1.gz $name.1.gz $J_INSTALL_DIR/man/man1/$name.1.gz
					[ ! $name = "javaws" ] && [ ! $name = "jvisualvm" ] && [ ! $name = "jmc" ] && echo "jdk $name $J_INSTALL_DIR/bin/$name" >> /opt/.jdk1.8.0_102.jinfo
				fi
      		fi
        fi
    done
else  #no man pages available
    for f in $J_INSTALL_DIR/bin/*; do
        name=`basename $f`;
        if [ ! -f "/usr/bin/$name" -o -L "/usr/bin/$name" ]; then  #some files, like jvisualvm might not be links
            if [ ! -e $J_INSTALL_DIR/jre/bin/$name ]; then #don't link already linked JRE files
                update-alternatives --install /usr/bin/$name $name $J_INSTALL_DIR/bin/$name $LATEST
                echo "jdk $name $J_INSTALL_DIR/bin/$name" >> /opt/.jdk1.8.0_102.jinfo
            fi
        fi
    done
fi
