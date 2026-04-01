const brevo = require("../config/brevo");

const sendOtpEmail = async (email, otp) => {
    try {
        await brevo.sendTransacEmail({
            sender: {
                email: "albinanilkumar45@gmail.com",
                name: "Notes App",
            },

            to: [{ email }],

            subject: "Your OTP Code",

            htmlContent: `
        <h3>Your OTP Code</h3>
        <p>Your verification code is:</p>
        <h2>${otp}</h2>
        <p>This OTP expires in 5 minutes.</p>
      `,
        });
    } catch (error) {
        console.log(error);
        throw new Error("Email send failed");
    }
};

module.exports = sendOtpEmail;