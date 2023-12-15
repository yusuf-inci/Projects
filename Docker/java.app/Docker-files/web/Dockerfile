FROM nginx
LABEL Project="Vprofile"
LABEL Env="prod"

RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginvproapp.conf /etc/nginx/conf.d/vproapp.conf