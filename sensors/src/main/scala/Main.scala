object Main extends App {
  if(args.length < 1) {
    throw new IllegalArgumentException("Not enough arguments")
  }

  println(s"From directory: ${args(0)}")

  Statistician(args(0))
    .calculateStats()
    .print()
}