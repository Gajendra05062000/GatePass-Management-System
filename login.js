var uname, pwd;

function f1()
{
	uname=document.login.t1.value
	pwd=document.login.t2.value
	if(uname=="" || pwd=="")
	{
		alert("Please enter your username and password")
		document.login.t1.focus()
		return false;
	}
	
};