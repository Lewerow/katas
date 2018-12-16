package main

import (
	"io"
	"io/ioutil"
	"log"
	"os"
)

type sensor struct {
	Records int
	Sum int
	Max int
	Min int
	NaNs int
}

func processFile(f *os.File) {
	data := make(map[string]sensor)

	data[""] = sensor{0, 0,0 ,0 ,0}
	arr := make([]byte, 10)

	for {
		n, err := f.Read(arr)

		if n > 0 {
			println(string(arr))
		}

		if err == io.EOF {
			break
		}

		if err != nil {
			log.Fatal(err)
			break
		}
	}
}

func main() {
	dir := os.Args[1]

	files, err := ioutil.ReadDir(dir)
	if err != nil {
		log.Fatal(err)
	}

	for _, f := range files {
		if f.IsDir() { continue }

		file, err := os.Open(f.Name())
		if err != nil {
			log.Fatal(err)
		}

		processFile(file)
	}

}
