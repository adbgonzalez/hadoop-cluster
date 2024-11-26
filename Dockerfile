FROM ubuntu:20.04

# Establecer variables de entorno
ENV HADOOP_VERSION=3.3.6
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_INSTALL=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/nativ
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"


# Instalar utilidades esenciales
RUN apt-get update && apt-get install -y \
    ssh \
    rsync \
    openjdk-8-jdk \
    wget \
    curl \
    vim \
    net-tools

# Descargar e instalar Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
    && tar -xzvf hadoop-$HADOOP_VERSION.tar.gz -C /usr/local/ \
    && mv /usr/local/hadoop-$HADOOP_VERSION /usr/local/hadoop \
    && rm hadoop-$HADOOP_VERSION.tar.gz

# Configurar SSH para nodos Hadoop
RUN ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

# Copiar archivos de configuración de Hadoop
COPY core-site.xml $HADOOP_HOME/etc/hadoop/
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/

# Formatear el Namenode (solo necesario en el nodo maestro)
#RUN $HADOOP_HOME/bin/hdfs namenode -format

# Exponer puertos de Hadoop
EXPOSE 8088 8042 50070 50075 50090 8020 9000

# Iniciar servicio SSH y mantener el contenedor corriendo
CMD service ssh start && bash
