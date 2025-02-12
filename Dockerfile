FROM ruby:3.2-slim

ENV REVIEWDOG_VERSION=v0.17.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

RUN gem install bundler-audit

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
