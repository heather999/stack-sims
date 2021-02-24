FROM opensuse/leap:15.2
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

RUN zypper install -y bash \
        curl \
        gzip \
        patch \
        tar \
        wget \
        which

ARG LSST_STACK_DIR=/opt/lsst/software/stack
#ARG EUPS_PRODUCT1=galsim
ARG EUPS_PRODUCT=lsst_distrib
#ARG EUPS_THROUGH=throughputs
#ARG EUPS_SKY=sims_skybrightness_data
ARG EUPS_TAG=w_2021_03
#ARG EUPS_THROUGH_TAG=DC2production
#ARG LSST_USER=lsst
#ARG LSST_GROUP=lsst

WORKDIR $LSST_STACK_DIR

ADD sbatch.tar.bz2 /nersc_slurm
#ENV PATH="/nersc_slurm:${PATH}"
#ENV LD_LIBRARY_PATH="/nersc_slurm:${LD_LIBRARY_PATH}"


#USER lsst



RUN echo "Environment: \n" && env | sort && \
    curl -OL https://raw.githubusercontent.com/lsst/lsst/w.2021.03/scripts/newinstall.sh && \
    bash newinstall.sh -bct && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
                  eups distrib install ${EUPS_TAG:+"-t"} $EUPS_TAG $EUPS_PRODUCT --nolocks; \
                  curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/master/shebangtron | python; \
                  echo 'hooks.config.site.lockDirectoryBase = None' >> $LSST_STACK_DIR/stack/current/site/startup.py; ' 
                  
                  #&& \
   #rm -Rf python/doc && \
   #rm -Rf python/phrasebooks && \
   #find stack -name "*.pyc" -delete && \
   #(find stack -name "*.so" ! -path "*/xpa/*" | xargs strip -s -p) || true && \
   #(find stack -name "src" ! -path "*/Eigen/*" | xargs rm -Rf) || true && \
   #(find stack -name "doc" | xargs rm -Rf) || true


# REally commented out
#RUN (find stack -name "tests" | xargs rm -Rf ) || true

  #           eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_THROUGH --nolocks; \
       ##           eups admin clearCache; \
        #          eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_SKY --nolocks;' && \


# export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
