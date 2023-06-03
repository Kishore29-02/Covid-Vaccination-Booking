const express = require("express");
const bodyParser = require('body-parser');
const mysql = require('mysql2');

const app = express();
const port = process.env.PORT || 5000;

app.use(bodyParser.urlencoded({extended:true}));
app.use(express.json());
// app.set('view-engine','ejs');

const pool = mysql.createPool({
    host : 'localhost',
    user:'root',
    password:"Tcka!2003",
    database:"covid",
    connectionLimit:10
})

//login

app.get('/login',(req,res)=> {
    res.sendFile(__dirname+"/login.html");
})

app.post('/login',(req,res)=>{
    const {id,pass} = req.body;
    const query = "SELECT * FROM admin WHERE admin_id = ? AND pass = ?";
    pool.query(query,[id,pass],(err,result)=>{
        if(err){
            res.semd({err});
        }
        if(result.length>0){
            res.redirect('/adminPage');
            res.end();
        }

        const query = "SELECT * FROM user WHERE user_id = ? AND pass = ?";
        pool.query(query,[id,pass],(err,result)=>{
            if(err){
                res.semd({err});
            }
            if(result.length>0){
                res.redirect('/userPage');
                res.end();
            }

            else {
                res.write("Invalid ID or password");
            }
        })
    })
})

app.get('/adminPage',(req,res)=>{
    // console.log(req.body);
    res.sendFile(__dirname+"/adminpage.html");
})

app.get('/userPage',(req,res)=>{
    res.send("user");
})

//register

app.get("/register",(req,res) => {
    res.sendFile(__dirname+"/register.html");
})

//CENTER OPERATIONS

// select

app.get('/all-center',(req,res)=> {
    const q = "SELECT * FROM CENTER";
    pool.query(q,(err,result) => {
        if(err) 
        res.send({err:err})
        else
        res.send(result);
    })
});

app.get('/center/id/:id',(req,res)=> {
    const q = "SELECT * FROM CENTER where center_id = ?";
    pool.query(q,[req.params.id],(err,result) => {
        if(err) 
        res.send({err:err})
        else
        res.send(result);
    })
});

app.get('/center/available',(req,res)=> {
    const q = "SELECT * FROM CENTER where available_slots>0";
    pool.query(q,(err,result) => {
        if(err) 
        res.send({err:err})
        else
        res.send(result);
    })
});

app.get('/center/time/:time',(req,res)=> {
    const q = "SELECT * FROM CENTER where ?> open_time AND ?<closing_time";
    pool.query(q,[[req.params.time],[req.params.time]],(err,result) => {
        if(err) 
        res.send({err:err})
        else
        res.send(result);
    })
});

//insert

app.get("/center",(req,res) => {
    res.sendFile(__dirname+"/center.html");
})

app.post('/center',(req,res) => {
    const query = "INSERT INTO center VALUES(?,?,?,?,?,?,?)";
    pool.query(query,[req.body.id,req.body.openTime,req.body.closingTime,req.body.available,req.body.contact,req.body.city,req.body.state],(err,result) => {
        if(err)
        res.send(err);
        else
        res.send("Inserted Successfully");
    })
});

//delete
app.delete('/center/delete/:id',(req,res) => {
    const query = "DELETE FROM center WHERE center_id = ?";
    pool.query(query,[req.params.id],(err,result) => {
        if(err)
        res.send(err);
        else
        res.send("deleted");
    })
});

// update 

app.put('/center/update/:id',(req,res) => {
    const query = "UPDATE center SET available_slots=? where center_id = ?";
    pool.query(query,[req.body.slots,req.params.id],(err,result) => {
        if(err)
        res.send(err);
        else
        res.send(`update ${req.body.slots}`);
    })
});

// user

// select

app.get('/all-users',(req,res)=> {
    const q = "SELECT * FROM user";
    pool.query(q,(err,result) => {
        if(err) 
        res.send({err:err})
        else
        res.send(result);
    })
});


app.post('/register',(req,res) => {
    const query = "INSERT INTO user (user_id, pass, fname, lname, age, phone_no, gender, city, state) VALUES(?,?,?,?,?,?,?,?,?)";
    console.log(req.body);
    const {user_id, pass, fname, lname, age, phone_no, gender, city, state} = req.body;
    console.log(user_id+pass);
    pool.query(query,[user_id, pass, fname, lname, age, phone_no, gender, city, state],(err,result) => {
        if(err) 
        res.send({err:err})
        else
        res.redirect("/login");
        res.end();
    })
});

// get appointment

app.put("/appointment/book",(req,res) => {
    const {user_id,center_id,vaccine_id,dose_no,appointment_date,appointment_time} = req.body;
    const query = "SELECT available_slots FROM center WHERE center_id = ?";
    pool.query(query,[center_id],(err,result)=>{
        if(err)
        res.send({err});
        
        if(result[0].available_slots == 0)
        res.send("No available slots");
        
        const innerQuery = "INSERT INTO appointment_record (user_id,center_id,vaccine_id,dose_no,appointment_date,appointment_time,status) VALUES(?,?,?,?,?,?,?)";
        pool.query(innerQuery,[user_id,center_id,vaccine_id,dose_no,appointment_date,appointment_time,"BOOKED"],(err,result) => {
            if(err)
            res.send({err});
            else
            res.send("Appointment Booked");
        })
    })
});

app.listen(port,()=>{
    console.log("The server is running");
})