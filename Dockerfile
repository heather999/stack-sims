FROM lsstsqre/centos:7-stack-lsst_distrib-w_2019_42
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_STACK_DIR=/opt/lsst/software/stack
ARG EUPS_PRODUCT1=galsim
ARG EUPS_PRODUCT2=lsst_sims
ARG EUPS_THROUGH=throughputs
ARG EUPS_SKY=sims_skybrightness_data
ARG EUPS_TAG2=sims_w_2019_42
ARG EUPS_THROUGH_TAG=DC2production
ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

WORKDIR $LSST_STACK_DIR

RUN echo "Environment: \n" && env | sort

RUN echo "Executing: eups distrib install $EUPS_PRODUCT $EUPS_TAG" && \
    source scl_source enable devtoolset-8 && \
    gcc --version && \
    echo -e "source scl_source enable devtoolset-8\n$(cat loadLSST.bash)" > loadLSST.bash && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
                  export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
                  eups distrib install ${EUPS_TAG2:+"-t"} $EUPS_TAG2 $EUPS_PRODUCT1 --nolocks; \
                  setup galsim; \
                  sed -i -e "s/\/build/\/opt\/lsst\/software\/stack/g" $GALSIM_DIR/lib/python/galsim/meta_data.py; \
                  unset galsim; \
                  eups distrib install ${EUPS_TAG2:+"-t"} $EUPS_TAG2 $EUPS_PRODUCT2 --nolocks; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_THROUGH --nolocks; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_SKY --nolocks;' 



RUN echo "Executing: Remove current tag" && \
    source scl_source enable devtoolset-8 && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
    eups tags --delete=current;' 

#    eups list -t current --showTags=current --name --version | while read n v; do echo eups undeclare --current $n $v; done; \
#    eups list -t current --showTags=current --name --version | while read n v; do eups undeclare --current $n $v; done;' 


RUN rm -Rf python/doc
RUN rm -Rf python/phrasebooks
RUN find stack -name "*.pyc" -delete
RUN (find stack -name "*.so" | xargs strip -s -p) || true
RUN (find stack -name "src" ! -path "*/Eigen/*" | xargs rm -Rf) || true
RUN (find stack -name "doc" | xargs rm -Rf) || true
#RUN (find stack -name "tests" | xargs rm -Rf ) || true


