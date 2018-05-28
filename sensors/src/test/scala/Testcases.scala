import java.io.File

import domain.SensorId

import scala.util.Try

object Testcases extends App {

  val resourcesPath = new File(getClass.getClassLoader.getResource("cases").getFile).toString

  assert(Try {Statistician(resourcesPath + "/error1").calculateStats()}.isFailure)
  assert(Try {Statistician(resourcesPath + "/error2").calculateStats()}.isFailure)
  assert(Try {Statistician(resourcesPath + "/error3").calculateStats()}.isFailure)
  assert(Try {Statistician(resourcesPath + "/error4").calculateStats()}.isFailure)

  val simplest = Statistician(resourcesPath + "/simple").calculateStats()

  val s1 = SensorId("s1")
  val s2 = SensorId("s2")
  val s3 = SensorId("s3")

  assert(simplest.fileCount == 2)
  assert(simplest.failedMeasurementCount == 2)
  assert(simplest.measurementCount == 7)
  assert(simplest.sensors.size == 3)
  assert(simplest.sensors(s3).isEmpty)
  assert(simplest.sensors(s1).get.max.value == 98)
  assert(simplest.sensors(s1).get.avg.value == 54)
  assert(simplest.sensors(s1).get.min.value == 10)
  assert(simplest.sensors(s2).get.max.value == 88)
  assert(simplest.sensors(s2).get.avg.value == 82)
  assert(simplest.sensors(s2).get.min.value == 78)

  assert(Statistician(resourcesPath + "/nofile").calculateStats().fileCount == 0)
}
