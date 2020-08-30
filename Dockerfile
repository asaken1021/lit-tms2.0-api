FROM litwebs/lit-school-sinatra:latest

ENV DEBIAN_FRONTEND nointeractive
ENV TZ Asia/Tokyo
ENV PATH $PATH:/home/lit_users/.rbenv/shims:/home/lit_users/.rbenv/bin

WORKDIR /home/lit_users/workspace

VOLUME ["/home/lit_users/workspace/db"]

EXPOSE 4567

COPY --chown=lit_users:lit_users ./ /home/lit_users/workspace

RUN sudo rm -f /etc/apt/sources.list.d/pgdg.list
RUN sudo apt update
RUN sudo apt upgrade -y
RUN sudo apt install -y tzdata screen aptitude
RUN sudo aptitude install -y ruby-rmagick libmagickcore-6-headers libmagickcore-dev libmagickwand-dev

RUN /bin/bash -l -c bundle
RUN /bin/bash -l -c bundle exec rake db:migrate

CMD ["ruby", "app.rb", "-o", "0.0.0.0"]

# RUN bash -c bundle
# RUN bash -c bundle exec db:migrate

# CMD ruby app.rb -o 0.0.0.0
