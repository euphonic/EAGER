FROM python:slim

WORKDIR /app

COPY . /app

RUN mkdir -p /opt/java
RUN tar -zxvf /app/docker/jre-8u172-linux-x64.tar.gz -C /opt/java
ENV JAVA_HOME /opt/java/jre1.8.0_172
ENV PATH $PATH:$JAVA_HOME/bin

RUN pip install --trusted-host pypi.python.org -r requirements.txt

EXPOSE 8888

CMD ["python", "server.py"]