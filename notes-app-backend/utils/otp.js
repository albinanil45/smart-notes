const bcrypt = require("bcryptjs");

const generateOtp = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

const hashOtp = async (otp) => {
    return await bcrypt.hash(otp, 10);
};

const compareOtp = async (otp, hashedOtp) => {
    return await bcrypt.compare(otp, hashedOtp);
};

module.exports = {
    generateOtp,
    hashOtp,
    compareOtp
};