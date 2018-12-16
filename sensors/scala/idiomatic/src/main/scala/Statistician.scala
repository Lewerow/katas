import java.nio.file.{Files, Path, Paths}
import java.util.stream.Collectors

import calculation.{IntermediateReport, IntermediateSensorStats}
import domain.{MeasurementValue, SensorId}
import results.Report

import scala.io.Source
import scala.util.Try
import scala.collection.JavaConverters._
import scala.language.postfixOps

case class Statistician(dir: String) {
  val SENSOR_ID_COLUMN = "sensor-id"
  val HUMIDITY_COLUMN = "humidity"
  val COLUMN_DELIMITER = ","
  val EXPECTED_COLUMN_COUNT = 2

  def calculateStats(): Report =

  // assume "reasonable" number of files (fitting in memory), otherwise we'd need to run streams here
    Files.list(Paths.get(dir)).collect(Collectors.toList())
      .asScala
      .filter(_.toAbsolutePath.toString.endsWith(".csv"))
      .par
      .map(f => calculateIntermediateStats(f))
      .foldLeft(IntermediateReport.empty)((acc, stats) => acc.mergeWith(stats))
    .toFinal


  private def calculateIntermediateStats(file: Path): IntermediateReport = {
    val lines = Source.fromFile(file.toFile).getLines()
    val header = lines.take(1).map(_.split(COLUMN_DELIMITER)).foldLeft(Array[String]())((a, b) => b)

    if(header.length > EXPECTED_COLUMN_COUNT || !header.contains(SENSOR_ID_COLUMN) || !header.contains(HUMIDITY_COLUMN)) {
      throw new IllegalArgumentException(s"Invalid structure for ${file.toAbsolutePath.toString}. Header: ${header}")
    }

    val sensorIdIndex = if(header(0) == SENSOR_ID_COLUMN) 0 else 1
    val valueIndex = if(header(1) == HUMIDITY_COLUMN) 1 else 0

    lines
      .foldLeft(IntermediateReport.single)((acc, line) => {
        val elems = line.split(COLUMN_DELIMITER)
        if(elems.length != EXPECTED_COLUMN_COUNT) {
          throw new IllegalArgumentException(
            s"Invalid structure in ${file.toAbsolutePath.toString}. " +
              s"Expected ${EXPECTED_COLUMN_COUNT} columns, got ${elems.length}"
          )
        }
        val sensorId = SensorId(elems(sensorIdIndex))
        val value = Try{ MeasurementValue( elems(valueIndex).toLong )} toOption

        acc.withMeasurement(sensorId, value)
      })
  }
}

