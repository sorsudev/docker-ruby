FROM alpine:3.10

RUN apk add --no-cache --update \
    bash \
    libxml2-dev \
    libxslt-dev \
    yaml \
    ruby-json \
    yaml-dev \
    git \
    wget \
    curl \
    vim \
    build-base \
    python \
    readline-dev \
    openssl-dev \
    zlib-dev \
    libcurl \
    sqlite-dev \
    curl-dev \
    linux-headers \
    postgresql-dev \
    nodejs \
    tzdata \
    linux-headers \
    imagemagick-dev \
    libffi-dev \
    libffi-dev \
&& rm -rf /var/cache/apk/*

RUN cp /usr/share/zoneinfo/Mexico/General /etc/localtime

ENV PATH /usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv
ENV BUNDLE_VERSION 1.17.3
ENV RUBY_VERSION 2.4.4
ENV CONFIGURE_OPTS --disable-install-doc

RUN git clone --depth 1 git://github.com/sstephenson/rbenv.git ${RBENV_ROOT} \
&&  git clone --depth 1 https://github.com/sstephenson/ruby-build.git ${RBENV_ROOT}/plugins/ruby-build \
&&  git clone --depth 1 git://github.com/jf/rbenv-gemset.git ${RBENV_ROOT}/plugins/rbenv-gemset \
&& ${RBENV_ROOT}/plugins/ruby-build/install.sh

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh 

RUN rbenv install -v $RUBY_VERSION \
&&  rbenv global $RUBY_VERSION

RUN gem install bundler -v $BUNDLE_VERSION
RUN bundle config --global silence_root_warning 1
