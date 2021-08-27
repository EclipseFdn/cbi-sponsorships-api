FROM eclipsefdn/nginx:stable-alpine

COPY cbiSponsorships.json /usr/share/nginx/html/

RUN sed -i 's/index \([^;]*\);/index cbiSponsorships.json;/' /etc/nginx/conf.d/default.conf
