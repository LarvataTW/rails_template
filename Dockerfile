# See https://github.com/phusion/passenger-docker/blob/master/Changelog.md
FROM phusion/passenger-ruby25:0.9.35

RUN apt-get update && \
    apt-get install -y imagemagick build-essential libpq-dev

# Set correct environment variables.
ENV HOME /root
ENV LANG en_US.UTF-8
ENV TZ=Asia/Taipei

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Run Bundle in a cache efficient way
COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

# Add the nginx info
ADD config/nginx.conf /etc/nginx/sites-enabled/webapp.conf
ADD config/nginx.env.conf /etc/nginx/main.d/nginx.env.conf

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
