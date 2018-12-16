package calculation

import domain.{MeasurementValue, SensorId}
import results.Report


case class IntermediateReport(fileCount: Long, measurementCount: Long, failedMeasurementCount: Long, sensors: IntermediateSensorMap) {
  def withMeasurement(sensorId: SensorId, value: Option[MeasurementValue]): IntermediateReport = {
    copy(
      measurementCount = measurementCount + 1,
      failedMeasurementCount = value.map(_ => failedMeasurementCount).getOrElse(failedMeasurementCount + 1),
      sensors = sensors.withMeasurement(sensorId, value)
    )
  }

  def mergeWith(other: IntermediateReport): IntermediateReport =
    copy(
      fileCount + other.fileCount,
      measurementCount + other.measurementCount,
      failedMeasurementCount + other.failedMeasurementCount,
      sensors.mergeWith(other.sensors)
    )

  def toFinal: Report =
    Report(fileCount, measurementCount, failedMeasurementCount, sensors.sensors.mapValues(_.map(_.toFinal)))
}

object IntermediateReport {
  def empty: IntermediateReport = IntermediateReport(0, 0, 0, IntermediateSensorMap.empty)
  def single: IntermediateReport = IntermediateReport.empty.copy(fileCount = 1)
}