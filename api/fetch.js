fetch("https://jsonplaceholder.typicode.com/todos/1")
  .then(response => response.json())
  .then(data => console.log("✅ Fetch Works:", data))
  .catch(error => console.error("❌ Fetch Failed:", error));