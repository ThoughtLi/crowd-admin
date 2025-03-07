FROM maven:3.8.6-eclipse-temurin-17-alpine as builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM ibm-semeru-runtimes:open-17-jdk
# 指定维护者的名字
MAINTAINER wayn111
WORKDIR /root/workspace
# 将当前目录下的jar包复制到docker容器的/目录下
COPY --from=builder /app/target/*.jar /opt/crowd.jar

# 添加环境变量
ENV TZ="Asia/Shanghai"
# 运行过程中创建一个mall-tiny-docker-file.jar文件
RUN bash -c 'touch /opt/crowd.jar'
# 声明服务运行在8000端口
EXPOSE 8088
# 指定docker容器启动时运行jar包
ENTRYPOINT ["sh", "-c", "exec java -jar -Xms256m -Xmx256m /opt/crowd.jar"]
