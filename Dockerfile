# Docker 镜像构建
FROM eclipse-temurin:17-jdk-alpine

RUN apk add --no-cache bash procps curl tar openssh-client

# common for all images
LABEL org.opencontainers.image.title="Apache Maven"
LABEL org.opencontainers.image.source=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.url=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.description="Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information."

ENV MAVEN_HOME=/usr/share/maven

COPY --from=maven:3.9.9-eclipse-temurin-17 ${MAVEN_HOME} ${MAVEN_HOME}
COPY --from=maven:3.9.9-eclipse-temurin-17 /usr/local/bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY --from=maven:3.9.9-eclipse-temurin-17 /usr/share/maven/ref/settings-docker.xml /usr/share/maven/ref/settings-docker.xml

RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn

ARG MAVEN_VERSION=3.9.9
ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]

# 指定工作目录
WORKDIR /app
# 将文件复制到容器里
COPY pom.xml .
COPY src ./src
# 方案一：用本地打的包
# COPY target ./target
# 方案二：容器内打包,并跳过测试用例
RUN mvn package -DskipTests

# 启动服务
#   -- 指定 application-prod.yml 启动
CMD ["java","-jar","/app/target/github-actions-demo-0.0.1-SNAPSHOT.jar","--spring.profiles.active=prod"]
