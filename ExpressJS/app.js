const express = require('express');
const app=express();
app.use(express.json())
let latitude = null;
let longitude = null;

app.post('/api/location', (req, res) => {
    const { latitude: lat, longitude: lon } = req.body;

    latitude = lat;
    longitude = lon;
  
    console.log(`Received location: ${latitude}, ${longitude}`);
    res.status(200).send('Location updated successfully');
  });

  app.get('/api/location', (req, res) => {
    if (latitude !== null && longitude !== null) {
        res.status(200).json({ latitude, longitude });
      } else {
        res.status(404).send('No location data available');
      }
  });
app.listen(3000,()=>{
    console.log("done")
})