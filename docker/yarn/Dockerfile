FROM node:10

WORKDIR /var/lib/php/tyoshii/sample

# install yarn
#RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash -
#RUN yum install -y nodejs
RUN npm install -g yarn

CMD yarn install && yarn run hot
