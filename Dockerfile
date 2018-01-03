FROM openjdk:8-jdk-alpine
MAINTAINER andreysaksonov

ENV MAVEN_VERSION=3.5.2 SPARK_VERSION=2.2.1 HADOOP_VERSION=2.7
RUN apk add --no-cache --update bash git nodejs yarn \
  && wget http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && wget http://mirror.cc.columbia.edu/pub/software/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
  && mkdir -p /usr/local/maven \
  && tar xvzf apache-maven-${MAVEN_VERSION}-bin.tar.gz --strip-components=1 -C /usr/local/maven \
  && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && mkdir -p /usr/local/spark \
  && tar xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz --strip-components=1 -C /usr/local/spark \
  && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
  && ln -s /usr/local/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /usr/local/spark \
  && sed 's/INFO/WARN/g' /usr/local/spark/conf/log4j.properties.template > /usr/local/spark/conf/log4j.properties

ENV ZEPPELIN_GIT_BRANCH=v0.7.3 SPARK_PROFILE=spark-2.2 HADOOP_PROFILE=hadoop-2.7
RUN echo '{ "allow_root": true }' > /root/.bowerrc \
  && git clone --branch ${ZEPPELIN_GIT_BRANCH} --depth 1 -q https://github.com/apache/zeppelin.git /usr/local/zeppelin \
  && /usr/local/maven/bin/mvn -f /usr/local/zeppelin/pom.xml -B clean package -P${SPARK_PROFILE} -P${HADOOP_PROFILE} -DskipTests

ENV ZEPPELIN_PORT=8080 ZEPPELIN_MEM="-Xmx1G" ZEPPELIN_JAVA_OPTS="-Dspark.home=/usr/local/spark"
WORKDIR /usr/local/zeppelin
CMD ["bin/zeppelin.sh"]
