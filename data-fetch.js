const sessionCookie = "53616c7465645f5f70dd06ae85d449d3a6edbb1c12b814dfccbaa2e4cfadb0451953d72a519b674d38c6c9157e03a3434e07e49b889a6c6af69d7e3b679856cb"

async function getInput(url) {
  const response = await fetch(url, {
    headers: {
      "Cookie": `session=${sessionCookie}`
    }
  });
  
  const text = await response.text();
  const arr = text.split('\n');
  
  return JSON.stringify(arr);
}

const url = process.argv[2]

getInput(url)
  .then(result => console.log(result))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });





