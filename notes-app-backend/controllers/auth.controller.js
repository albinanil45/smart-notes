const User = require("../models/user.model");
const Otp = require("../models/otp.model");

const generateOtp = require("../utils/otp").generateOtp;
const hashOtp = require("../utils/otp").hashOtp;
const compareOtp = require("../utils/otp").compareOtp;

const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const sendOtpEmail = require("../utils/sendOtpEmail");

// REGISTER
exports.register = async (req, res) => {
    try {

        const { name, email, password } = req.body;

        const existingUser = await User.findOne({ email });

        if (existingUser)
            return res.status(400).json({ message: "User already exists" });

        const hashedPassword = await bcrypt.hash(password, 10);

        await User.create({
            name,
            email,
            password: hashedPassword
        });

        const otp = generateOtp();
        const hashedOtp = await hashOtp(otp);

        await Otp.findOneAndUpdate(
            { email },
            {
                otp: hashedOtp,
                attempts: 0,
                expiresAt: new Date(Date.now() + 5 * 60 * 1000),
                resendAfter: new Date(Date.now() + 60 * 1000)
            },
            { upsert: true }
        );

        await sendOtpEmail(email, otp);

        res.json({ message: "OTP sent for verification" });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// VERIFY OTP
exports.verifyOtp = async (req, res) => {

    try {

        const { email, otp } = req.body;

        const otpDoc = await Otp.findOne({ email });

        if (!otpDoc)
            return res.status(400).json({ message: "OTP expired" });

        if (otpDoc.attempts >= 5)
            return res.status(400).json({ message: "Too many attempts" });

        const isMatch = await compareOtp(otp, otpDoc.otp);

        if (!isMatch) {

            otpDoc.attempts += 1;
            await otpDoc.save();

            return res.status(400).json({ message: "Invalid OTP" });
        }

        await User.updateOne(
            { email },
            { isVerified: true }
        );

        await Otp.deleteOne({ email });

        res.json({ message: "Account verified successfully" });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// LOGIN
exports.login = async (req, res) => {

    try {

        const { email, password } = req.body;

        const user = await User.findOne({ email });

        if (!user)
            return res.status(400).json({ message: "User not found" });

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch)
            return res.status(400).json({ message: "Invalid credentials" });

        const token = jwt.sign(
            { id: user._id },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        res.json({
            token,
            user,
            message: "Login successful"
        });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }

};

// FORGOT PASSWORD
exports.forgotPassword = async (req, res) => {

    try {

        const { email } = req.body;

        const user = await User.findOne({ email });

        if (!user)
            return res.status(400).json({ message: "User not found" });

        const existingOtp = await Otp.findOne({ email });

        if (existingOtp && existingOtp.resendAfter > new Date()) {
            return res.status(400).json({
                message: "Please wait before requesting OTP again"
            });
        }

        const otp = generateOtp();
        const hashedOtp = await hashOtp(otp);

        await Otp.findOneAndUpdate(
            { email },
            {
                otp: hashedOtp,
                attempts: 0,
                expiresAt: new Date(Date.now() + 5 * 60 * 1000),
                resendAfter: new Date(Date.now() + 60 * 1000)
            },
            { upsert: true }
        );

        await sendOtpEmail(email, otp);

        res.json({ message: "OTP sent" });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// RESET PASSWORD
exports.resetPassword = async (req, res) => {

    try {

        const { email, otp, newPassword } = req.body;

        const otpDoc = await Otp.findOne({ email });

        if (!otpDoc)
            return res.status(400).json({ message: "OTP expired" });

        const isMatch = await compareOtp(otp, otpDoc.otp);

        if (!isMatch)
            return res.status(400).json({ message: "Invalid OTP" });

        const hashedPassword = await bcrypt.hash(newPassword, 10);

        await User.updateOne(
            { email },
            { password: hashedPassword }
        );

        await Otp.deleteOne({ email });

        res.json({ message: "Password reset successful" });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// RESEND OTP
exports.resendOtp = async (req, res) => {
    try {

        const { email } = req.body;

        const user = await User.findOne({ email });

        if (!user)
            return res.status(400).json({ message: "User not found" });

        // Prevent resend spam
        const existingOtp = await Otp.findOne({ email });

        if (existingOtp && existingOtp.resendAfter > new Date()) {
            return res.status(400).json({
                message: "Please wait before requesting OTP again"
            });
        }

        const otp = generateOtp();
        const hashedOtp = await hashOtp(otp);

        await Otp.findOneAndUpdate(
            { email },
            {
                otp: hashedOtp,
                attempts: 0,
                expiresAt: new Date(Date.now() + 5 * 60 * 1000),
                resendAfter: new Date(Date.now() + 60 * 1000)
            },
            { upsert: true }
        );

        await sendOtpEmail(email, otp);

        res.json({ message: "OTP resent successfully" });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// GET CURRENT USER
exports.getCurrentUser = async (req, res) => {

    try {

        const id = req.userId;

        const user = await User.findById(id).select("-password");

        if (!user)
            return res.status(404).json({ message: "User not found" });

        res.json(user);

    } catch (error) {
        res.status(500).json({ message: error.message });
    }

};