package calculation

import domain.MeasurementValue
import results.SensorStats

case class IntermediateSensorStats(min: MeasurementValue, max: MeasurementValue, sum: Long, count: Long) {
  def mergeWith(other: IntermediateSensorStats): IntermediateSensorStats =
    copy(if(min < other.min) min else other.min, if(max > other.max) max else other.max, sum + other.sum, count + other.count)

  def toFinal: SensorStats = SensorStats(min, max, MeasurementValue(sum / count))
  def withMeasurement(m: MeasurementValue): IntermediateSensorStats = {
    copy(
      min = if(m < min) m else min,
      max = if(m > max) m else max,
      sum = sum + m.value,
      count = count + 1
    )
  }
}
object IntermediateSensorStats {
  def empty: IntermediateSensorStats = IntermediateSensorStats(MeasurementValue.MAX, MeasurementValue.MIN, 0, 0)
}
