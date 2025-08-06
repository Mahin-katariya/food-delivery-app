import express from 'express'
import cors from 'cors'
import cookieParser from 'cookie-parser'

const app = express()
const PORT = process.env.PORT || 3000

app.use(cors({
    origin:process.env.CORS_ORIGIN,
    Credential:true
}))

app.use(express.json({limit:"16kb"})) //when requesting data in json format or body
app.use(express.urlencoded({extended:true,limit:"16kb"})) //when requesting data from url
app.use(express.static("public"))//files stored in a particular folder
app.use(cookieParser())

export {app}