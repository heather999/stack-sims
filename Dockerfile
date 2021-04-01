FROM lsstsqre/centos:7-stack-lsst_distrib-w_2021_14
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_STACK_DIR=/opt/lsst/software/stack
ARG EUPS_PRODUCT1=galsim
ARG EUPS_PRODUCT2=lsst_sims
ARG EUPS_THROUGH=throughputs
ARG EUPS_SKY=sims_skybrightness_data
ARG EUPS_TAG2=sims_w_2021_14
ARG EUPS_THROUGH_TAG=DC2production
ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

WORKDIR $LSST_STACK_DIR

USER root
RUN yum install -y wget \
    which
USER lsst

# June 2020 - galsim is no longer installed as eups package but is pre-installed via conda-forge
#                  export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
#                  eups distrib install ${EUPS_TAG2:+"-t"} $EUPS_TAG2 $EUPS_PRODUCT1 --nolocks; \
#                  setup galsim; \
#                  sed -i -e "s/\/build/\/opt\/lsst\/software\/stack/g" $GALSIM_DIR/lib/python/galsim/meta_data.py; \
#                  unset galsim; \


RUN echo "Environment: \n" && env | sort && \
    echo "Executing: eups distrib install $EUPS_PRODUCT $EUPS_TAG" && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
                  pip freeze > $LSST_STACK_DIR/require.txt; \
                  eups distrib install ${EUPS_TAG2:+"-t"} $EUPS_TAG2 $EUPS_PRODUCT2 --nolocks; \
                  export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_THROUGH --nolocks; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_SKY --nolocks;' && \
   rm -Rf python/doc && \
   rm -Rf python/phrasebooks && \
   find stack -name "*.pyc" -delete && \
   (find stack -name "*.so" ! -path "*/xpa/*" | xargs strip -s -p) || true && \
   (find stack -name "src" ! -path "*/Eigen/*" | xargs rm -Rf) || true && \
   (find stack -name "doc" | xargs rm -Rf) || true
#RUN (find stack -name "tests" | xargs rm -Rf ) || true

  #           eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_THROUGH --nolocks; \
       ##           eups admin clearCache; \
        #          eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_SKY --nolocks;' && \


# export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
