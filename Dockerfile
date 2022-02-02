FROM  phusion/baseimage:focal-1.1.0

MAINTAINER Chinkesh Kumar

RUN echo "deb http://archive.ubuntu.com/ubuntu focal main universe" > /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive

ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VER}-openjdk-amd64/

ENV MAVEN_VERSION 3.8.4
ENV MAVEN_HOME /usr/share/maven

ENV TOMCAT_MAJOR_VERSION 9
ENV TOMCAT_MINOR_VERSION 9.0.58
ENV CATALINA_HOME /tomcat

# Installing Java and Maven
RUN apt-get update -y && \
	apt-get install -y wget openjdk-${JAVA_VER}-jdk ant ca-certificates-java && \
    update-ca-certificates -f && \
	mkdir -p /usr/share/maven && \
    curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn && \
	apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk${JAVA_VER}-installer
	
# Set JAVA_HOME Path
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VER}-openjdk-amd64/" >> ~/.bashrc

# Set Maven Volume
VOLUME /root/.m2

# Downloading & Installing Tomcat
RUN	wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
	tar zxf apache-tomcat-*.tar.gz && \
 	rm apache-tomcat-*.tar.gz && \
 	mv apache-tomcat* tomcat && \
    apt-get clean all && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh

RUN mkdir /etc/service/tomcat
ADD run.sh /etc/service/tomcat/run
RUN chmod +x /*.sh
RUN chmod +x /etc/service/tomcat/run

EXPOSE 8080

CMD ["/sbin/my_init"]