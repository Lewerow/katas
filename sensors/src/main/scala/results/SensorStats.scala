package results

import domain.MeasurementValue

case class SensorStats(min: MeasurementValue, max: MeasurementValue, avg: MeasurementValue)
