FROM lsstsqre/centos:7-stack-lsst_distrib-w_2019_37
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_STACK_DIR=/opt/lsst/software/stack
ARG EUPS_PRODUCT1=galsim
ARG EUPS_PRODUCT2=lsst_sims
ARG EUPS_THROUGH=throughputs
ARG EUPS_SKY=sims_skybrightness_data
ARG EUPS_TAG2=sims_w_2019_37
ARG EUPS_THROUGH_TAG=DC2production
ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

WORKDIR $LSST_STACK_DIR


RUN echo "Environment: \n" && env | sort && \
    echo "Executing: eups distrib install $EUPS_PRODUCT $EUPS_TAG" && \
    source scl_source enable devtoolset-6 && \
    gcc --version && \
    echo -e "source scl_source enable devtoolset-6\n$(cat loadLSST.bash)" > loadLSST.bash && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
                  pip freeze > $LSST_STACK_DIR/require.txt; \
                  sed -i 's/astropy==3.1.2/astropy==3.2.3/g'  $LSST_STACK_DIR/require.txt; \
                  pip install -c $LSST_STACK_DIR/require.txt astropy==3.2.3; \
                  export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
                  eups distrib install ${EUPS_TAG2:+"-t"} $EUPS_TAG2 $EUPS_PRODUCT1 --nolocks; \
                  setup galsim; \
                  sed -i -e "s/\/build/\/opt\/lsst\/software\/stack/g" $GALSIM_DIR/lib/python/galsim/meta_data.py; \
                  unset galsim; \
                  eups distrib install ${EUPS_TAG2:+"-t"} $EUPS_TAG2 $EUPS_PRODUCT2 --nolocks; \
                  setup sims_catUtils; \
                  chmod ugo+x $SIMS_CATUTILS_DIR/support_scripts/get_kepler_light_curves.sh; \
                  chmod ugo+x $SIMS_CATUTILS_DIR/support_scripts/get_mdwarf_flares.sh; \
                  $SIMS_CATUTILS_DIR/support_scripts/get_kepler_light_curves.sh; \
                  $SIMS_CATUTILS_DIR/support_scripts/get_mdwarf_flares.sh; \
                  unset sims_catUtils; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_THROUGH --nolocks; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_SKY --nolocks;' && \
   rm -Rf python/doc && \
   rm -Rf python/phrasebooks && \
   find stack -name "*.pyc" -delete && \
   (find stack -name "*.so" | xargs strip -s -p) || true && \
   (find stack -name "src" ! -path "*/Eigen/*" | xargs rm -Rf) || true && \
   (find stack -name "doc" | xargs rm -Rf) || true && \
   (find stack -name "tests" | xargs rm -Rf ) || true


