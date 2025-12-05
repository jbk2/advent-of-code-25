const sessionCookie = "53616c7465645f5f73499419b06debc22daa6d862c82262cae17bb2a35b814f8e5cfa1d068669724a31a971c8c9401463f6e52d4ca6b29f98dee2ed11dfb8b23"

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





