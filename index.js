const express = require("express"),
  methodOverride = require("method-override"),
  bodyParser = require("body-parser"),
  mongoose = require("mongoose");


const Patient = require("./models/Details");
const app = express();


app.use(express.static("public"));
mongoose.connect("mongodb+srv://gaurav822:hackathon@cluster0-nnpbu.mongodb.net/patient?retryWrites=true&w=majority");


 
app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(methodOverride("_method"));
app.set("view engine", "ejs");


app.get("/", (req, res) => {
  res.render("technoMedica");
});


app.get("/doctorLogin", (req, res) => {
  res.render("doctorLogin");
})

app.get("/patientLogin", (req, res) => {
  Patient.find({}, (err, patient) => {
    if (err) {
      console.log(err);
      res.send("Not working");
    } else {
      res.render("patientLogin", {
        patient : patient
      });

    }
  })
})

app.get("/patientDetail", (req, res)=>{
  Patient.find({}, (err, patient) => {
    if (err) {
      console.log(err);
      res.send("Not working");
    } else {
      res.render("patientDetail", {
        patient : patient
      });
    }
  })
})

app.post("/patientLogin", (req, res) => {
  ({
    name,
    address,
    age,
    bloodPressure,
    wbcCount,
    haemoglobin,
    rbcCount,
    mvc,
    mchc,
    pcount,
    mpv,
    weight,
    height,
    bmi,
    ctrRatio,
    sbp,
    dbp,
    pulsePressure,
    pulseRate,
    thyroxin,
    bloodSugar,
    urineSugar,
    bloodUrineNitrogen,
    sUricAcid,
    sCalcium,
    sPhosphorus
  } = req.body)

  var patientDetails = {
    name,
    address,
    age,
    bloodPressure,
    wbcCount,
    haemoglobin,
    rbcCount,
    mvc,
    mchc,
    pcount,
    mpv,
    weight,
    height,
    bmi,
    ctrRatio,
    sbp,
    dbp,
    pulsePressure,
    pulseRate,
    thyroxin,
    bloodSugar,
    urineSugar,
    bloodUrineNitrogen,
    sUricAcid,
    sCalcium,
    sPhosphorus
  };
  Patient.remove();
  Patient.create(patientDetails, (err, newPatient) => {
    if (err) {
      console.log(err);
    } else {
      res.redirect("patientDetail");
    }
  });



})

app.listen(3000, () => {
  console.log("Server");
});