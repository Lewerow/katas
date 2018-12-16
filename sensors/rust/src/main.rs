use std::fs;
use std::collections::HashMap;
use std::sync::Mutex;

fn main() {

    let dir_path = "G:\\Kata\\katas\\sensors\\data";
    // for each file in directory

    let data_mutex = Mutex::new(true);
    let mut full_data: Vec<HashMap<String, i32>> = Vec::new();
    for entry in fs::read_dir(dir_path).unwrap() {
        let mut data: HashMap<String, i32> = HashMap::new();
        let entry = entry.unwrap();
        let content = fs::read_to_string(entry.path()).unwrap();
        let lines = content.lines();
        for l in lines {
            let pieces: Vec<&str> = l.split(";").collect();

            if pieces.len() != 2 {
                eprintln!("Error: illegal line: {}", l);
                continue;
            }

            let key: &str = pieces.get(0).get_or_insert(&"");
            match pieces.get(1).unwrap().parse::<i32>() {
                Ok(v) => {
                    let val = data.get(key).map_or_else(|| v, |v1| v1 + v);
                    data.insert(key.to_string(), val);
                }
                Err(e) => {
                    if let Some(x) = pieces.get(1) {
                        if x != &"NaN" {
                            eprintln!("Error: {}. Not a number: {}", e, x);
                        }
                        continue;
                    }
                }
            }
        }

        {
            let _m = data_mutex.lock().unwrap();
            full_data.push(data);
        }
    }


    let mut totals: HashMap<String, i32> = HashMap::new();
    for ses in full_data {
        for (k, v) in ses {
            let v1 = totals.get(&k);
            totals.insert(k, v1.map_or_else(|| v, |v2| v2 + v));
        }
    }

    // open file

    // calculate stats

    // close file

    // after all

    // calculate all stats

    // print stuff
    for (k, v) in totals {
        println!("{}: {}", k, v)
    }
}
