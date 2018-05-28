package calculation

import domain.{MeasurementValue, SensorId}

case class IntermediateSensorMap(sensors: Map[SensorId, Option[IntermediateSensorStats]]) {
  def withMeasurement(sensorId: SensorId, measurement: Option[MeasurementValue]): IntermediateSensorMap =
    copy(sensors = sensors +
      (sensorId ->
        measurement.map(v =>
          Some(sensors.get(sensorId).flatten.getOrElse(IntermediateSensorStats.empty).withMeasurement(v))
        ).getOrElse(sensors.getOrElse(sensorId, None)))
    )

  def mergeWith(other: IntermediateSensorMap): IntermediateSensorMap = {
    other.sensors.foldLeft(this)(
      (accumulator, stat) => {
        val current = accumulator.sensors.getOrElse(stat._1, None)
        IntermediateSensorMap(if(stat._2.isEmpty) {
          accumulator.sensors + (stat._1 -> current)
        } else if(current.isEmpty) {
          accumulator.sensors + (stat._1 -> stat._2)
        } else {
          accumulator.sensors + (stat._1 -> Some(stat._2.get.mergeWith(current.get)))
        })
      }
    )
  }
}

object IntermediateSensorMap {
  def empty: IntermediateSensorMap = IntermediateSensorMap(Map.empty)
}