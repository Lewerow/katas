package domain

case class MeasurementValue(value: Long) extends Ordered[MeasurementValue] {
  override def compare(that: MeasurementValue): Int = value.compareTo(that.value)
}
object MeasurementValue {
  def MIN: MeasurementValue = MeasurementValue(Long.MinValue)
  def MAX: MeasurementValue = MeasurementValue(Long.MaxValue)
}