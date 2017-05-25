FROM centos/s2i-base-centos7

MAINTAINER Hossam Hammady <github@hammady.net>

EXPOSE 8080

LABEL summary="Platform for building and running RVM-based Ruby applications" \
      io.k8s.description="Platform for building and running RVM-based Ruby applications" \
      io.k8s.display-name="RVM" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,rvm"

RUN yum install -y centos-release-scl && \
    INSTALL_PKGS="libyaml-devel readline-devel libffi-devel libtool bison" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /opt/app-root && chmod -R ug+rwx /opt/app-root

USER 1001

RUN echo progress-bar >> ~/.curlrc && \
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer && \
    curl -O https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer.asc && \
    gpg --verify rvm-installer.asc && \
    bash rvm-installer stable && \
    export PATH=$PATH:$HOME/.rvm/bin && \
    source $HOME/.rvm/scripts/rvm && \
    rvm autolibs read-fail && \
    rvm requirements && \
    echo "bundler" >> $HOME/.rvm/gemsets/global.gems && \
    echo "foreman" >> $HOME/.rvm/gemsets/global.gems && \
    echo "listen" >> $HOME/.rvm/gemsets/global.gems

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
