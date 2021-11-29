FROM eclipsefdn/nginx:stable-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY cbiSponsorships.json /usr/share/nginx/html/
