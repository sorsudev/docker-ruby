FROM ubuntu:18.04

RUN apt-get update && apt-get install -y apache2 curl wget

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.16.3
ENV NVM_INSTALL_PATH $NVM_DIR/versions/node/v$NODE_VERSION
ENV NODE_PATH $NVM_INSTALL_PATH/lib/node_modules
ENV DEBIAN_FRONTEND=noninteractive
ENV RBENV_ROOT /usr/local/rbenv
ENV BUNDLE_VERSION 1.17.3
ENV RUBY_VERSION 2.4.4
ENV PATH ${RBENV_ROOT}/shims:${RBENV_ROOT}/bin:$NVM_INSTALL_PATH/bin:$PATH


RUN mkdir -p $NVM_DIR
RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

RUN echo "source $NVM_DIR/nvm.sh && \
    nvm alias default $NODE_VERSION && \
    nvm use default" | bash

RUN node -v
RUN npm -v

RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN bash -l -c 'a2enmod proxy && service apache2 start'

RUN apt-get update && apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev imagemagick apt-utils apt-transport-https ca-certificates postgresql postgresql-contrib libpq-dev libjemalloc-dev -y

RUN bash -l -c 'ln -fs /usr/share/zoneinfo/Mexico/General /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata'

RUN git clone --depth 1 git://github.com/sstephenson/rbenv.git ${RBENV_ROOT} \
&&  git clone --depth 1 https://github.com/sstephenson/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
&&  git clone --depth 1 git://github.com/jf/rbenv-gemset.git ${RBENV_ROOT}/plugins/rbenv-gemset \
&& ${RBENV_ROOT}/plugins/ruby-build/install.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc

ARG REQUESTED_RUBY_VERSION="2.4.4"

RUN if test -n "$REQUESTED_RUBY_VERSION" -a ! -x ${RBENV_ROOT}/versions/$REQUESTED_RUBY_VERSION/bin/ruby; then (cd ${RBENV_ROOT}/plugins/ruby-build  && git pull && RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install -s $REQUESTED_RUBY_VERSION) && rbenv global $REQUESTED_RUBY_VERSION && apt-get clean && rm -f /var/lib/apt/lists/*_*; fi
RUN gem install bundler -v $BUNDLE_VERSION
RUN bundle config --global silence_root_warning 1
