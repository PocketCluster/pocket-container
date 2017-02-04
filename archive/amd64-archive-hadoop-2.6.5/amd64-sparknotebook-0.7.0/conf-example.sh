

    custom {
      localRepo  = "/pocket/spark-notebook",
      repos      = ["m" %  "default" % "http://repo.maven.apache.org/maven2/" % "maven"],
      deps       = ["junit % junit % 4.12"],
      imports    = ["import scala.util._"],
      sparkConf {
        spark.local.dir = "/pocket/spark/tmp",
        spark.driver.extraClassPath = "/etc/spark/conf:/etc/hadoop/conf:/opt/hadoop/share/hadoop/common/lib/*:/opt/spark/jars/*",
        spark.driver.extraJavaOptions = "-Dspark.driver.log.level=DEBUG",
        spark.driver.host = "pc-core",
        spark.eventLog.dir = "file:///pocket/spark/log",
        spark.eventLog.enabled = "true",
        spark.executor.extraClassPath = "/etc/spark/conf:/etc/hadoop/conf:/opt/hadoop/share/hadoop/common/lib/*:/opt/spark/jars/*",
        spark.executor.extraJavaOptions = "-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:MaxHeapFreeRatio=70",
        spark.master="spark://pc-core:7077",
        spark.executor.memory="1G"
      }
    }


    custom {
      localRepo  = "/pocket/spark-notebook",
      imports    = ["import scala.util._"],
      sparkConf  = {
        spark.app.name : "Spark-Notebook",
        spark.master : "spark://pc-core:7077",
        spark.executor.memory : "1G"
      }
    }


/opt/spark-notebook/bin/spark-notebook -Dconfig.file=/opt/spark-notebook/conf/application.conf -Dhttp.port=9001

function build_spark_notebook() { 
  local SHOULD_SQUASH=${1}
  local NOTEBOOK_VERSION=0.7.0
  local NOTEBOOK_BUILD_TARGET=${PLATFORM}-sparknotebook-${NOTEBOOK_VERSION}
  local NOTEBOOK_BUILD_PATH=./${NOTEBOOK_BUILD_TARGET}
    if [[ ! -f ${NOTEBOOK_BUILD_PATH}/spark-notebook-${NOTEBOOK_VERSION}-scala-2.11.8-spark-2.1.0-hadoop-2.7.3.tar ]]; then
        echo "Spark Notebook ${SPARK_VERSION} not found"
        return 2
    fi
  if [ ${SHOULD_SQUASH} -eq 1 ]; then
    sed 's/BUILDCHAINTAG/latest/g' ${NOTEBOOK_BUILD_PATH}/Dockerfile.template > ${NOTEBOOK_BUILD_PATH}/Dockerfile
    _build_squash ${NOTEBOOK_BUILD_TARGET} || true
  else
    sed 's/BUILDCHAINTAG/dev/g' ${NOTEBOOK_BUILD_PATH}/Dockerfile.template > ${NOTEBOOK_BUILD_PATH}/Dockerfile
    _unsquashed_build ${NOTEBOOK_BUILD_TARGET} || true
  fi
  rm ${NOTEBOOK_BUILD_PATH}/Dockerfile
}
