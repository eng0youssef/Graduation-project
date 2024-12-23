const express = require('express');
const { createTransport }= require('nodemailer');
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
  async function notifyAdmin() {
  const Transporter=createTransport({
    host:"live.smtp.mailtrap.io",
    port:587,
    auth:{
      user:"api",
      pass:"7f92840c5c10b24cb4bd5b788c86fcc5",
    },
  });
  let info = await Transporter.sendMail({
    from:'info@demomailtrap.com',
    to:"mohammedayman5112@gmail.com",
    subject:"Notification",
    text:"We Know Your Location and We try to help you",
  });
  console.log("Message Sent:",info.messageId);
}

app.listen(3000,()=>{
     notifyAdmin();
    console.log("done")
})
