document.querySelector('#check-api').addEventListener('click', async () => {
  const result = document.querySelector('#result');
  result.textContent = 'Requesting /api through NGINX…';
  try {
    const response = await fetch('/api');
    result.textContent = JSON.stringify(await response.json(), null, 2);
  } catch (error) {
    result.textContent = `Request failed: ${error}`;
  }
});
