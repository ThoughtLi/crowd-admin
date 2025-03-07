FROM maven:3.8.6-eclipse-temurin-17-alpine as builde
ENV PROJECT_NAME crowd-admin
#定义工作目录
ENV WORK_PATH /usr/src/$PROJECT_NAME
####################定义环境变量 start####################
#将源码复制到当前目录
COPY ./crowd-* $WORK_PATH/
COPY ./images $WORK_PATH/images
COPY ./ip2region.xdb $WORK_PATH/ip2region.xdb
COPY ./pom.xml $WORK_PATH/pom.xml
#编译构建
RUN cd $WORK_PATH && mvn clean package -DskipTests -pl crowd-web -am


FROM ibm-semeru-runtimes:open-17-jdk
# 指定维护者的名字
MAINTAINER wayn111
WORKDIR /root/workspace
# 将当前目录下的jar包复制到docker容器的/目录下
COPY --from=builder /usr/src/crowd-admin/crowd-web/target/*.jar /opt/crowd.jar
ADD ip2region.xdb /home/app/ip2region.xdb
# 添加环境变量
ENV IP_REGION_PATH=/home/app/ip2region.xdb
ENV TZ="Asia/Shanghai"
# 运行过程中创建一个mall-tiny-docker-file.jar文件
RUN bash -c 'touch /opt/crowd.jar'
# 声明服务运行在8000端口
EXPOSE 8088
# 指定docker容器启动时运行jar包
ENTRYPOINT ["sh", "-c", "exec java -jar -Xms256m -Xmx256m /opt/crowd.jar"]
