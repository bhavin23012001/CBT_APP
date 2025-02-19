const mongoose = require('mongoose');

const connection = mongoose.createConnection('mongodb+srv://admin:admin@cluster0.cgq0i.mongodb.net/').on('open',()=>{
    console.log("MongoDB Connected");
}).on('error',()=>{
    console.log("MongoDB Connection Error");
});

module.exports = connection;