package results

import domain.SensorId

case class Report(fileCount: Long, measurementCount: Long, failedMeasurementCount: Long, sensors: Map[SensorId, Option[SensorStats]]) {
  def print(): Unit = {
    println(s"Num of processed files: $fileCount")
    println(s"Num of processed measurements: $measurementCount")
    println(s"Num of failed measurements: $failedMeasurementCount")

    println("")
    println("Sensors with highest avg humidity:")
    println("")

    println("sensor-id,min,avg,max")
    sensors.toVector
      .sortWith((a, b) => a._2.isDefined && b._2.forall(_.avg < a._2.get.avg))
      .foreach(s => {
        val results = s._2.map(st => s"${st.min.value},${st.avg.value},${st.max.value}").getOrElse("NaN,NaN,NaN")
        println(s"${s._1.id},$results")
      })
  }
}