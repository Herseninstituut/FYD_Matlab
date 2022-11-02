%setenvdj

dbpar = nhi_fyd_parms();

setenv('DJ_HOST', dbpar.Server)
setenv('DJ_USER', dbpar.User)
setenv('DJ_PASS', dbpar.Passw)