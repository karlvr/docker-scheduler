FROM ubuntu:18.04 as build

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
		cron \
		rsyslog \
	    apt-transport-https \
	    ca-certificates \
	    curl \
	    software-properties-common \
	    gpg-agent && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
	apt-get update && \
	apt-get install -y --no-install-recommends docker-ce-cli && \
	apt-get clean

RUN echo 'cron.*                /dev/stdout' >> /etc/rsyslog.conf && \
	echo > /etc/crontab
COPY ./docker-entrypoint.sh /
COPY ./sendmail /usr/sbin/sendmail
COPY ./commands/* /usr/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["cron", "-f", "-L", "15"]
